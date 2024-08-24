//
//  ExpenseView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import ComposableArchitecture

enum ExpenseViewState {
    case idle
    case submitInProgress
    case submitSuccessful
    case submitError
}

struct ExpenseData: Equatable, Codable {
    var id: UUID? = UUID()
    var category: ExpenseCategory = .food
    var amount: Double = 0.00
    var date: Double = Date().timeIntervalSince1970
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case food
    case gas
    case groceries
    case misc
    
    var color: Color {
        switch self {
        case .food:
            return .blue
        case .gas:
            return .green
        case .groceries:
            return .orange
        case .misc:
            return .purple
        }
    }
}

@Reducer
struct Expense {
    @Reducer
    enum Destination {
        case expenseHistory(ExpenseHistory)
    }
    
    @ObservableState
    struct State {
        var data: ExpenseData = ExpenseData()
        var viewState: ExpenseViewState = .idle
        var chartData: [ExpenseData] = []
        var expenseChart: ExpenseChart.State = .init(chartData: [])
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case onAppear
        case selectCategory(ExpenseCategory)
        case amountChanged(Double)
        case submitExpense
        case handleSubmitResult(TaskResult<Void>)
        case resetState
        case getExpenses(Date? = nil)
        case handleGetExpenseResult(TaskResult<[ExpenseData]>)
        case logoutButtonTapped
        case expenseChart(ExpenseChart.Action)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.requestManager) var requestManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.getExpenses(Date()))
            case .selectCategory(let category):
                state.data.category = category
                return .none
            case .amountChanged(let amount):
                state.data.amount = amount
                return .none
            case .submitExpense:
                state.data.date = Date().timeIntervalSince1970
                state.viewState = .submitInProgress
                return .run { [data = state.data] send in
                    await send(.handleSubmitResult(
                        TaskResult {
                            try await requestManager.fireAndForget(ExpenseRequest.save(data))
                        }
                    )
                )
            }
            case .handleSubmitResult(let result):
                switch result {
                case .success:
                    state.viewState = .submitSuccessful
                case .failure:
                    state.viewState = .submitError
                }
                return .none
            case .resetState:
                state.data.category = .food
                state.data.amount = 0.00
                state.viewState = .idle
                return .send(.getExpenses(Date()))
            case .getExpenses(let date):
                return .run { send in
                    await send(
                        .handleGetExpenseResult(
                            TaskResult {
                                try await requestManager.perform(ExpenseRequest.getByMonth(date))
                            }
                        )
                    )
                }
            case .handleGetExpenseResult(let result):
                switch result {
                case .success(let chartData):
                    state.chartData = chartData.sorted(by: { $0.category.rawValue < $1.category.rawValue })
                    state.expenseChart = .init(chartData: state.chartData)
                case .failure:
                    break
                }
                return .none
            case .logoutButtonTapped:
                return .none
            case .expenseChart(.delegate(.viewHistory)):
                state.destination = .expenseHistory(.init(chartData: state.chartData))
                return .none
            case .expenseChart:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct ExpenseView: View {
    @Bindable var store: StoreOf<Expense>
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .center, spacing: 4.0) {
                    HStack {
                        ZStack {
                            Image("roller-skate")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 34, height: 34)
                                .frame(maxWidth: .infinity)
                            Button(action: { store.send(.logoutButtonTapped) }) {
                              Image(systemName: "rectangle.portrait.and.arrow.right")
                            }.frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)

                    ExpenseChartView(store: store.scope(state: \.expenseChart, action: \.expenseChart))
                        .padding()
                    
                    Spacer()
                    VStack {
                        categorySelector(store: store)
                        HStack {
                            CurrencyTextField(value: $store.data.amount.sending(\.amountChanged))
                            .frame(maxHeight: 50)
                            .truncationMode(.tail)
                            
                            submitButton(store: store)
                        }
                        .padding()
                    }
                }
            }
            .navigationDestination(item: $store.scope(state: \.destination?.expenseHistory, action: \.destination.expenseHistory)) { store in
                ExpenseHistoryView(store: store)
            }
        }.onAppear {
            store.send(.onAppear)
        }
    }
    
    private func categorySelector(store: StoreOf<Expense>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                    ZStack {
                        Capsule()
                            .frame(width: 105, height: 35)
                            .foregroundColor(category.color)
                        Button(action: {
                            store.send(.selectCategory(category))
                        }, label: {
                            Text(category.rawValue.capitalized)
                                .foregroundColor(tabTextColor(selectedCategory: category))
                                .font(.caption)
                        })
                        .frame(width: 100, height: 30)
                        .background(tabFillColor(selectedCategory: category))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
    
    private func submitButton(store: StoreOf<Expense>) -> some View {
        Button(action: {
            store.send(.submitExpense)
        }, label: {
            switch store.viewState {
            case .idle:
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
            case .submitSuccessful:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        store.send(.resetState)
                    }
            case .submitInProgress:
                ProgressView()
                    .tint(.white)
            case .submitError:
                Image(systemName: "xmark.circle")
                    .foregroundColor(.white)
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        store.send(.resetState)
                    }
            }
        })
        .padding()
        .background(submitButtonColor)
        .disabled(store.viewState != .idle)
        .clipShape(Capsule())
    }
}

extension ExpenseView {
    var submitButtonColor: Color {
        var color = Color.mint
        
        switch store.viewState {
        case .idle,
            .submitSuccessful:
            break
        case .submitInProgress:
            color = .gray
        case .submitError:
            color = .red
        }
        
        return color
    }
    
    func tabTextColor(selectedCategory: ExpenseCategory) -> Color {
        return store.data.category == selectedCategory ? .white : .black
    }
    
    func tabFillColor(selectedCategory: ExpenseCategory) -> Color {
        let cellCategory = store.data.category
        return cellCategory == selectedCategory ? cellCategory.color : .white
    }
}

#Preview {
    ExpenseView(store: Store(
        initialState: .init(
            chartData: [
                ExpenseData(id: UUID(), category: .food, amount: 6.00, date: Date(timeIntervalSince1970: 1722160922).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: Date(timeIntervalSince1970: 1722420122).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: Date(timeIntervalSince1970: 1721556122).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1720951322).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1720346522).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1719828122).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .food, amount: 3.00, date: Date(timeIntervalSince1970: 1719828122).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .groceries, amount: 2.00, date: Date(timeIntervalSince1970: 1719828122).timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .gas, amount: 1.00, date: Date(timeIntervalSince1970: 1719828122).timeIntervalSince1970)
            ]
        )) {
        Expense()
    })
}
