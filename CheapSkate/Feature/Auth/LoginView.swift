//
//  LoginView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 2/11/23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Login {
    @ObservableState
    struct State: Equatable {
        @Presents var register: Register.State?
        var username: String = ""
        var password: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitLogin
        case handleLoginResult
        case register(PresentationAction<Register.Action>)
        case registerButtonTapped
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.requestManager) var requestManager
    @Dependency(\.auth) var auth
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .submitLogin:
                return .run { [state] send in
                    do {
                        try await auth.signIn(state.username, state.password)
                        await send(.handleLoginResult)
                    } catch {
                        
                    }
                }
            case .handleLoginResult:
                return .none
            case .registerButtonTapped:
                state.register = Register.State()
                return .none
            case .register(.presented(.delegate(.registrationSuccessful(let registerData)))):
                state.username = registerData.email
                state.password = registerData.password
                return .send(.submitLogin)
            case .register(_):
                return .none
            case .binding:
                return .none
            }
        }.ifLet(\.$register, action: \.register) {
            Register()
        }
    }
}

struct LoginView: View {
    @Bindable var store: StoreOf<Login>
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
            
            VStack {
                TextField("Username", text: $store.username)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(TextInputAutocapitalization.never)
                SecureField("Password", text: $store.password)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(TextInputAutocapitalization.never)
                Button("Login", action: {
                    store.send(.submitLogin)
                })
                Text("or")
                Button("Sign up", action: {
                    store.send(.registerButtonTapped)
                })
            }.padding()
        }
        .sheet(item: $store.scope(state: \.register, action: \.register)) { store in
            RegisterView(store: store)
        }
    }
}
