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
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                            ZStack {
                                Capsule()
                                    .frame(width: 105, height: 55)
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
                                        .font(.body)
                                })
                                .frame(width: 100, height: 50)
                                .background(
                                    viewModel.tabFillColor(
                                        cellCategory: viewStore.data.category,
                                        selectedCategory: category
                                    )
                                )
                                .clipShape(Capsule())
                            }
                        }
                    }
                }

                CurrencyTextField(
                    numberFormatter: viewModel.formatter,
                    value: viewStore.binding(\.data.$amount)
                ).frame(maxWidth: .infinity, maxHeight: 90)
                
                Button(action: {
                    viewStore.send(.submitExpense)
                }, label: {
                    if viewStore.viewState == .idle {
                        Text("Submit")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    } else if viewStore.viewState == .submitSuccessful {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.white)
                                .task {
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    viewStore.send(.resetState)
                                }
                            Text("Success")
                                .foregroundColor(.white)
                        }.frame(maxWidth: .infinity)
                    } else if viewStore.viewState == .submitInProgress {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else if viewStore.viewState == .submitError {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.white)
                                .task {
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    viewStore.send(.resetState)
                                }
                            Text("Error")
                                .foregroundColor(.white)
                        }.frame(maxWidth: .infinity)
                    }
                })
                .padding()
                .background(viewModel.submitButtonColor(viewState: viewStore.viewState))
                .disabled(viewStore.viewState != .idle)
                .clipShape(Capsule())
            }
            .padding()
        }
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
                        })
                    )
                )
            )
    }
}
