//
//  ExpenseHistory.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/10/23.
//

import SwiftUI
import ComposableArchitecture

struct ExpenseHistoryView: View {
    let store: StoreOf<Expense>
    let viewModel = ExpenseHistoryViewModel()
    
    var body: some View {
        WithViewStore(store, observe: \.chartData) { viewStore in
            ScrollView() {
                ForEach(viewModel.monthlyExpenses(expenseData: viewStore.state), id: \.key) { key, value in
                    VStack(alignment: .leading) {
                        Text(viewModel.formatKey(key))
                            .font(.title)
                        expenseList(value.sorted(by: { $0.date > $1.date }))
                        Spacer()
                    }.padding(.leading, 20)
                }
                
                Spacer(minLength: 10)
                
                HStack {
                    VStack{
                        Text("Monthly Expenses")
                        Text(viewModel.sum(of: viewStore.state))
                    }
                    VStack{
                        Text("Average Daily Spend")
                        Text("\(viewModel.averageDailySpend(from: viewStore.state))")
                    }
                    VStack{
                        Text("Projected Spending")
                        Text(viewModel.extrapolatedSpend(from: viewStore.state))
                    }
                }
            }.onAppear {
                viewStore.send(.getExpenses())
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
            }.padding(.bottom, 10)
        }
    }
}
