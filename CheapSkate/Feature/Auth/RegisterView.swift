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
    struct State: Equatable { }
    
    enum Action {
        case signUpButtonTapped(RegisterData)
        case delegate(Delegate)
    }
    
    enum Delegate {
        case registrationSuccessful(RegisterData)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signUpButtonTapped(let registerData):
                guard registerData.password == registerData.confirmPassword else {
                    return .none
                }
                
                return .run { send in
                    do {
                        try await auth.createUser(registerData.email, registerData.password)
                        await send(.delegate(.registrationSuccessful(registerData)))
                    } catch {
                        // error creating user
                    }
                }
            case .delegate(_):
                return .none
            }
        }
    }
}

struct RegisterView: View {
    // TODO: See if we can use TCA bindings for these instead of state.
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    private let store: StoreOf<Register>
    
    init(store: StoreOf<Register>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TextField("Username", text: $email)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(TextInputAutocapitalization.never)
                SecureField("Password", text: $password)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(TextInputAutocapitalization.never)
                SecureField("Confirm Password", text: $confirmPassword)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(TextInputAutocapitalization.never)
                Button("Sign up", action: {
                    viewStore.send(
                        .signUpButtonTapped(
                            RegisterData(
                                email: email,
                                password: password,
                                confirmPassword: confirmPassword
                            )
                        )
                    )
                })
            }
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
