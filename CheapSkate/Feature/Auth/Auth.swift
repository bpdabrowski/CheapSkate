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
    private static let keychainKey = "TIL-API-KEY"
    private static let userIdKey = "CS-USER-ID-KEY"
    static let shared = Auth()
    
    private let authClient = AuthClient()
    
    private init() { }
    
    private(set) var token: String? {
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
    
    private(set) var userId: String? {
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
        userId = nil
    }
    
    func login(username: String, password: String) async throws {
            let login = try await authClient.login(username: username, password: password)
            self.token = login.value
            self.userId = login.user.id?.uuidString ?? "" // this should throw an error if we are unable to get a uuid here and I think we should show the registration screen.
    }
}


class AuthClient {
    static var urlComponents: URLComponents? {
        let baseURL = "localhost"
        let endpoint = "/api/users/login"
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = baseURL
        urlComponents.port = 8080
        urlComponents.path = endpoint
        return urlComponents
    }
    
    func login(username: String, password: String) async throws -> Token {
        guard let url = Self.urlComponents?.url else {
            throw APIError.requestError
        }
        
        guard let loginString = "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString()
        else {
            throw APIError.requestError
        }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        loginRequest.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.data(for: loginRequest)
        
        return try apiDecode(Token.self, from: data)
    }
}
