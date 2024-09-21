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
    struct State {
        @Presents var destination: Destination.State?
        var username: String = ""
        var password: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitLogin
        case handleLoginResult
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
                        
                    }
                }
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
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
            
            VStack {
                Text("Email")
                    .frame(
                        maxWidth: .infinity,
                        alignment: .init(horizontal: .leading, vertical: .center)
                    )
                TextField("Email", text: $store.username)
                    .credentials()
                    .padding(.bottom, 15)
                Text("Password")
                    .frame(
                        maxWidth: .infinity,
                        alignment: .init(horizontal: .leading, vertical: .center)
                    )
                ZStack {
                    SecureField("Password", text: $store.password)
                        .credentials()
                        .onSubmit {
                            store.send(.submitLogin)
                        }
                }
                
                Button("Login", action: {
                    store.send(.submitLogin)
                })
                Text("or")
                Button("Sign up", action: {
                    store.send(.registerButtonTapped)
                })
            }.padding()
        }
        .sheet(item: $store.scope(state: \.destination?.register, action: \.destination.register)) { store in
            RegisterView(store: store)
        }
    }
}

#Preview {
    LoginView(
        store: .init(
            initialState: .init(),
            reducer: { Login() }
        )
    )
}
