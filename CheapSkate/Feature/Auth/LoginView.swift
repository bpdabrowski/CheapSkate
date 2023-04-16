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
    @ObservedObject private var viewStore: ViewStore<Void, Login.Action>
    
    init(store: StoreOf<Login>) {
        self.store = store
        self.viewStore = ViewStore(self.store.stateless)
    }
    
    var body: some View {
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
