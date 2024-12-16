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
        var categories: [ExpenseCategory] = ExpenseCategory.allCases.sorted(by: { $0.rawValue < $1.rawValue })
    }
    
    enum Action {
        case delegate(Delegate)
        case backTapped
        case cellTapped(ExpenseCategory)
        
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
            case let .cellTapped(category):
                state.signUpData.categories.append(category)
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

struct CategoryView: View {
    @Bindable var store: StoreOf<Category>
    @Environment(\.dismiss) var dismiss
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 110))
    ]
    
    var body: some View {
            VStack {
                LargeHeader(text: "Categorize Your Spending")
                SubHeader(text: "Select the categories that you would like to track.")
                    .padding(.bottom, 20)
                LazyVGrid(columns: adaptiveColumn, spacing: 20) {
                    ForEach(store.categories, id: \.self) { category in
                        CategoryCell(title: category.rawValue, color: category.color, action: {
                            store.send(.cellTapped(category))
                        })
                    }
                }
                Spacer()
                OnboardingNavigationButtons(nextAction: {
                    store.send(.delegate(.nextTapped))
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
