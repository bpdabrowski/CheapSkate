//
//  ExpenseHistoryTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 7/14/24.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import CheapSkate

@MainActor
struct ExpenseHistoryTests {
    
    @Test func monthlyExpenses() {
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
        
        #expect(monthlyExpenses.first?.key == DateComponents(year: 2001, month: 2))
        #expect(
            monthlyExpenses.first?.value == [
                ExpenseData(id: id, category: .groceries, amount: 3.00, date: lateDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .misc, amount: 4.00, date: lateDate.timeIntervalSince1970)
            ]
        )
        #expect(monthlyExpenses.last?.key == DateComponents(year: 2001, month: 1))
        #expect(
            monthlyExpenses.last?.value == [
                ExpenseData(id: id, category: .food, amount: 1.00, date: earlyDate.timeIntervalSince1970),
                ExpenseData(id: id, category: .gas, amount: 2.00, date: earlyDate.timeIntervalSince1970)
            ]
        )
    }
    
    @Test func deleteExpense() async {
        let date = Date(timeIntervalSinceReferenceDate: 100_000).timeIntervalSince1970
        let id = UUID()
        let kept = ExpenseData(id: id, category: .food, amount: 1.00, date: date, remoteId: "kept")
        let deleted = ExpenseData(id: id, category: .gas, amount: 2.00, date: date, remoteId: "deleted")
        let requestManager = SpyRequestManager()
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [kept, deleted]),
            reducer: { ExpenseHistory() },
            withDependencies: { $0.requestManager = requestManager }
        )
        
        await store.send(.deleteExpense(deleted)) {
            $0.chartData = [kept]
        }
        await store.receive(\.delegate)
        
        let paths = await requestManager.paths
        #expect(paths == ["expenses/deleted"])
    }
}

private actor SpyRequestManager: RequestManagerProtocol {
    var paths: [String] = []
    
    func perform(_ request: any RequestProtocol) async throws -> [ExpenseData] { [] }
    
    func fireAndForget(_ request: any RequestProtocol) async throws {
        paths.append(request.path)
    }
}
