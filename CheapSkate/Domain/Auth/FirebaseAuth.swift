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
    var createUser: @Sendable (String, String) async throws -> Void
    var signIn: @Sendable (String, String) async throws -> Void
    var currentUser: @Sendable () -> FirebaseAuth.User?
    var signOut: @Sendable () -> Void
}

extension FirebaseAuthentication: DependencyKey, Sendable {
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
            createUser: { _, _ in unimplemented("\(Self.self).createHistory", placeholder: ()) },
            signIn: { _, _ in unimplemented("\(Self.self).signIn", placeholder: ()) },
            currentUser: { unimplemented("\(Self.self).currentUser", placeholder: nil)  },
            signOut: { unimplemented("\(Self.self).signOut", placeholder: ()) }
        )
    }
}

extension DependencyValues: Sendable {
    var auth: FirebaseAuthentication {
        get { self[FirebaseAuthentication.self] }
        set { self[FirebaseAuthentication.self] = newValue }
    }
}
