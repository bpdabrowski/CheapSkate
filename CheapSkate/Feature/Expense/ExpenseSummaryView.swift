//
//  ExpenseSummaryView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/3/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ExpenseSummary {
    @ObservableState
    struct State: Equatable {
        var chartData: [ExpenseData] = []
        
        var monthlyGoal: Double {
            5_000.00
        }
        
        var plusMinus: Double {
            monthlyGoal - chartData.sum
        }
        
        var plusMinusDailyAverage: Double {
            (monthlyGoal / Double(Date().daysInMonth)) - averageDailySpend()
        }
        
        func averageDailySpend(dayOfMonth: Date = Date()) -> Double {
            chartData.sum / Double(dayOfMonth.day)
        }
        
        func extrapolatedSpend(date: Date = Date()) -> Double {
            averageDailySpend(dayOfMonth: date) * Double(date.daysInMonth)
        }
    }
}

struct ExpenseSummaryView: View {
    @Bindable var store: StoreOf<ExpenseSummary>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                SummaryCell(title: "Monthly Expenses", data: store.state.chartData.sum, color: .blue)
                SummaryCell(title: "Daily Average", data: store.state.averageDailySpend(), color: .green)
                SummaryCell(title: "Projected", data: store.state.extrapolatedSpend(), color: .orange)
                SummaryCell(title: "+/- Total", data: store.state.plusMinus, color: .purple)
                SummaryCell(title: "+/- Daily Average", data: store.state.plusMinusDailyAverage, color: .blue)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}

struct HistoricalExpenseSummaryView: View {
    @Bindable var store: StoreOf<ExpenseSummary>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                SummaryCell(title: "Monthly Expenses", data: store.state.chartData.sum, color: .blue)
                SummaryCell(title: "Daily Average", data: store.state.averageDailySpend(), color: .green)
                SummaryCell(title: "+/- Total", data: store.state.plusMinus, color: .orange)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}

fileprivate struct SummaryCell: View {
    let title: String
    let data: Double
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(color)
                .shadow(color: Color(.lightGray), radius: 5, y: 5)
                .frame(width: 125, height: 60)
            VStack{
                Text(title)
                    .foregroundColor(.white)
                    .font(.caption)
                Text(data.currency)
                    .foregroundColor(.white)
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
}
