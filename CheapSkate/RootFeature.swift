//
//  RootFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import ComposableArchitecture

struct RootState {
  var expenseState = ExpenseState()
}

enum RootAction {
  case expenseAction(ExpenseAction)
}

struct RootEnvironment { }

// swiftlint:disable trailing_closure
let rootReducer = Reducer<
  RootState,
  RootAction,
  SystemEnvironment<RootEnvironment>
>.combine(
  expenseReducer.pullback(
    state: \.expenseState,
    action: /RootAction.expenseAction,
    environment: { _ in
      .live(environment: ExpenseEnvironment(putExpenseRequest: putExpenseEffect))
    }))
// swiftlint:enable trailing_closure
