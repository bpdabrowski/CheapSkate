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
    private let store: StoreOf<Login>
    
    init(store: StoreOf<Login>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                
                VStack {
                    TextField("Username", text: $username)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(TextInputAutocapitalization.never)
                    SecureField("Password", text: $password)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(TextInputAutocapitalization.never)
                    Button("Login", action: {
                        viewStore.send(.submitLogin(username, password))
                    })
                }.padding()
            }
        }
    }
}
