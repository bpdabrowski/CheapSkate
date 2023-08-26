//
//  ExpenseRepository.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/30/22.
//

import ComposableArchitecture
import Foundation

class ExpenseRepository {
    
    let expenseClient = ExpenseClient()
    
    func saveExpense(state: ExpenseData) async throws {
        guard state.amount != 0 else {
            throw APIError.invalidValue
        }
        return try await expenseClient.saveExpense(state: state)
    }
    
    func getExpenses(for date: Date? = nil) async throws -> [ExpenseData] {
        return try await expenseClient.getExpenses(for: date)
    }
}
