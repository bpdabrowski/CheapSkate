//
//  CheapSkateApp.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI
import ComposableArchitecture
import Firebase
import FirebaseFunctions

@main
struct CheapSkateApp: App {
    init() {
        // Unit tests build their own stores, so skip app setup when running as the test host.
        guard !_XCTIsTesting else { return }
        FirebaseApp.configure()
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-useFirebaseEmulators") {
            connectToFirebaseEmulators()
        }
        #endif
    }

    #if DEBUG
    /// Points Auth, Realtime Database and Functions at the emulators started from cheapskate-backend.
    /// On a physical device, set the FIREBASE_EMULATOR_HOST environment variable to the Mac's LAN IP.
    private func connectToFirebaseEmulators() {
        let host = ProcessInfo.processInfo.environment["FIREBASE_EMULATOR_HOST"] ?? "localhost"
        Auth.auth().useEmulator(withHost: host, port: 9099)
        Database.database().useEmulator(withHost: host, port: 9000)
        Functions.functions().useEmulator(withHost: host, port: 5001)
    }
    #endif

    var body: some Scene {
        WindowGroup {
            if _XCTIsTesting {
                EmptyView()
            } else {
                AppView(
                    store: Store(
                        initialState: AppReducer.State(),
                        reducer: {
                            AppReducer()
                        }
                    )
                )
            }
        }
    }
}
