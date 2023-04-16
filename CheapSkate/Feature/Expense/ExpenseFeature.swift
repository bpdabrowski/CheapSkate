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
    case logout
}

struct ExpenseData: Equatable, Codable {
    var id: UUID?
    var category: ExpenseCategory = .food
    var amount: Double = 0.00
    var date: Date = Date()
}

struct ExpenseFeature: ReducerProtocol {
    struct State: Equatable {
        var data: ExpenseData = ExpenseData()
        var viewState: ExpenseViewState = .idle
        var chartData: [ExpenseData] = []
    }
    
    enum Action {
        case onAppear
        case selectCategory(ExpenseCategory)
        case amountChanged(Double)
        case submitExpense
        case handleSubmitResult(Result<Void, APIError>)
        case resetState
        case getExpenses(Date? = nil)
        case handleGetExpenseResult(Result<[ExpenseData], APIError>)
        case submitLogin(String, String)
        case handleLoginResult(Result<AuthResult, APIError>)
        case showLogoutView // I think this should be moved into its own state and then scoped in the proper context.
    }
    
    let expenseRepository = ExpenseRepository()
    @Dependency(\.mainQueue) var mainQueue
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            if Auth().token == nil {
                return Effect(value: .showLogoutView)
            } else {
                return Effect(value: .getExpenses(Date()))
            }
        case .selectCategory(let category):
            state.data.category = category
            return .none
        case .amountChanged(let amount):
            state.data.amount = amount
            return .none
        case .submitExpense:
            state.data.date = Date()
            state.viewState = .submitInProgress
            return expenseRepository.saveExpense(state: state.data)
                .receive(on: mainQueue)
                .catchToEffect()
                .map(ExpenseFeature.Action.handleSubmitResult)
        case .handleSubmitResult(let result):
            switch result {
            case .success:
                state.viewState = .submitSuccessful
            case .failure:
                state.viewState = .submitError
            }
            return .none
        case .resetState:
            state.data.category = .food
            state.data.amount = 0.00
            state.viewState = .idle
            
            return Effect(value: .getExpenses(Date()))
        case .getExpenses(let date):
            return expenseRepository.getExpenses(for: date)
                .receive(on: mainQueue)
                .catchToEffect()
                .map(ExpenseFeature.Action.handleGetExpenseResult)
        case .handleGetExpenseResult(let result):
            switch result {
            case .success(let chartData):
                state.chartData = chartData.sorted(by: { $0.category.rawValue < $1.category.rawValue })
            case .failure:
                break
            }
            return .none
        case .submitLogin(let username, let password):
            return Auth().login(username: username, password: password) // probably need to put auth in an environment class.
                .receive(on: mainQueue)
                .catchToEffect()
                .map(ExpenseFeature.Action.handleLoginResult)
        case .handleLoginResult(let result):
            switch result {
            case .success:
                state.viewState = .idle
            case .failure:
                state.viewState = .logout
            }
            return Effect(value: .getExpenses(Date()))
        case .showLogoutView:
            Auth().logout()
            state.viewState = .logout
            return .none
        }
    }
}
