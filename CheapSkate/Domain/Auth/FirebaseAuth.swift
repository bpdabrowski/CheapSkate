//
//  FirebaseAuth.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 6/29/24.
//

import Dependencies
import Foundation
import Firebase

struct FirebaseAuthentication {
    var createUser: (String, String) async throws -> Void
    var signIn: (String, String) async throws -> Void
    var currentUser: () -> FirebaseAuth.User?
    var signOut: () -> Void
}

extension FirebaseAuthentication: DependencyKey {
    static var liveValue: FirebaseAuthentication {
        FirebaseAuthentication(
            createUser: { email, password in
                try await Auth.auth().createUser(withEmail: email, password: password)
            },
            signIn: { email, password in
                try await Auth.auth().signIn(withEmail: email, password: password)
            },
            currentUser: {
                Auth.auth().currentUser
            },
            signOut: {
                try? Auth.auth().signOut()
                Database.database().reference().removeAllObservers()
            }
        )
    }
    
    static var testValue: FirebaseAuthentication {
        FirebaseAuthentication(
            createUser: { _, _ in unimplemented() },
            signIn: { _, _ in unimplemented() },
            currentUser: { unimplemented() },
            signOut: { unimplemented() }
        )
    }
}

extension DependencyValues {
    var auth: FirebaseAuthentication {
        get { self[FirebaseAuthentication.self] }
        set { self[FirebaseAuthentication.self] = newValue }
    }
}
