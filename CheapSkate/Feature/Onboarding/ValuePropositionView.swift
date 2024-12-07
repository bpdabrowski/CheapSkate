//
//  ValuePropositionView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/21/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct ValueProposition {
    @ObservableState
    struct State: Equatable {
        @Shared var signUpData: SignUpData
    }
    
    enum Action {
        case delegate(Delegate)
        
        enum Delegate {
            case nextButtonTapped
            case skipTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }
}

struct ValuePropositionView: View {
    @Bindable var store: StoreOf<ValueProposition>
    
    var body: some View {
            VStack {
                Text("ValuePropositionView")
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        store.send(.delegate(.nextButtonTapped))
                    }, label: {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    })
                    .padding()
                    .background(Color.mint)
                    .clipShape(Circle())
                }
            }
            .safeAreaPadding(20)
    }
}

#Preview("Value Proposition") {
    ValuePropositionView(
        store: .init(initialState: .init(signUpData: Shared(SignUpData())), reducer: { ValueProposition() })
    )
}

struct OnboardingNavigationButtons: View {
    @Environment(\.dismiss) var dismiss
    var nextAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.mint)
            })
            .padding()
            .background(Color.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.mint, lineWidth: 2)
            )

            Spacer()
            
            Button(action: {
                nextAction()
            }, label: {
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            })
            .padding()
            .background(Color.mint)
            .clipShape(Circle())
        }
    }
}
