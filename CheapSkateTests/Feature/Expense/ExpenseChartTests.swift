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
        ExpenseData(id: UUID(), category: .food, amount: 6.00, date: 1722160922),
        ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: 1722420122),
        ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: 1721556122),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1720951322),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1720346522),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1719828122)
    ])) {
        ExpenseChart()
    }

    func testXAxisDomain() throws {
        let date = Date(timeIntervalSince1970: 1722160922)
        XCTAssertEqual(date.startOfMonth...date.endOfMonth, store.state.xAxisDomain)
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
