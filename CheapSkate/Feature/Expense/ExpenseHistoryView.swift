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
    struct State {
        let chartData: [ExpenseData]
    }
}

struct ExpenseHistoryView: View {
    let store: StoreOf<ExpenseHistory>
    let viewModel = ExpenseHistoryViewModel()
    
    var body: some View {
        ScrollView() {
            ForEach(viewModel.monthlyExpenses(expenseData: store.state.chartData), id: \.key) { key, value in
                VStack(alignment: .leading) {
                    Text(viewModel.formatKey(key))
                        .font(.title)
                        .padding(.leading, 20)
                    expenseList(value.sorted(by: { $0.date > $1.date }))
                    Spacer()
                }
            }
            
            Spacer(minLength: 10)
            
            HStack {
                VStack{
                    Text("Monthly Expenses")
                    Text(viewModel.sum(of: store.chartData))
                }
                VStack{
                    Text("Average Daily Spend")
                    Text("\(viewModel.averageDailySpend(from: store.chartData))")
                }
                VStack{
                    Text("Projected Spending")
                    Text(viewModel.extrapolatedSpend(from: store.chartData))
                }
            }
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
                                    Text(viewModel.day(from: series.date))
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                }
                                .padding(.leading, 5)
                            Spacer()
                        }

                        
                        HStack {
                            Spacer()
                            Text(viewModel.currency(expense: series.amount))
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    ExpenseHistoryView(store: Store(
        initialState: Expense.State(
            chartData: [
                ExpenseData(id: UUID(), category: .food, amount: 6.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSinceNow: -200_000).timeIntervalSince1970)
            ]
        )) {
        Expense()
    })
}

