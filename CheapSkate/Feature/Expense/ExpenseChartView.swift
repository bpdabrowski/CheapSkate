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
                    .frame(height: 250)
                VStack {
                    Text(viewModel.measurementsByMonth(viewStore.chartData.first?.date))
                    Chart {
                        ForEach(viewStore.chartData, id: \.date) { series in
                            BarMark(
                                x: .value("Date", series.date, unit: .day),
                                y: .value("Amount", series.amount)
                            ).foregroundStyle(by: .value("Category", series.category.rawValue.capitalized))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                    .frame(height: 175)
                    .chartXAxis {
                        AxisMarks(values: .automatic(minimumStride: 7)) { axisValue in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(
                                format: .dateTime.week(.weekOfMonth)
                            )
                        }
                    }
                }
            }
        }
    }
}
