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
            let rootStore = Store(
              initialState: RootState(),
              reducer: rootReducer,
              environment: .live(environment: RootEnvironment()))
            let store = rootStore.scope(
               state: \.expenseState,
               action: RootAction.expenseAction
            )
            if Auth().token == nil {
                LoginView(expenseStore: store)
            } else {
                ExpenseView(store: store)
            }
        }
    }
}
