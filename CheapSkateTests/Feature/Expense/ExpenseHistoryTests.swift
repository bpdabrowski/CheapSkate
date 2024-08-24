//
//  ExpenseHistoryTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 7/14/24.
//

import ComposableArchitecture
import XCTest
@testable import CheapSkate

final class ExpenseHistoryTests: XCTestCase {
    
    func testMonthlyExpenses() throws {
        let earlyDate = Date(timeIntervalSinceReferenceDate: 100_000)
        let lateDate = Date(timeIntervalSinceReferenceDate: 5_000_000)
        let id = UUID(uuidString: "1")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [
                ExpenseData(id: id, category: .food, amount: 1.00, date: earlyDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: earlyDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: lateDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: lateDate.timeIntervalSince1970)
            ]),
            reducer: { ExpenseHistory() }
        )
        let monthlyExpenses = store.state.monthlyExpenses
        
        XCTAssertEqual(monthlyExpenses.first?.key,  DateComponents(year: 2001, month: 2))
        XCTAssertEqual(
            monthlyExpenses.first?.value,
            [
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: lateDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: lateDate.timeIntervalSince1970)
            ]
        )
        XCTAssertEqual(monthlyExpenses.last?.key, DateComponents(year: 2001, month: 1))
        XCTAssertEqual(
            monthlyExpenses.last?.value,
            [
                ExpenseData(id: id, category: .food, amount: 1.00, date: earlyDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: earlyDate.timeIntervalSince1970)
            ]
        )
    }
    
    func testExpenseSums() {
        let date = Date()
        let id = UUID(uuidString: "1")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [
                ExpenseData(id: id, category: .food, amount: 1.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: date.timeIntervalSince1970)
            ]),
            reducer: { ExpenseHistory() }
        )
        XCTAssertEqual(store.state.sum, "$10.00")
    }
    
    func testExpenseSums_MonthlyFilter() {
        let date = Date()
        let filteredDate = Date(timeIntervalSinceReferenceDate: 5_000_000)
        let id = UUID(uuidString: "1")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [
                ExpenseData(id: id, category: .food, amount: 1.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: filteredDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: filteredDate.timeIntervalSince1970)
            ]),
            reducer: { ExpenseHistory() }
        )
        XCTAssertEqual(store.state.sum, "$3.00")
    }
    
    func testExpenseSums_NotInMonth() {
        let date = Date(timeIntervalSinceReferenceDate: 5_000_000)
        let id = UUID(uuidString: "1")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [
                ExpenseData(id: id, category: .food, amount: 1.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: date.timeIntervalSince1970)
            ]),
            reducer: { ExpenseHistory() }
        )
        XCTAssertEqual(store.state.sum, "$0.00")
    }
    
    func testAverageDailySpend() {
        let date = Date(timeIntervalSince1970: 1_250_000)
        let id = UUID(uuidString: "1")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [
                ExpenseData(id: id, category: .food, amount: 6.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: date.timeIntervalSince1970)
            ]),
            reducer: { ExpenseHistory() }
        )
        XCTAssertEqual(store.state.averageDailySpend(dayOfMonth: date, referenceDate: date), "$1.00")
    }
    
    func testExtrapolatedSpend() {
        let date = Date(timeIntervalSince1970: 1_250_000)
        let id = UUID(uuidString: "1")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [
                ExpenseData(id: id, category: .food, amount: 6.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: date.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: date.timeIntervalSince1970)
            ]),
            reducer: { ExpenseHistory() }
        )
        XCTAssertEqual(store.state.extrapolatedSpend(date: date), "$31.00")
    }
}
