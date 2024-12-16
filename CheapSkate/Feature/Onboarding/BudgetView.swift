//
//  BudgetView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/7/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Budget {
    
    @Reducer
    enum Destination {
        case budgetPicker(Budget)
    }
    
    @ObservableState
    struct State {
        @Shared var signUpData: SignUpData
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case delegate(Delegate)
        case backTapped
        case destination(PresentationAction<Destination.Action>)
        case budgetPickerTapped
        case budgetAmountSelected(Int)
        
        enum Delegate {
            case nextTapped
            case skipTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backTapped:
                return .run { _ in
                    @Dependency(\.dismiss) var dismiss
                    await dismiss()
                }
            case .budgetPickerTapped:
                state.destination = .budgetPicker(state)
                return .none
            case let .budgetAmountSelected(amount):
                state.signUpData.budgetGoal = amount
                return .none
            case .delegate,
                .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct BudgetView: View {
    @Bindable var store: StoreOf<Budget>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            VStack {
                LargeHeader(text: "Hit Your Budgeting Goals")
                SubHeader(text: "Enter the maximum amount you would like to spend each month.")
                    .padding(.bottom, 20)
                Button {
                    store.send(.budgetPickerTapped)
                } label: {
                    Text(String(store.state.signUpData.budgetGoal.currency))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .padding(20)
                        .font(.system(size: 52))
                        .foregroundStyle(.gray)
                }
                .buttonStyle(BudgetSelectorButtonStyle())
                Spacer()
                OnboardingNavigationButtons(nextAction: {
                    store.send(.delegate(.nextTapped))
                })
            }
            .safeAreaPadding(20)
            .sheet(
                item: $store.scope(
                    state: \.destination?.budgetPicker,
                    action: \.destination.budgetPicker
                )
            ) { store in
                BudgetSelectorView(store: store)
                    .presentationDetents([.fraction(0.20)])
            }
    }
}

#Preview("Budget") {
    BudgetView(
        store: .init(initialState: .init(signUpData: Shared(SignUpData())), reducer: { Budget() })
    )
}

struct BudgetSelectorView: View {
    @State public var selectedAmount: Int = 0
    @Bindable var store: StoreOf<Budget>
    
    var body: some View {
        Picker("Budget Amount", selection: $selectedAmount) {
            ForEach(0...25_000, id: \.self) { amount in
                if amount % 500 == 0 {
                    Text(amount.currency)
                }
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: selectedAmount) { _, newValue in
            store.send(.budgetAmountSelected(newValue))
        }
    }
}

struct BudgetSelectorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.gray)
                    .opacity(0.2)
            )
            .foregroundColor(.white)
    }
}
