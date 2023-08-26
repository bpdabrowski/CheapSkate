//
//  LoginFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 4/15/23.
//

import ComposableArchitecture
import Foundation

struct Login: Reducer {
    struct State: Equatable { }
    
    enum Action {
        case submitLogin(String, String)
        case handleLoginResult
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .submitLogin(let username, let password):
            return .run { send in
                try await Auth.shared.login(username: username, password: password)
                await send(.handleLoginResult)
            }
        case .handleLoginResult:
            if Auth.shared.token == nil {
                // put error up on the login view
                return .none
            }
            return .none
        }
    }
}
