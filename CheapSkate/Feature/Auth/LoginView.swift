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
    struct State: Equatable { 
        @PresentationState var register: Register.State?
    }
    
    enum Action {
        case submitLogin(String, String)
        case handleLoginResult
        case register(PresentationAction<Register.Action>)
        case registerButtonTapped
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.requestManager) var requestManager
    @Dependency(\.auth) var auth
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .submitLogin(let email, let password):
                return .run { send in
                    do {
                        try await auth.signIn(email, password)
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
                return .send(.submitLogin(registerData.email, registerData.password))
            case .register(_):
                return .none
            }
        }.ifLet(\.$register, action: \.register) {
            Register()
        }
    }
}

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
                    Text("or")
                    Button("Sign up", action: {
                        viewStore.send(.registerButtonTapped)
                    })
                }.padding()
            }
        }
        .sheet(store: self.store.scope(state: \.$register, action: { .register($0) })) { store in
            RegisterView(store: store)
        }
    }
}
