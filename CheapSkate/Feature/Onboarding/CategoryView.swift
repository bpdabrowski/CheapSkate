//
//  CategoryView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/7/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Category {
    @ObservableState
    struct State: Equatable {
        @Shared var signUpData: SignUpData
    }
    
    enum Action {
        case delegate(Delegate)
        case backTapped
        
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
            case .delegate:
                return .none
            }
        }
    }
}

struct CategoryView: View {
    @Bindable var store: StoreOf<Category>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            VStack {
                Text("CategoryView")
                Spacer()
                OnboardingNavigationButtons(nextAction: {
                    store.send(.delegate(.nextButtonTapped))
                })
            }
            .safeAreaPadding(20)
    }
}

#Preview("Category") {
    CategoryView(
        store: .init(
            initialState: .init(signUpData: Shared(SignUpData())),
            reducer: { Category() }
        )
    )
}
