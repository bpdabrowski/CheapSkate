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
    let store: Store<ExpenseState, ExpenseAction>
    let viewModel = ExpenseChartViewModel()
    
    var body: some View {
        WithViewStore(store) { viewStore in
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
                                Text(viewModel.measurementsByMonth(viewStore.chartData.first?.date))
                                    .padding(.top, 3)
                                    .padding(.bottom, 3)
                                    .foregroundColor(.white)
                            }
                        Text(viewModel.total(expenseData: viewStore.chartData))
                            .padding(.bottom, 3)
                            .foregroundColor(.gray)
                        Spacer()
                    }.padding(.leading, 20)

                    Chart {
                        ForEach(viewStore.chartData, id: \.date) { series in
                            BarMark(
                                x: .value("Date", series.date, unit: .day),
                                y: .value("Amount", series.amount)
                            ).foregroundStyle(by: .value("Category", series.category.rawValue))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                    .frame(height: 175)
                    .chartLegend(position: .bottom, alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                chartKey(category: .food, expenseData: viewStore.chartData)
                                chartKey(category: .gas, expenseData: viewStore.chartData)
                            }
                            VStack(alignment: .leading) {
                                chartKey(category: .groceries, expenseData: viewStore.chartData)
                                chartKey(category: .misc, expenseData: viewStore.chartData)
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(minimumStride: 7)) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(
                                format: .dateTime.week(.weekOfMonth)
                            )
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
                                ExpenseHistoryView()
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
