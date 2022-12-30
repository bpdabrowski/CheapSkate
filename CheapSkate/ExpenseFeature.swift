//
//  ExpenseFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Combine
import ComposableArchitecture
import Foundation

struct ExpenseState: Equatable {
    var category: ExpenseCategory = .groceries
    var amount: String = ""
}

enum ExpenseAction {
    case selectCategory(ExpenseCategory)
    case submitAmount(String)
    case submitExpense
    case resetState(Result<Void, APIError>)
}

struct ExpenseEnvironment {
    var putExpenseRequest: (ExpenseState) -> Effect<Void, APIError>
}

let expenseReducer = Reducer<
  ExpenseState,
  ExpenseAction,
  SystemEnvironment<ExpenseEnvironment>
> { state, action, environment in
    switch action {
    case .selectCategory(let category):
        state.category = category
        return .none
    case .submitAmount(let amount):
        state.amount = amount
        return EffectTask(value: ExpenseAction.submitExpense)
    case .submitExpense:
        return environment.putExpenseRequest(state)
            .receive(on: environment.mainQueue())
            .catchToEffect()
            .map(ExpenseAction.resetState)
    case .resetState(let result):
        switch result {
        case .success:
            state.category = .groceries
            state.amount = ""
        case .failure:
            // send some sort of message back to the UI letting the user know that there was a failure.
            break
        }
        return .none
    }
}
