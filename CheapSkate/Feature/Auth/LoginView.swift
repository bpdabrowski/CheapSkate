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
    
    @Reducer
    enum Destination {
        case register(Register)
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var username: String = ""
        var password: String = ""
        var loginError: Bool = false
        var loginAttempts: CGFloat = 0
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitLogin
        case handleLoginResult
        case handleLoginError
        case destination(PresentationAction<Destination.Action>)
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
                        await send(.handleLoginError)
                    }
                }
            case .handleLoginError:
                state.loginError = true
                state.loginAttempts += 1
                return .none
            case .handleLoginResult:
                return .none
            case .registerButtonTapped:
                state.destination = .register(.init())
                return .none
            case .destination(.presented(.register(.delegate(.registrationSuccessful(let registerData))))):
                state.username = registerData.email
                state.password = registerData.password
                return .send(.submitLogin)
            case .binding:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct LoginView: View {
    @Bindable var store: StoreOf<Login>
    @FocusState private var focusedField: Bool?
    
    var body: some View {
        VStack {
            LargeHeader(text: "Sign into your account")
            SubHeader(text: "Login now to keep budgeting")
            
            CredentialField(labelText: "Email", text: $store.username)
                .focused($focusedField, equals: true)
            
            CredentialField(labelText: "Password", text: $store.password, isSecure: true)
                .onSubmit {
                    store.send(.submitLogin)
                }
            
            AuthErrorView(text: "Username or Password is incorrect")
                .opacity(store.loginError ? 1 : 0)
                .modifier(Shake(animatableData: store.loginAttempts))
                .animation(.default, value: store.loginAttempts)

            Button {
                store.send(.submitLogin)
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity, maxHeight: 20)
            }
            .buttonStyle(FullWidth())
            .sensoryFeedback(.error, trigger: store.loginAttempts)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                Button("Register here", action: {
                    store.send(.registerButtonTapped)
                })
                .foregroundColor(.black)
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            focusedField = true
        }
        .padding()
        .fullScreenCover(item: $store.scope(state: \.destination?.register, action: \.destination.register)) { store in
            RegisterView(store: store)
        }
    }
}

extension Login.Destination.State: Equatable {}

#Preview {
    LoginView(
        store: .init(
            initialState: .init(),
            reducer: { Login() }
        )
    )
}
