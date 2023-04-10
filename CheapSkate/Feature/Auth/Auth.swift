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

  func logout() {
    token = nil
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
                return AuthResult.success
            }
            .mapError { _ in APIError.requestError }
            .eraseToEffect()
    }
}
