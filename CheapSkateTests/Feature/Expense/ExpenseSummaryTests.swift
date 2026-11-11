//
//  ExpenseSummaryTests.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/3/24.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import CheapSkate

@MainActor
struct ExpenseSummaryTests {
    private static let id = UUID(uuidString: "1")
    private static let date = Date()
    private static let data = [
        ExpenseData(id: id, category: .food, amount: 1.00, date: date.timeIntervalSince1970),
        ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
        ExpenseData(id: id, category: .groceries, amount: 3.00, date: date.timeIntervalSince1970),
        ExpenseData(id: id, category: .misc, amount: 4.00, date: date.timeIntervalSince1970)
    ]
    let store = TestStore(
        initialState: ExpenseSummary.State(chartData: data),
        reducer: { ExpenseSummary() }
    )
    
    @Test func expenseSums() {
        #expect(store.state.chartData.sum.currency == "$10.00")
    }
    
    @Test func plusMinus() {
        #expect(store.state.plusMinus.currency == "$4,990.00")
    }
    
    @Test func plusMinusDailyAverage() {
        #expect(store.state.plusMinusDailyAverage.currency == "$163.33")
    }
    
    @Test func averageDailySpend() {
        #expect(store.state.averageDailySpend(dayOfMonth: Date(timeIntervalSince1970: 200)).currency == "$0.32")
    }
    
    @Test func extrapolatedSpend() {
        #expect(store.state.extrapolatedSpend(date: Date(timeIntervalSince1970: 200)).currency == "$10.00")
    }
}
