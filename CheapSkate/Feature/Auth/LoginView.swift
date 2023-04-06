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
    @ObservedObject private var viewModel: LoginViewModel = LoginViewModel()
    var expenseStore: Store<ExpenseState, ExpenseAction>
    
    var body: some View {
        if viewModel.loginSuccess {
            ExpenseView(store: expenseStore)
        } else {
            VStack {
                TextField("Username: ", text: $username)
                SecureField("Password: ", text: $password)
                
                Button("Login", action: {
                    viewModel.login(username: username, password: password)
                })
            }.padding()
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var loginSuccess = false
    
    func login(username: String, password: String) {
        Auth().login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loginSuccess = true
                case .failure:
                    self?.loginSuccess = false
      //                    let message = "Could not login. Check your credentials and try again"
      //                    ErrorPresenter.showError(message: message, on: self)
                }
            }
        }
    }
}
