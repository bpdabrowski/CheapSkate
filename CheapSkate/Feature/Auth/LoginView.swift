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
    @State private var password: String = "" // see if we can put these in viewState below.
    let store: StoreOf<Login>
    @ObservedObject var viewStore: ViewStore<ViewState, Login.Action>
    
    struct ViewState: Equatable {
        init(state: Login.State) { }
    }
    
    init(store: StoreOf<Login>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
    }
    
    var body: some View {
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
