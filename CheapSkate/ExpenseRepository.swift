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
    
    func saveExpense(state: ExpenseState) -> Effect<Void, APIError> {
        guard state.amount != 0 else {
            return Effect(error: APIError.invalidValue)
        }
        return expenseClient.saveExpense(state: state)
    }
}
