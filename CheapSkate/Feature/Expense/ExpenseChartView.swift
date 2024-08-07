//
//  ExpenseChartView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/1/23.
//

import Foundation
import SwiftUI
import Charts
import ComposableArchitecture

struct ExpenseChartView: View {
    let store: StoreOf<Expense>
    let viewModel = ExpenseChartViewModel()
    
    var body: some View {
        WithViewStore(store, observe: \.chartData) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.white)
                    .shadow(color: Color(UIColor.lightGray), radius: 5, y: 5)
                    .frame(height: 300)
                VStack {
                    HStack {
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.blue)
                            .overlay {
                                Text(viewModel.measurementsByMonth(viewStore.state.first?.date))
                                    .padding(.top, 3)
                                    .padding(.bottom, 3)
                                    .foregroundColor(.white)
                            }
                        Text(viewModel.total(expenseData: viewStore.state))
                            .padding(.bottom, 3)
                            .foregroundColor(.gray)
                        Spacer()
                    }.padding(.leading, 20)

                    Chart {
                        ForEach(viewStore.state, id: \.id) { series in
                            BarMark(
                                x: .value("Date", Date(timeIntervalSince1970: series.date), unit: .day),
                                y: .value("Amount", series.amount)
                            )
                            .foregroundStyle(series.category.color)
                            .foregroundStyle(by: .value("Category", series.category.rawValue))
                            
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                    .frame(height: 175)
                    .chartLegend(position: .bottom, alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                chartKey(category: .food, expenseData: viewStore.state)
                                chartKey(category: .gas, expenseData: viewStore.state)
                            }
                            VStack(alignment: .leading) {
                                chartKey(category: .groceries, expenseData: viewStore.state)
                                chartKey(category: .misc, expenseData: viewStore.state)
                            }
                        }
                    }
                    .chartXScale(domain: viewModel.xAxisDomain(expenseData: viewStore.state))
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            if let date = value.as(Date.self) {
                                let day = Calendar.current.component(.day, from: date)
                                if ((day % 7) == 0) || day == 1 {
                                    AxisValueLabel(format: .dateTime.day())
                                    AxisTick()
                                    AxisGridLine()
                                }
                            }
                        }
                    }
                    
                    VStack {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .padding(.leading, 20)
                            .foregroundColor(.gray)
                        HStack() {
                            Spacer()
                            NavigationLink("View Expense History") {
                                ExpenseHistoryView(store: store)
                            }.font(.system(size: 16))
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                    }
                }
            }
        }
    }
    
    private func chartKey(category: ExpenseCategory, expenseData: [ExpenseData]) -> some View {
        HStack {
            Circle()
                .foregroundColor(category.color)
                .frame(width: 10, height: 10)
            Text(viewModel.total(for: category, expenseData: expenseData))
                .foregroundColor(Color.gray)
                .font(.system(size: 12))
        }
    }
}

#Preview {
    ExpenseChartView(store: Store(
        initialState: Expense.State(
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
