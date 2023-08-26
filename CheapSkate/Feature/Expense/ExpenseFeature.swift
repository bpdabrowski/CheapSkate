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

struct ExpenseData: Equatable, Codable {
    var id: UUID?
    var category: ExpenseCategory = .food
    var amount: Double = 0.00
    var date: Date = Date()
}

struct Expense: Reducer {
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
        case handleSubmitResult(TaskResult<Void>)
        case resetState
        case getExpenses(Date? = nil)
        case handleGetExpenseResult(TaskResult<[ExpenseData]>)
        case logoutButtonTapped
    }
    
    let expenseRepository = ExpenseRepository()
    @Dependency(\.mainQueue) var mainQueue
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .send(.getExpenses(Date()))
        case .selectCategory(let category):
            state.data.category = category
            return .none
        case .amountChanged(let amount):
            state.data.amount = amount
            return .none
        case .submitExpense:
            state.data.date = Date()
            state.viewState = .submitInProgress
            return .run { [data = state.data] send in
                await send(.handleSubmitResult(TaskResult { try await expenseRepository.saveExpense(state: data) }))
            }
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
            return .send(.getExpenses(Date()))
        case .getExpenses(let date):
            return .run { send in
                await send(.handleGetExpenseResult(TaskResult { try await expenseRepository.getExpenses(for: date) }))
            }
        case .handleGetExpenseResult(let result):
            switch result {
            case .success(let chartData):
                state.chartData = chartData.sorted(by: { $0.category.rawValue < $1.category.rawValue })
            case .failure:
                break
            }
            return .none
        case .logoutButtonTapped:
            return .none
        }
    }
}
