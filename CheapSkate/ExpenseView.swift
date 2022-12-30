//
//  ContentView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI
import ComposableArchitecture

struct ExpenseView: View {
    @State private var amount: String = ""
    @FocusState private var amountInFocus: Bool
    let store: Store<ExpenseState, ExpenseAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: 4.0) {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                            ZStack {
                                Capsule()
                                    .frame(width: 105, height: 55)
                                    .foregroundColor(.mint)
                                Button(action: { viewStore.send(.selectCategory(category)) }, label: {
                                    Text(category.rawValue.capitalized)
                                        .foregroundColor(.black)
                                        .font(.body)
                                })
                                .frame(width: 100, height: 50)
                                .background(.white)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                HStack {
                    Text("$")
                        .font(.system(size: 75))
                    TextField("0.00", text: $amount)
                        .font(.system(size: 75))
                        .focused($amountInFocus)
                        .tint(.black)
                        .keyboardType(.decimalPad)
                }
                
                Button(action: { viewStore.send(.submitAmount(amount)) }, label: {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                })
                .padding()
                .background(.mint)
                .clipShape(Capsule())
                
            }
            .padding()
            .onAppear {
                self.amountInFocus = true
            }
        }
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView(store:
            Store(
                initialState: ExpenseState(),
                reducer: expenseReducer,
                environment: .live(
                    environment: ExpenseEnvironment(
                        putExpenseRequest: { _ in
                            putExpenseEffect(state: ExpenseState())
                        })
                    )
                )
            )
    }
}
