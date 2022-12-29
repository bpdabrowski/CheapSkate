//
//  CheapSkateApp.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import SwiftUI

@main
struct CheapSkateApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = ExpenseViewModel()
            ExpenseView(viewModel: viewModel)
        }
    }
}
