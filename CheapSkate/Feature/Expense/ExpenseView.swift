//
//  ContentView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI
import ComposableArchitecture

struct ExpenseView: View {
    let store: Store<ExpenseState, ExpenseAction>
    let viewModel = ExpenseViewModel()
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: 4.0) {
                ExpenseChartView(store: store)
                    .onAppear {
                        viewStore.send(.getExpenses)
                    }

                Spacer()
                VStack {
                    categorySelector(viewStore: viewStore)
                    HStack {
                        CurrencyTextField(
                            numberFormatter: viewModel.formatter,
                            value: viewStore.binding(\.data.$amount)
                        )
                        .frame(maxHeight: 50)
                        .truncationMode(.tail)
                        submitButton(viewStore: viewStore)
                    }
                }
            }
            .padding()
        }
    }
    
    private func categorySelector(viewStore: ViewStore<ExpenseState, ExpenseAction>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                    ZStack {
                        Capsule()
                            .frame(width: 105, height: 35)
                            .foregroundColor(.mint)
                        Button(action: {
                            viewStore.send(.selectCategory(category))
                        }, label: {
                            Text(category.rawValue.capitalized)
                                .foregroundColor(
                                    viewModel.tabTextColor(
                                        cellCategory: viewStore.data.category,
                                        selectedCategory: category
                                    )
                                )
                                .font(.caption)
                        })
                        .frame(width: 100, height: 30)
                        .background(
                            viewModel.tabFillColor(
                                cellCategory: viewStore.data.category,
                                selectedCategory: category
                            )
                        )
                        .clipShape(Capsule())
                    }
                }
            }.padding(.bottom, 10)
        }
    }
    
    private func submitButton(viewStore: ViewStore<ExpenseState, ExpenseAction>) -> some View {
        Button(action: {
            viewStore.send(.submitExpense)
        }, label: {
            if viewStore.viewState == .idle {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
            } else if viewStore.viewState == .submitSuccessful {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.white)
                        .task {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            viewStore.send(.resetState)
                        }
                }
            } else if viewStore.viewState == .submitInProgress {
                ProgressView()
                    .tint(.white)
            } else if viewStore.viewState == .submitError {
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.white)
                        .task {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            viewStore.send(.resetState)
                        }
                }
            }
        })
        .padding()
        .background(viewModel.submitButtonColor(viewState: viewStore.viewState))
        .disabled(viewStore.viewState != .idle)
        .clipShape(Capsule())
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(store:
            Store(
                initialState: ExpenseState(),
                reducer: expenseReducer,
                environment: .live(
                    environment: ExpenseEnvironment(
                            saveExpense: { _ in
                                ExpenseRepository().saveExpense(state: ExpenseState().data)
                            },
                            getExpenses: { _ in
                                ExpenseRepository().getExpenses(for: 12)
                            }
                        )
                    )
                )
            )
    }
}
