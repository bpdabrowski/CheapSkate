//
//  LoginView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 2/11/23.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    @State private var username: String = "admin"
    @State private var password: String = ""
    var expenseStore: Store<ExpenseState, ExpenseAction>
    
    var body: some View {
        WithViewStore(expenseStore) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                
                VStack {
                    TextField("Username: ", text: $username)
                    SecureField("Password: ", text: $password)
                    Button("Login", action: {
                        viewStore.send(.submitLogin(username, password))
                    })
                }.padding()
            }
        }
    }
}
