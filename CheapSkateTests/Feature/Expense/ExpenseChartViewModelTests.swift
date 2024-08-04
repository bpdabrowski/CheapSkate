//
//  ExpenseChartViewModelTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 8/3/24.
//

import XCTest
@testable import CheapSkate

final class ExpenseChartViewModelTests: XCTestCase {
    let subject = ExpenseChartViewModel()
    let data = [
        ExpenseData(id: UUID(), category: .food, amount: 6.00, date: Date(timeIntervalSince1970: 1722160922).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: Date(timeIntervalSince1970: 1722420122).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: Date(timeIntervalSince1970: 1721556122).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1720951322).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1720346522).timeIntervalSince1970),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSince1970: 1719828122).timeIntervalSince1970)
    ]

    func testXAxisDomain() throws {
        XCTAssertEqual(Date(timeIntervalSince1970: 1722160922).startOfMonth()...Date(timeIntervalSince1970: 1722160922).endOfMonth(), subject.xAxisDomain(expenseData: data))
    }
    
    func testXAxisDomain_DefaultRange() throws {
        let defaultDate = Date(timeIntervalSince1970: 200)
        XCTAssertEqual(defaultDate.startOfMonth()...defaultDate.endOfMonth(), subject.xAxisDomain(expenseData: [], defaultDate: defaultDate))
    }
    
    func testTotalForCategory_Empty() {
        XCTAssertEqual("Food - $0.00", subject.total(for: .food, expenseData: []))
        XCTAssertEqual("Groceries - $0.00", subject.total(for: .groceries, expenseData: []))
        XCTAssertEqual("Gas - $0.00", subject.total(for: .gas, expenseData: []))
        XCTAssertEqual("Misc - $0.00", subject.total(for: .misc, expenseData: []))
    }
}
