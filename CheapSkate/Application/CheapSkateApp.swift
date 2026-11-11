//
//  CheapSkateApp.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI
import ComposableArchitecture
import Firebase

@main
struct CheapSkateApp: App {
    init() {
        // Unit tests build their own stores, so skip app setup when running as the test host.
        guard !_XCTIsTesting else { return }
        FirebaseApp.configure()
    }

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
