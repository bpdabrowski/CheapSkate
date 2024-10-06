//
//  RegisterView.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 12/29/23.
//

import SwiftUI
import ComposableArchitecture
import Firebase
import RegexBuilder

@Reducer
struct Register {
    @Dependency(\.auth) var auth
    
    struct RegisterData {
        let email: String
        let password: String
        let confirmPassword: String
    }
    
    @ObservableState
    struct State: Equatable {
        var email: String = ""
        var password: String = ""
        var confirmPassword: String = ""
        fileprivate var registrationError: [RegistrationError]?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signUpButtonTapped
        case delegate(Delegate)
        case registrationUnsuccessful
    }
    
    enum Delegate {
        case registrationSuccessful(RegisterData)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .signUpButtonTapped:
                guard valid(email: state.email) else {
                    state.registrationError = [.invalidEmail]
                    return .none
                }
                
                if let registrationErrors = invalid(password: state.password) {
                    state.registrationError = registrationErrors
                    return .none
                }
                
                guard state.password == state.confirmPassword else {
                    state.registrationError = [.passwordsNotMatching]
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
                        await send(.registrationUnsuccessful)
                    }
                }
            case .registrationUnsuccessful:
                state.registrationError = [.serverError]
                return .none
            case .delegate(_):
                return .none
            case .binding:
                return .none
            }
        }
    }
    
    private func valid(email: String) -> Bool {
        let word = OneOrMore(.word)
        let emailPattern = Regex {
            ZeroOrMore {
                word
                "."
            }
            word
            "@"
            word
            OneOrMore {
                "."
                word
            }
        }
        
        do {
            return try emailPattern.firstMatch(in: email) != nil
        } catch {
            return false
        }
    }
    
    private func invalid(password: String) -> [RegistrationError]? {
        var registrationErrors: [RegistrationError]?
        // Ensure string has one special case letter.
        let specialCharacter = Regex {
            Lookahead {
                Regex {
                    One(CharacterClass.anyOf("!@#$&*").inverted)
                }
            }
        }
        
        if password.count < 8 {
            registrationErrors?.append(.passwordTooShort)
        } else if let _ = try? specialCharacter.firstMatch(in: password) {
            registrationErrors?.append(.specialCharacter)
        }
        return registrationErrors
    }
}

struct RegisterView: View {
    @Bindable var store: StoreOf<Register>
    @FocusState private var focusedField: Bool?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            LargeHeader(text: "Get Started")
            SubHeader(text: "Register now to start your budgeting journey.")
            
            CredentialField(labelText: "Email", text: $store.email)
                .focused($focusedField, equals: true)
            CredentialField(labelText: "Password", text: $store.password, isSecure: true)
            CredentialField(labelText: "Confirm Password", text: $store.confirmPassword, isSecure: true)
            
            ForEach(store.registrationError ?? []) { error in
                AuthErrorView(text: error.text)
                    .opacity(store.registrationError != nil ? 1 : 0)
            }.padding(.bottom, 5)
            
            Button {
                store.send(.signUpButtonTapped)
            } label: {
                Text("Register")
                    .frame(maxWidth: .infinity, maxHeight: 20)
            }
            .buttonStyle(FullWidth())
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                Button("Login here", action: {
                    dismiss()
                })
                .foregroundColor(.black)
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            focusedField = true
        }
        .padding()
    }
}

#Preview {
    RegisterView(store: Store(initialState: Register.State()) {
        Register()
    })
}

fileprivate enum RegistrationError: Error, Identifiable {
    var id: UUID { UUID() }
    
    case passwordsNotMatching
    case invalidEmail
    case serverError
    case passwordTooShort
    case specialCharacter
    
    var text: String {
        return switch self {
        case .passwordsNotMatching:
            "Passwords must match."
        case .invalidEmail:
            "Email is invalid."
        case .serverError:
            "Registration failed."
        case .passwordTooShort:
            "Password must be at least 8 characters long."
        case .specialCharacter:
            "Password must contain at least one special character."
        }
    }
}
