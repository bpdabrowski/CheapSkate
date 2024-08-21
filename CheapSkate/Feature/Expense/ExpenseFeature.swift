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
    var id: UUID? = UUID()
    var category: ExpenseCategory = .food
    var amount: Double = 0.00
    var date: Double = Date().timeIntervalSince1970
}

@Reducer
struct Expense {
    @Reducer
    enum Destination {
        case expenseHistory(ExpenseHistory)
    }
    
    @ObservableState
    struct State {
        var data: ExpenseData = ExpenseData()
        var viewState: ExpenseViewState = .idle
        var chartData: [ExpenseData] = []
        var expenseChart: ExpenseChart.State = .init(chartData: [])
        @Presents var destination: Destination.State?
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
        case expenseChart(ExpenseChart.Action)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.requestManager) var requestManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
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
                state.data.date = Date().timeIntervalSince1970
                state.viewState = .submitInProgress
                return .run { [data = state.data] send in
                    await send(.handleSubmitResult(
                        TaskResult {
                            try await requestManager.fireAndForget(ExpenseRequest.save(data))
                        }
                    )
                )
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
                    await send(
                        .handleGetExpenseResult(
                            TaskResult {
                                try await requestManager.perform(ExpenseRequest.getByMonth(date))
                            }
                        )
                    )
                }
            case .handleGetExpenseResult(let result):
                switch result {
                case .success(let chartData):
                    state.chartData = chartData.sorted(by: { $0.category.rawValue < $1.category.rawValue })
                    state.expenseChart = .init(chartData: state.chartData)
                case .failure:
                    break
                }
                return .none
            case .logoutButtonTapped:
                return .none
            case .expenseChart(.delegate(.viewHistory)):
                state.destination = .expenseHistory(.init(chartData: state.chartData))
                return .none
            case .expenseChart:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
