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
            case nextTapped
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
                LargeHeader(text: "Welcome to CheapSkate!")
                SubHeader(text: "The fastest and most accurate way to track your expenses.")
                valueItem(
                    title: "Fast & Easy Tracking",
                    description: "Quick entry expense logging, we’ve got you covered.",
                    image: Image(systemName: "gauge.with.dots.needle.100percent"),
                    imageColor: .purple
                )
                .padding(.top, 20)
                valueItem(
                    title: "Accurate Historical Data",
                    description: "View all of your historical expenses in one place.",
                    image: Image(systemName: "checkmark.seal"),
                    imageColor: .green
                )
                valueItem(
                    title: "Spending Metrics",
                    description: "Understand your expenses on a deeper level.",
                    image: Image(systemName: "chart.bar"),
                    imageColor: .orange
                )
                Spacer()
                HStack {
                    Spacer()

                    Button {
                        store.send(.delegate(.nextTapped))
                    } label: {
                        Text("Sign up with Apple")
                            .frame(maxWidth: .infinity, maxHeight: 20)
                    }
                    .buttonStyle(FullWidth())
                }
            }
            .safeAreaPadding(20)
    }
    
    private func valueItem(title: String, description: String, image: Image, imageColor: Color) -> some View {
        HStack(alignment: .top) {
            image
                .font(.title)
                .foregroundStyle(imageColor)
            VStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SubHeader(text: description)
            }
        }
        .padding(.bottom, 10)
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
