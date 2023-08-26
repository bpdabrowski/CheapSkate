//
//  RootFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import ComposableArchitecture
import Foundation

struct AppReducer: Reducer {
    struct State {
        var expense: Expense.State
        var login: Login.State?
        
        init(
            expense: Expense.State = .init(),
            login: Login.State? = nil
        ) {
            self.expense = expense
            self.login = login
        }
    }
    
    enum Action {
        case onAppear
        case expense(Expense.Action)
        case login(Login.Action)
    }
    
    let expenseRepository = ExpenseRepository()
    
    var body: some Reducer<State, Action> {
        self.core
          .ifLet(\.login, action: /Action.login) {
            Login()
          }
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Scope(state: \.expense, action: /Action.expense) {
            Expense()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if Auth.shared.token == nil {
                    state.login = .init()
                }
                return .none
            case .expense(.logoutButtonTapped):
                state.login = .init()
                Auth.shared.logout()
                return .none
            case .login(.handleLoginResult):
                if Auth.shared.token != nil {
                    state.login = nil
                    return .send(.expense(.getExpenses(Date())))
                } else {
                    return .none
                }
            case .expense,
                .login:
                return .none
            }
        }
    }
}
