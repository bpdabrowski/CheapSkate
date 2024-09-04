//
//  ExpenseSummaryTests.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/3/24.
//

import ComposableArchitecture
import XCTest
@testable import CheapSkate

final class ExpenseSummaryTests: XCTestCase {
    private static let id = UUID(uuidString: "1")
    private static let date = Date()
    let data = [
        ExpenseData(id: id, category: .food, amount: 1.00, date: date.timeIntervalSince1970),
        ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
        ExpenseData(id: id, category: .groceries, amount: 3.00, date: date.timeIntervalSince1970),
        ExpenseData(id: id, category: .misc, amount: 4.00, date: date.timeIntervalSince1970)
    ]
    
    func testExpenseSums() {
        let store = TestStore(
            initialState: ExpenseSummary.State(chartData: data),
            reducer: { ExpenseSummary() }
        )
        XCTAssertEqual(store.state.chartData.sum.currency, "$10.00")
    }
    
    func testPlusMinus() {
        let store = TestStore(
            initialState: ExpenseSummary.State(chartData: data),
            reducer: { ExpenseSummary() }
        )
        XCTAssertEqual(store.state.plusMinus.currency, "$4,990.00")
    }
    
    func testPlusMinusDailyAverage() {
        let store = TestStore(
            initialState: ExpenseSummary.State(chartData: data),
            reducer: { ExpenseSummary() }
        )
        XCTAssertEqual(store.state.plusMinusDailyAverage.currency, "$163.33")
    }
    
    func testAverageDailySpend() {
        let store = TestStore(
            initialState: ExpenseSummary.State(chartData: data),
            reducer: { ExpenseSummary() }
        )
        XCTAssertEqual(store.state.averageDailySpend(dayOfMonth: Date(timeIntervalSince1970: 200)).currency, "$0.32")
    }
    
    func testExtrapolatedSpend() {
        let store = TestStore(
            initialState: ExpenseSummary.State(chartData: data),
            reducer: { ExpenseSummary() }
        )
        XCTAssertEqual(store.state.extrapolatedSpend(date: Date(timeIntervalSince1970: 200)).currency, "$10.00")
    }
}
