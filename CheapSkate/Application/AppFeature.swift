//
//  RootFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import ComposableArchitecture

struct AppReducer: ReducerProtocol {
    struct State {
        var expenseState: ExpenseFeature.State = ExpenseFeature.State()
    }
    
    enum Action {
        case expenseAction(ExpenseFeature.Action)
    }
    
    let expenseRepository = ExpenseRepository()
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.expenseState, action: /Action.expenseAction) {
            ExpenseFeature()
        }
    }
}
