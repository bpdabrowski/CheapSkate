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
            ExpenseView(store: Store(initialState: ExpenseFeature.State(), reducer: ExpenseFeature()))
        }
    }
}
