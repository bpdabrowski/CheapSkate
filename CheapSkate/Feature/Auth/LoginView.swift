//
//  LoginView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 2/11/23.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    var expenseStore: StoreOf<ExpenseFeature>
    
    var body: some View {
        WithViewStore(expenseStore) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                
                VStack {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(TextInputAutocapitalization.never)
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(TextInputAutocapitalization.never)
                    Button("Login", action: {
                        viewStore.send(.submitLogin(username, password))
                    })
                }.padding()
            }
        }
    }
}
