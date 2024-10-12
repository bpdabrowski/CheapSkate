//
//  LoginReducerTests.swift
//  CheapSkateTests
//
//  Created by Brendyn Dabrowski on 10/12/24.
//

import Testing
import ComposableArchitecture
@testable import CheapSkate
import Foundation

@MainActor
struct LoginReducerTests {
    let testStore = TestStore(initialState: .init()) { Login() }
    
    @Test func authError() async throws {
        testStore.dependencies.auth.signIn = { _,_ in throw NSError() }
        await testStore.send(.submitLogin)
        await testStore.receive(\.handleLoginError) {
            $0.loginError = true
            $0.loginAttempts = 1
        }
    }
 }
