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
                ExpenseData(id: id, category: .transportation, amount: 2.00, date: earlyDate.timeIntervalSince1970),
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
                ExpenseData(id: id, category: .transportation, amount: 2.00, date: earlyDate.timeIntervalSince1970)
            ]
        )
    }
    
    @Test func deleteExpense() async {
        let date = Date(timeIntervalSinceReferenceDate: 100_000).timeIntervalSince1970
        let id = UUID()
        let kept = ExpenseData(id: id, category: .food, amount: 1.00, date: date, remoteId: "kept")
        let deleted = ExpenseData(id: id, category: .transportation, amount: 2.00, date: date, remoteId: "deleted")
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
    
    @Test func editButtonTapped() async {
        let expense = ExpenseData(id: UUID(), category: .food, amount: 1.00, date: 0, remoteId: "edited")
        let store = TestStore(
            initialState: ExpenseHistory.State(chartData: [expense]),
            reducer: { ExpenseHistory() }
        )
        
        await store.send(.editButtonTapped(expense)) {
            $0.editExpense = EditExpense.State(expense: expense)
        }
        await store.send(.editExpense(.presented(.selectCategory(.transportation)))) {
            $0.editExpense?.expense.category = .transportation
        }
        await store.send(.editExpense(.presented(.amountChanged(12.50)))) {
            $0.editExpense?.expense.amount = 12.50
        }
    }
    
    @Test func saveEditedExpense() async {
        let id = UUID()
        let kept = ExpenseData(id: id, category: .food, amount: 1.00, date: 0, remoteId: "kept")
        let original = ExpenseData(id: id, category: .food, amount: 2.00, date: 0, remoteId: "edited")
        var edited = original
        edited.category = .transportation
        edited.amount = 12.50
        let requestManager = SpyRequestManager()
        let store = TestStore(
            initialState: ExpenseHistory.State(
                chartData: [kept, original],
                editExpense: EditExpense.State(expense: edited)
            ),
            reducer: { ExpenseHistory() },
            withDependencies: { $0.requestManager = requestManager }
        )
        
        await store.send(.editExpense(.presented(.delegate(.save(edited))))) {
            $0.chartData = [kept, edited]
        }
        await store.receive(\.delegate.expenseUpdated)
        
        let paths = await requestManager.paths
        #expect(paths == ["expenses/edited"])
    }
}

private actor SpyRequestManager: RequestManagerProtocol {
    var paths: [String] = []
    
    func perform(_ request: any RequestProtocol) async throws -> [ExpenseData] { [] }
    
    func fireAndForget(_ request: any RequestProtocol) async throws {
        paths.append(request.path)
    }
}
