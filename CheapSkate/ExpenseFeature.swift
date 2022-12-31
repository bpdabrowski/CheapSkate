//
//  ExpenseFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Combine
import ComposableArchitecture
import Foundation

struct ExpenseState: Equatable, Encodable {
    var category: ExpenseCategory = .groceries
    @BindableState var amount: Double = 0.00
    var date: Date = Date()
}

enum ExpenseAction: BindableAction {
    case binding(BindingAction<ExpenseState>)
    case selectCategory(ExpenseCategory)
    case submitExpense
    case resetState(Result<Void, APIError>)
}

struct ExpenseEnvironment {
    var saveExpense: (ExpenseState) -> Effect<Void, APIError>
}

let expenseReducer = Reducer<
  ExpenseState,
  ExpenseAction,
  SystemEnvironment<ExpenseEnvironment>
> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .selectCategory(let category):
        state.category = category
        return .none
    case .submitExpense:
        state.date = Date()
        return environment.saveExpense(state)
            .receive(on: environment.mainQueue())
            .catchToEffect()
            .map(ExpenseAction.resetState)
    case .resetState(let result):
        switch result {
        case .success:
            state.category = .groceries
            state.amount = 0.00
        case .failure:
            // send some sort of message back to the UI letting the user know that there was a failure.
            break
        }
        return .none
    }
}.binding()
