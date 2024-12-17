//
//  AppView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 4/15/23.
//

import ComposableArchitecture
import Dependencies
import SwiftUI

@Reducer
struct AppReducer {
    @ObservableState
    struct State {
        var expense: Expense.State?
        var login: Login.State?
        var onboarding: Onboarding.State?
        @Shared(.appStorage("onboardingComplete")) var onboardingComplete = false
        
        init(
            expense: Expense.State? = nil,
            login: Login.State? = nil,
            onboarding: Onboarding.State? = nil
        ) {
            self.expense = expense
            self.login = login
            self.onboarding = onboarding
        }
    }
    
    enum Action {
        case onAppear
        case expense(Expense.Action)
        case login(Login.Action)
        case onboarding(Onboarding.Action)
    }
    
    @Dependency(\.auth) var auth
    
    var body: some Reducer<State, Action> {
        self.core
          .ifLet(\.login, action: \.login) {
            Login()
          }
          .ifLet(\.expense, action: \.expense) {
            Expense()
          }
          .ifLet(\.onboarding, action: \.onboarding) {
              Onboarding()
          }
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.onboardingComplete else {
                    state.onboarding = .init(signUpData: Shared(SignUpData()))
                    return .none
                }
                
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
                state.expense = .init()
                return .none
            case .onboarding(.delegate(.skipTapped)),
                .onboarding(.delegate(.completeTapped)):
                state.onboardingComplete = true
                return .send(.onAppear)
            case .expense,
                .login,
                .onboarding:
                return .none
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppReducer>
    
    var body: some View {
        Group {
            if store.login == nil, let expenseStore = store.scope(state: \.expense, action: \.expense) {
                ExpenseView.init(store: expenseStore)
            } else if let loginStore = store.scope(state: \.login, action: \.login) {
                LoginView.init(store: loginStore)
            } else if let onboardingStore = store.scope(state: \.onboarding, action: \.onboarding) {
                OnboardingFlow.init(store: onboardingStore)
            }
        }.onAppear {
            store.send(.onAppear)
        }
    }
}
