//
//  LoginFeature.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 4/15/23.
//

import ComposableArchitecture
import Foundation

struct Login: ReducerProtocol {
    struct State { }
    
    enum Action {
        case submitLogin(String, String)
        case handleLoginResult(Result<AuthResult, APIError>)
        case showLogoutView
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .submitLogin(let username, let password):
            return Auth.shared.login(username: username, password: password)
                .receive(on: mainQueue)
                .catchToEffect()
                .map(Login.Action.handleLoginResult)
        case .handleLoginResult(let result):
            if case .failure = result {
                // put error up on the login view
                return .none
            }
            return .none
        case .showLogoutView:
            Auth.shared.logout()
            return .none
        }
    }
}
