//
//  SignUpFlow.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/26/24.
//

import ComposableArchitecture
import SwiftUI

struct SignUpData: Equatable {
    var categories: [ExpenseCategory] = []
    var budgetGoal: Int = 5_000
}

@Reducer
struct Onboarding {
    @Reducer
    enum Path {
        case budget(Budget)
        case category(Category)
        case summary(Summary)
    }

    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var valueProposition: ValueProposition.State = .init(signUpData: Shared(SignUpData()))
        @Shared var signUpData: SignUpData
    }

    enum Action {
        case valueProposition(ValueProposition.Action)
        case path(StackActionOf<Path>)
        case delegate(Delegate)
        
        enum Delegate {
            case skipTapped
            case completeTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .path(.element(id: _, action: delegateAction)):
                switch delegateAction {
                case .budget(.delegate(let budgetDelegate)):
                    switch budgetDelegate {
                    case .skipTapped:
                        return .send(.delegate(.skipTapped))
                    case .nextTapped:
                        state.path.append(.category(.init(signUpData: state.$signUpData)))
                    }
                case .category(.delegate(let categoryDelegate)):
                    switch categoryDelegate {
                    case .skipTapped:
                        return .send(.delegate(.skipTapped))
                    case .nextTapped:
                        state.path.append(.summary(.init(signUpData: state.$signUpData)))
                    }
                case .summary(.delegate(let summaryDelegate)):
                    switch summaryDelegate {
                    case .completeTapped:
                        return .send(.delegate(.completeTapped))
                    }
                case .budget,
                    .category,
                    .summary:
                    return .none
                }
                return .none
            case .valueProposition(.delegate(.nextTapped)):
                state.path.append(.budget(.init(signUpData: state.$signUpData)))
                return .none
            case .valueProposition,
                .path,
                .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

struct OnboardingFlow: View {
    @Bindable var store: StoreOf<Onboarding>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            ValuePropositionView(store: store.scope(state: \.valueProposition, action: \.valueProposition))
                .padding(.top, 40)
        } destination: { store in
            switch store.case {
            case .budget(let store):
                BudgetView(store: store)
                    .onboardingNavBar(action: { store.send(.delegate(.skipTapped)) })
            case .category(let store):
                CategoryView(store: store)
                    .onboardingNavBar(action: { store.send(.delegate(.skipTapped)) })
            case .summary(let store):
                SummaryView(store: store)
                    .navigationBarBackButtonHidden(true)
                    .padding(.top, 40)
            }
        }
    }
}

extension View {
    public func onboardingNavBar(action: @escaping () -> Void) -> some View {
        modifier(OnboardingNavBarViewModifier(action: action))
    }
}

struct OnboardingNavBarViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        action()
                    } label: {
                        Text("Skip")
                            .padding(10)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.gray)
                                    .opacity(0.2)
                            )
                    }
                }
            }
    }
}

#Preview {
    OnboardingFlow(
        store: Store(
            initialState: Onboarding.State(signUpData: Shared(SignUpData())),
            reducer: { Onboarding() }
        )
    )
}
