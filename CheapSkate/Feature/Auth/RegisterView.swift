//
//  RegisterView.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 12/29/23.
//

import SwiftUI
import ComposableArchitecture
import Firebase

@Reducer
struct Register {
    @Dependency(\.auth) var auth
    
    @ObservableState
    struct State: Equatable {
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signUpButtonTapped
        case delegate(Delegate)
    }
    
    enum Delegate {
        case registrationSuccessful(RegisterData)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .signUpButtonTapped:
                guard state.password == state.confirmPassword else {
                    return .none
                }
                
                return .run { [state] send in
                    do {
                        try await auth.createUser(state.email, state.password)
                        await send(.delegate(.registrationSuccessful(RegisterData(
                            email: state.email,
                            password: state.password,
                            confirmPassword: state.confirmPassword
                        ))))
                    } catch {
                        // error creating user
                    }
                }
            case .delegate(_):
                return .none
            case .binding:
                return .none
            }
        }
    }
}

struct RegisterView: View {
    @Bindable var store: StoreOf<Register>
    
    var body: some View {
        VStack {
            TextField("Username", text: $store.email)
                .disableAutocorrection(true)
                .textInputAutocapitalization(TextInputAutocapitalization.never)
            SecureField("Password", text: $store.password)
                .disableAutocorrection(true)
                .textInputAutocapitalization(TextInputAutocapitalization.never)
            SecureField("Confirm Password", text: $store.confirmPassword)
                .disableAutocorrection(true)
                .textInputAutocapitalization(TextInputAutocapitalization.never)
            Button("Sign up", action: {
                store.send(.signUpButtonTapped)
            })
        }
    }
}

struct RegisterData {
    let email: String
    let password: String
    let confirmPassword: String
}

#Preview {
    RegisterView(store: Store(initialState: Register.State()) {
        Register()
    })
}
