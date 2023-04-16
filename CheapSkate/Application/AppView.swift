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
    @ObservedObject var viewStore: ViewStore<ViewState, AppReducer.Action>

    struct ViewState: Equatable {
      let isLoginPresented: Bool

      init(state: AppReducer.State) {
        self.isLoginPresented = state.login != nil
      }
    }

    public init(store: StoreOf<AppReducer>) {
      self.store = store
      self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
    }
    
    var body: some View {
        Group {
            if !self.viewStore.isLoginPresented {
                ExpenseView(store: store.scope(state: \.expense, action: AppReducer.Action.expense))
            } else {
                IfLetStore(
                  self.store.scope(state: \.login, action: AppReducer.Action.login),
                  then: LoginView.init(store:)
                )
            }
        }.onAppear {
            viewStore.send(.onAppear)
        }
    }
}
