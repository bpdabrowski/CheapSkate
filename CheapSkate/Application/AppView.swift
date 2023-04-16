//
//  AppView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 4/15/23.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppReducer>
    var body: some View {
        ExpenseView(store: store.scope(state: \.expenseState, action: AppReducer.Action.expenseAction))
    }
}
