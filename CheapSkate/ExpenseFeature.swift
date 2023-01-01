//
//  ExpenseFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Combine
import ComposableArchitecture
import Foundation

enum ExpenseViewState {
    case idle
    case submitInProgress
    case submitSuccessful
    case submitError
}

struct ExpenseData: Equatable, Encodable {
    var category: ExpenseCategory = .groceries
    @BindableState var amount: Double = 0.00
    var date: Date = Date()
}

struct ExpenseState: Equatable {
    var data: ExpenseData = ExpenseData()
    var viewState: ExpenseViewState = .idle
}

enum ExpenseAction: BindableAction {
    case binding(BindingAction<ExpenseState>)
    case selectCategory(ExpenseCategory)
    case submitExpense
    case handleSubmitResult(Result<Void, APIError>)
    case resetState
}

struct ExpenseEnvironment {
    var saveExpense: (ExpenseData) -> Effect<Void, APIError>
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
        state.data.category = category
        return .none
    case .submitExpense:
        state.data.date = Date()
        state.viewState = .submitInProgress
        return environment.saveExpense(state.data)
            .receive(on: environment.mainQueue())
            .catchToEffect()
            .map(ExpenseAction.handleSubmitResult)
    case .handleSubmitResult(let result):
        switch result {
        case .success:
            state.viewState = .submitSuccessful
        case .failure:
            state.viewState = .submitError
        }
        return .none
    case .resetState:
        state.data.category = .groceries
        state.data.amount = 0.00
        state.viewState = .idle

        return .none
    }
}.binding()
