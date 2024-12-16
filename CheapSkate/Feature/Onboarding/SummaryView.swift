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
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 110))
    ]
    
    var body: some View {
            VStack {
                LargeHeader(text: "Lets get trackin' 🙌")
                SubHeader(text: "Below is your budgetting goal and categories.")
                Text("Budget Goal")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                Text(store.state.signUpData.budgetGoal.currency)
                    .budgetStyle()
                Text("Selected Categories")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                LazyVGrid(columns: adaptiveColumn, spacing: 20) {
                    ForEach(store.state.signUpData.categories, id: \.self) { category in
                        CategoryCell(title: category.rawValue, color: category.color, selected: true)
                        .disabled(true)
                    }
                }
                Spacer()
                Button {
                    store.send(.delegate(.completeTapped))
                } label: {
                    Text("Start Tracking")
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
            initialState: .init(signUpData: Shared(SignUpData(categories: ExpenseCategory.allCases.sorted(by: { $0.rawValue < $1.rawValue })))),
            reducer: { Summary() }
        )
    )
}
