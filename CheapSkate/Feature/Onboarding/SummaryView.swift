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
        case backTapped
        
        enum Delegate {
            case completeTapped
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

struct SummaryView: View {
    @Bindable var store: StoreOf<Summary>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            VStack {
                Text("SummaryView")
                Spacer()
                Button {
                    store.send(.delegate(.completeTapped))
                } label: {
                    Text("Let's Go!")
                        .frame(maxWidth: .infinity, maxHeight: 20)
                }
                .buttonStyle(FullWidth())
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
