//
//  ExpenseHistory.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/10/23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ExpenseHistory {
    @ObservableState
    struct State: Equatable {
        var chartData: [ExpenseData]
        @Presents var editExpense: EditExpense.State?
        
        var monthlyExpenses: [(key: DateComponents, value: [Array<ExpenseData>.Element])] {
            return Dictionary(grouping: chartData, by: { $0.date.date.monthAndYear })
                .sorted { $0.key.month ?? 0 > $1.key.month ?? 0 }
                .sorted { $0.key.year ?? 0 > $1.key.year ?? 0 }
        }
    }
    
    enum Action {
        case onAppear
        case handleAllExpensesResult([ExpenseData])
        case editButtonTapped(ExpenseData)
        case editExpense(PresentationAction<EditExpense.Action>)
        case deleteExpense(ExpenseData)
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case expenseUpdated(ExpenseData)
            case expenseDeleted(ExpenseData)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    @Dependency(\.requestManager) var requestManager
                    let allExpenses = try await requestManager.perform(ExpenseRequest.all)
                    await send(.handleAllExpensesResult(allExpenses))
                }
            case let .handleAllExpensesResult(expenses):
                state.chartData = expenses
                return .none
            case let .editButtonTapped(expense):
                state.editExpense = .init(expense: expense)
                return .none
            case let .editExpense(.presented(.delegate(.save(expense)))):
                guard let remoteId = expense.remoteId,
                      let index = state.chartData.firstIndex(where: { $0.remoteId == remoteId }) else {
                    return .none
                }
                state.chartData[index] = expense
                return .run { send in
                    @Dependency(\.requestManager) var requestManager
                    try await requestManager.fireAndForget(ExpenseRequest.update(remoteId, expense))
                    await send(.delegate(.expenseUpdated(expense)))
                }
            case .editExpense:
                return .none
            case let .deleteExpense(expense):
                guard let remoteId = expense.remoteId else {
                    return .none
                }
                state.chartData.removeAll { $0.remoteId == remoteId }
                return .run { send in
                    @Dependency(\.requestManager) var requestManager
                    try await requestManager.fireAndForget(ExpenseRequest.delete(remoteId))
                    await send(.delegate(.expenseDeleted(expense)))
                }
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$editExpense, action: \.editExpense) {
            EditExpense()
        }
    }
}

struct ExpenseHistoryView: View {
    @Bindable var store: StoreOf<ExpenseHistory>
    
    var body: some View {
        ScrollView() {
            ForEach(store.state.monthlyExpenses, id: \.key) { key, value in
                VStack(alignment: .leading) {
                    Text(formatKey(key))
                        .font(.title)
                        .padding(.leading, 20)
                    expenseList(value.sorted(by: { $0.date > $1.date }))
                    HistoricalExpenseSummaryView(
                        store: Store(
                            initialState: ExpenseSummary.State(chartData: value),
                            reducer: { ExpenseSummary() }
                        )
                    )
                    
                    Spacer()
                }
            }
            
            Spacer(minLength: 10)
        }
        .sheet(item: $store.scope(state: \.editExpense, action: \.editExpense)) { store in
            EditExpenseView(store: store)
                .presentationDetents([.medium])
        }
    }
    
    private func expenseList(_ data: [ExpenseData]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 5) {
                ForEach(data, id: \.id) { series in
                    ZStack {
                        Capsule()
                            .frame(width: 115, height: 35)
                            .foregroundColor(series.category.color)
                        Capsule()
                            .frame(width: 110, height: 30)
                            .foregroundColor(.white)
                        HStack {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundColor(series.category.color)
                                .overlay {
                                    Text(String(series.date.date.day))
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                }
                                .padding(.leading, 5)
                            Spacer()
                        }

                        
                        HStack {
                            Spacer()
                            Text(series.amount.currency)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                        }
                    }
                    .contentShape(.contextMenuPreview, Capsule())
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            store.send(.editButtonTapped(series))
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            store.send(.deleteExpense(series))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension ExpenseHistoryView {
    func formatKey(_ key: DateComponents) -> String {
        guard let month = key.month,
            let year = key.year else {
            return ""
        }

        let monthSymbol = Calendar.current.monthSymbols[month - 1]
        return "\(monthSymbol) \(year)"
    }
}

extension Calendar {
    func isDateInThisMonth(_ date: Date, referenceDate: Date = Date()) -> Bool {
      return isDate(date, equalTo: referenceDate, toGranularity: .month)
    }
}

#Preview {
    ExpenseHistoryView(store: Store(
        initialState: .init(
            chartData: [
                ExpenseData(id: UUID(), category: .food, amount: 6.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSinceNow: -200_000).timeIntervalSince1970)
            ]
        )) {
        ExpenseHistory()
    })
}

