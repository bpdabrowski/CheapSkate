//
//  ExpenseChartTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 8/3/24.
//

import ComposableArchitecture
import XCTest
@testable import CheapSkate

final class ExpenseChartTests: XCTestCase {
    var store = TestStore(initialState: ExpenseChart.State(chartData: [
        ExpenseData(id: UUID(), category: .food, amount: 6.00, date: Date(timeIntervalSince1970: 1722160922).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: Date(timeIntervalSince1970: 1722420122).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: Date(timeIntervalSince1970: 1721556122).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1720951322).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1720346522).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1719828122).timeIntervalSince1970)
    ])) {
        ExpenseChart()
    }

    func testXAxisDomain() throws {
        XCTAssertEqual(Date(timeIntervalSince1970: 1722160922).startOfMonth()...Date(timeIntervalSince1970: 1722160922).endOfMonth(), store.state.xAxisDomain)
    }
    
    func testTotalForCategory_Empty() {
        store = TestStore(initialState: ExpenseChart.State(chartData: [])) {
            ExpenseChart()
        }
        
        XCTAssertEqual("Food - $0.00", store.state.total(for: .food))
        XCTAssertEqual("Groceries - $0.00", store.state.total(for: .groceries))
        XCTAssertEqual("Gas - $0.00", store.state.total(for: .gas))
        XCTAssertEqual("Misc - $0.00", store.state.total(for: .misc))
    }
}
