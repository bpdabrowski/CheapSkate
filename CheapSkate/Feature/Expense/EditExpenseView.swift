//
//  EditExpenseView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 11/10/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditExpense {
    @ObservableState
    struct State: Equatable {
        var expense: ExpenseData
    }

    enum Action {
        case selectCategory(ExpenseCategory)
        case amountChanged(Double)
        case cancelButtonTapped
        case saveButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case save(ExpenseData)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectCategory(category):
                state.expense.category = category
                return .none
            case let .amountChanged(amount):
                state.expense.amount = amount
                return .none
            case .cancelButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            case .saveButtonTapped:
                return .run { [expense = state.expense] send in
                    await send(.delegate(.save(expense)))
                    await dismiss()
                }
            case .delegate:
                return .none
            }
        }
    }
}

struct EditExpenseView: View {
    @Bindable var store: StoreOf<EditExpense>

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                CategoryPicker(selected: store.expense.category) { category in
                    store.send(.selectCategory(category))
                }
                CurrencyTextField(value: $store.expense.amount.sending(\.amountChanged))
                    .frame(maxHeight: 70)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle(Date(timeIntervalSince1970: store.expense.date).formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.saveButtonTapped)
                    }
                    .disabled(store.expense.amount <= 0)
                }
            }
        }
    }
}

#Preview {
    EditExpenseView(store: Store(
        initialState: .init(
            expense: ExpenseData(id: UUID(), category: .gas, amount: 42.50, date: Date().timeIntervalSince1970)
        )) {
        EditExpense()
    })
}
