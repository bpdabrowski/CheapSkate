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
    
    func saveExpense(state: ExpenseData) -> Effect<Void, APIError> {
        guard state.amount != 0 else {
            return Effect(error: APIError.invalidValue)
        }
        return expenseClient.saveExpense(state: state)
    }
    
    func getExpenses(for date: Date? = nil) -> Effect<[ExpenseData], APIError> {
        return expenseClient.getExpenses(for: date)
    }
}
