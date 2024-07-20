//
//  AppView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 4/15/23.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

struct AppReducer: Reducer {
    struct State {
        var expense: Expense.State?
        var login: Login.State?
        
        init(
            expense: Expense.State? = nil,
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
    
    @Dependency(\.auth) var auth
    
    var body: some Reducer<State, Action> {
        self.core
          .ifLet(\.login, action: /Action.login) {
            Login()
          }
          .ifLet(\.expense, action: /Action.expense) {
            Expense()
          }
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard auth.currentUser() != nil else {
                    state.login = .init()
                    return .none
                }
                state.expense = .init()
                return .none
            case .expense(.logoutButtonTapped):
                auth.signOut()
                state.login = .init()
                return .none
            case .login(.handleLoginResult):
                guard auth.currentUser() != nil else {
                    return .none
                }
                
                state.login = nil
                return .send(.expense(.getExpenses(Date())))
            case .expense,
                .login:
                return .none
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppReducer>

    struct ViewState: Equatable {
      let isLoginPresented: Bool

      init(state: AppReducer.State) {
        self.isLoginPresented = state.login != nil
      }
    }

    public init(store: StoreOf<AppReducer>) {
      self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init(state:)) { viewStore in
            Group {
                if !viewStore.isLoginPresented {
                    IfLetStore(
                      self.store.scope(state: \.expense, action: AppReducer.Action.expense),
                      then: ExpenseView.init(store:)
                    )
                } else {
                    IfLetStore(
                      self.store.scope(state: \.login, action: AppReducer.Action.login),
                      then: LoginView.init(store:)
                    )
                }
            }.onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
