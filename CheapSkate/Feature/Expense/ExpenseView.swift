//
//  ContentView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI
import ComposableArchitecture

struct ExpenseView: View {
    let store: StoreOf<Expense>
    let viewModel = ExpenseViewModel()
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    VStack(alignment: .center, spacing: 4.0) {
                        HStack {
                            ZStack {
                                Image("roller-skate")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 34, height: 34)
                                    .frame(maxWidth: .infinity)
                                Button(action: { viewStore.send(.logoutButtonTapped) }) {
                                  Image(systemName: "rectangle.portrait.and.arrow.right")
                                }.frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }.padding(.bottom, 10)

                        ExpenseChartView(store: store)
                        
                        Spacer()
                        VStack {
                            categorySelector(viewStore: viewStore)
                            HStack {
                                CurrencyTextField(
                                    numberFormatter: viewModel.formatter,
                                    value: viewStore.binding(get: \.data.amount, send: Expense.Action.amountChanged)
                                )
                                .frame(maxHeight: 50)
                                .truncationMode(.tail)
                                
                                submitButton(viewStore: viewStore)
                            }
                        }
                    }
                    .padding()
                }
            }.onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private func categorySelector(viewStore: ViewStoreOf<Expense>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                    ZStack {
                        Capsule()
                            .frame(width: 105, height: 35)
                            .foregroundColor(category.color)
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
    
    private func submitButton(viewStore: ViewStoreOf<Expense>) -> some View {
        Button(action: {
            viewStore.send(.submitExpense)
        }, label: {
            if viewStore.viewState == .idle {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
            } else if viewStore.viewState == .submitSuccessful {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        viewStore.send(.resetState)
                    }
            } else if viewStore.viewState == .submitInProgress {
                ProgressView()
                    .tint(.white)
            } else if viewStore.viewState == .submitError {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.white)
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        viewStore.send(.resetState)
                    }
            }
        })
        .padding()
        .background(viewModel.submitButtonColor(viewState: viewStore.viewState))
        .disabled(viewStore.viewState != .idle)
        .clipShape(Capsule())
    }
}
