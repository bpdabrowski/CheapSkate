//
//  ExpenseChartTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 8/3/24.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import CheapSkate

@MainActor
struct ExpenseChartTests {
    let store = TestStore(initialState: ExpenseChart.State(chartData: [
        ExpenseData(id: UUID(), category: .food, amount: 6.00, date: 1722160922),
        ExpenseData(id: UUID(), category: .transportation, amount: 2.00, date: 1722420122),
        ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: 1721556122),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1720951322),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1720346522),
        ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: 1719828122)
    ])) {
        ExpenseChart()
    }

    @Test func xAxisDomain() {
        let date = Date(timeIntervalSince1970: 1722160922)
        #expect(date.startOfMonth...date.endOfMonth == store.state.xAxisDomain)
    }
    
    @Test func totalForCategory_Empty() {
        let store = TestStore(initialState: ExpenseChart.State(chartData: [])) {
            ExpenseChart()
        }
        
        #expect(store.state.total(for: .food) == "Food - $0.00")
        #expect(store.state.total(for: .groceries) == "Groceries - $0.00")
        #expect(store.state.total(for: .transportation) == "Transportation - $0.00")
        #expect(store.state.total(for: .misc) == "Misc - $0.00")
    }
}

struct ExpenseCategoryTests {
    private func decode(_ category: String) throws -> ExpenseCategory {
        try JSONDecoder().decode(ExpenseCategory.self, from: Data("\"\(category)\"".utf8))
    }

    @Test func decodesLegacyGasAsTransportation() throws {
        #expect(try decode("gas") == .transportation)
    }

    @Test func decodesCurrentCategories() throws {
        for category in ExpenseCategory.allCases {
            #expect(try decode(category.rawValue) == category)
        }
    }

    @Test func encodesTransportation() throws {
        let data = try JSONEncoder().encode(ExpenseCategory.transportation)
        #expect(String(decoding: data, as: UTF8.self) == "\"transportation\"")
    }

    @Test func rejectsUnknownCategories() {
        #expect(throws: DecodingError.self) { try decode("travel") }
    }
}
