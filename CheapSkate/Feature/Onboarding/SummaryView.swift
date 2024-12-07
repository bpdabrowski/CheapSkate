//
//  SummaryView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/7/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Summary {
    @ObservableState
    struct State: Equatable {
        @Shared var signUpData: SignUpData
    }
    
    enum Action {
        case delegate(Delegate)
        case backButtonTapped
        
        enum Delegate {
            case nextButtonTapped
            case skipTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in
                    @Dependency(\.dismiss) var dismiss
                    await dismiss()
                }
            case .delegate:
                return .none
            }
        }
    }
}

struct SummaryView: View {
    @Bindable var store: StoreOf<Summary>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            VStack {
                Text("SummaryView")
                Spacer()
                OnboardingNavigationButtons(nextAction: {
                    store.send(.delegate(.nextButtonTapped))
                })
            }
            .safeAreaPadding(20)
    }
}

#Preview("Summary") {
    SummaryView(
        store: .init(
            initialState: .init(signUpData: Shared(SignUpData())),
            reducer: { Summary() }
        )
    )
}
