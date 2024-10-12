//
//  RegisterReducerTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 10/12/24.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import CheapSkate

@MainActor
struct RegisterReducerTests {
    
    @Test("Invalid email")
    func signupButtonTapped_invalidEmail() async throws {
        let testStore = TestStore(
            initialState: Register.State(email: "test.com"),
            reducer: { Register() }
        )
        
        await testStore.send(.signUpButtonTapped) {
            $0.registrationError = [.invalidEmail]
        }
    }
    
    @Test("Invalid password")
    func signupButtonTapped_passwordNotMatching() async throws {
        let testStore = TestStore(
            initialState: Register.State(email: "test@test.com", password: "test1234!", confirmPassword: "test1234!@"),
            reducer: { Register() }
        )
        
        await testStore.send(.signUpButtonTapped) {
            $0.registrationError = [.passwordsNotMatching]
        }
    }
    
    @Test("Password to short")
    func signupButtonTapped_invalidPassword() async throws {
        let testStore = TestStore(
            initialState: Register.State(email: "test@test.com", password: "test", confirmPassword: "test"),
            reducer: { Register() }
        )
        
        await testStore.send(.signUpButtonTapped) {
            $0.registrationError = [.passwordTooShort]
        }
    }
    
    @Test("No special character")
    func signupButtonTapped_noSpecialCharacter() async throws {
        let testStore = TestStore(
            initialState: Register.State(email: "test@test.com", password: "test1234", confirmPassword: "test1234"),
            reducer: { Register() }
        )
        testStore.dependencies.auth.createUser = { _,_ in throw NSError() }
        
        await testStore.send(.signUpButtonTapped) {
            $0.registrationError = [.specialCharacter]
        }
    }
    
    @Test("Registration unsuccessful")
    func signupButtonTapped_registrationUnsuccessful() async throws {
        let testStore = TestStore(
            initialState: Register.State(email: "test@test.com", password: "test1234$", confirmPassword: "test1234$"),
            reducer: { Register() }
        )
        testStore.dependencies.auth.createUser = { _,_ in throw NSError() }
        
        await testStore.send(.signUpButtonTapped)
        await testStore.receive(\.registrationUnsuccessful) {
            $0.registrationError = [.serverError]
        }
    }
}
