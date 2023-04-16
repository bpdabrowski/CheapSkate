//
//  CheapSkateApp.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct CheapSkateApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppReducer.State(), reducer: AppReducer()))
        }
    }
}
