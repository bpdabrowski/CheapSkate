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
}
