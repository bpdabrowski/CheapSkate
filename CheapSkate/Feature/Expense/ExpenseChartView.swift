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

@Reducer
struct ExpenseChart {
    @ObservableState
    struct State: Equatable {
        let chartData: [ExpenseData]
        
        var measurementsByMonth: String {
            guard let interval = chartData.first?.date else {
                return ""
            }
            
            return Calendar.current.veryShortMonthSymbols[interval.date.month - 1]
        }
        
        var xAxisDomain: ClosedRange<Date> {
            @Dependency(\.date) var defaultDate
            guard let interval = chartData.map(\.date).first else {
                return defaultDate.now.startOfMonth...defaultDate.now.endOfMonth
            }
            let date = Date(timeIntervalSince1970: interval)
            return date.startOfMonth...date.endOfMonth
        }
        
        func total(for category: ExpenseCategory) -> String {
            let dictionary = Dictionary(grouping: chartData, by: \.category)
            let formattedCategory = category.rawValue.capitalized
            guard let categoryTotal = dictionary[category]?.map(\.amount).reduce(0, +) else {
                return "\(formattedCategory) - \(0.0.currency)"
            }
            return "\(formattedCategory) - \(categoryTotal.currency)"
        }
    }
    
    enum Action {
        case delegate(Delegate)
        
        enum Delegate {
            case viewHistory
        }
    }
}

struct ExpenseChartView: View {
    let store: StoreOf<ExpenseChart>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.white)
                .shadow(color: Color(.lightGray), radius: 5, y: 5)
                .frame(height: 260)
            VStack {
                HStack {
                    Circle()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.blue)
                        .overlay {
                            Text(store.state.measurementsByMonth)
                                .padding(.top, 3)
                                .padding(.bottom, 3)
                                .foregroundColor(.white)
                        }
                    Text(store.state.chartData.sum.currency)
                        .padding(.bottom, 3)
                        .foregroundColor(.gray)
                    Spacer()
                }.padding(.leading, 20)

                Chart {
                    ForEach(store.chartData, id: \.id) { series in
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
                            chartKey(category: .food)
                            chartKey(category: .gas)
                        }
                        VStack(alignment: .leading) {
                            chartKey(category: .groceries)
                            chartKey(category: .misc)
                        }
                    }
                }
                .chartXScale(domain: store.state.xAxisDomain)
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
            }
        }
        .onTapGesture {
            store.send(.delegate(.viewHistory))
        }
    }
    
    private func chartKey(category: ExpenseCategory) -> some View {
        HStack {
            Circle()
                .foregroundColor(category.color)
                .frame(width: 10, height: 10)
            Text(store.state.total(for: category))
                .foregroundColor(Color.gray)
                .font(.system(size: 12))
        }
    }
}

#Preview {
    ExpenseChartView(store: Store(
        initialState: .init(
            chartData: [
                ExpenseData(id: UUID(), category: .food, amount: 6.00, date: 1722160922),
                ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: 1722420122),
                ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: 1721556122),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1720951322),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1720346522),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1719828122),
                ExpenseData(id: UUID(), category: .food, amount: 3.00, date: 1719828122),
                ExpenseData(id: UUID(), category: .groceries, amount: 2.00, date: 1719828122),
                ExpenseData(id: UUID(), category: .gas, amount: 1.00, date: 1719828122)
            ]
        )) {
        ExpenseChart()
    })
}
