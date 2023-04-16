//
//  Auth.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 2/11/23.
//

import Foundation
import UIKit
import ComposableArchitecture

enum AuthResult {
  case success
  case failure
}

class Auth {
    static let keychainKey = "TIL-API-KEY"
    static let userIdKey = "CS-USER-ID-KEY"
    
    var token: String? {
        get {
            Keychain.load(key: Auth.keychainKey)
        }
        set {
            if let newToken = newValue {
                Keychain.save(key: Auth.keychainKey, data: newToken)
            } else {
                Keychain.delete(key: Auth.keychainKey)
            }
        }
    }
    
    static var userId: String? {
        get {
            UserDefaults.standard.string(forKey: Auth.userIdKey)
        }
        set {
            if let newUserId = newValue {
                UserDefaults.standard.set(newUserId, forKey: Auth.userIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Auth.userIdKey)
            }
        }
    }
    
    func logout() {
        token = nil
        Self.userId = nil
    }
    
    func login(username: String, password: String) -> Effect<AuthResult, APIError> {
        let path = "http://localhost:8080/api/users/login"
        guard let url = URL(string: path) else {
            fatalError("Failed to convert URL")
        }
        guard
            let loginString = "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString()
        else {
            fatalError("Failed to encode credentials")
        }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        loginRequest.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: loginRequest)
            .map(\.data)
            .decode(type: Token.self, decoder: JSONDecoder())
            .map {
                self.token = $0.value // maybe should move this into its own auth state and have a separate reducer or something.
                Self.userId = $0.user.id?.uuidString ?? "" // this should throw an error if we are unable to get a uuid here and I think we should show the registration screen.
                return AuthResult.success
            }
            .mapError { _ in APIError.requestError }
            .eraseToEffect()
    }
}
