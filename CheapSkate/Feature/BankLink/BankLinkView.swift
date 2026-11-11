//
//  BankLinkView.swift
//  CheapSkate
//

import ComposableArchitecture
import LinkKit
import SwiftUI

@Reducer
struct BankLink {
    @ObservableState
    struct State: Equatable {
        var linkToken: String?
        var isLinkPresented = false
        var status: Status = .idle

        enum Status: Equatable {
            case idle
            case loading
            case linking
            case importing
            case linked(PlaidSyncResult)
            case failed(String)
        }
    }

    enum Action {
        case connectButtonTapped
        case linkTokenResponse(TaskResult<String>)
        case linkReady
        case setLinkPresented(Bool)
        case linkSucceeded(publicToken: String, institutionName: String?)
        case linkExited(errorMessage: String?)
        case exchangeResponse(TaskResult<PlaidSyncResult>)
        case doneButtonTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case bankLinked
        }
    }

    @Dependency(\.plaid) var plaid
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .connectButtonTapped:
                state.status = .loading
                return .run { send in
                    await send(.linkTokenResponse(TaskResult { try await plaid.createLinkToken() }))
                }
            case .linkTokenResponse(.success(let token)):
                // The view creates the Link handler for this token, then sends linkReady.
                state.linkToken = token
                state.status = .linking
                return .none
            case .linkTokenResponse(.failure):
                state.status = .failed("Couldn't start connecting your bank. Please try again.")
                return .none
            case .linkReady:
                state.isLinkPresented = true
                return .none
            case .setLinkPresented(let isPresented):
                state.isLinkPresented = isPresented
                return .none
            case let .linkSucceeded(publicToken, institutionName):
                state.isLinkPresented = false
                state.linkToken = nil
                state.status = .importing
                return .run { send in
                    await send(.exchangeResponse(TaskResult {
                        try await plaid.exchangePublicToken(publicToken, institutionName)
                    }))
                }
            case .linkExited(let errorMessage):
                // Link tokens are single use, so a retry fetches a new one.
                state.isLinkPresented = false
                state.linkToken = nil
                state.status = errorMessage.map(State.Status.failed) ?? .idle
                return .none
            case .exchangeResponse(.success(let result)):
                state.status = .linked(result)
                return .send(.delegate(.bankLinked))
            case .exchangeResponse(.failure):
                state.status = .failed("Your bank connected, but importing transactions failed. Please try again.")
                return .none
            case .doneButtonTapped:
                return .run { _ in await dismiss() }
            case .delegate:
                return .none
            }
        }
    }
}

struct BankLinkView: View {
    @Bindable var store: StoreOf<BankLink>
    @State private var linkHandler: (any Handler)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "building.columns")
                    .font(.system(size: 48))
                    .foregroundStyle(.mint)
                    .padding(.top, 40)
                Text("Connect your bank")
                    .font(.title2.bold())
                Text("CheapSkate imports your card and bank purchases automatically, so your morning coffee shows up without typing it in.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                statusMessage
                Spacer()
                actionButton
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { store.send(.doneButtonTapped) }
                }
            }
        }
        .onChange(of: store.linkToken) { _, token in
            linkHandler = token.flatMap(makeHandler)
        }
        .plaidLinkIfReady(isPresented: $store.isLinkPresented.sending(\.setLinkPresented), handler: linkHandler)
    }

    @ViewBuilder
    private var statusMessage: some View {
        switch store.status {
        case .idle, .linking:
            EmptyView()
        case .loading, .importing:
            ProgressView(store.status == .importing ? "Importing transactions…" : "Connecting…")
        case .linked(let result):
            Label("Imported \(result.upserted) expenses", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failed(let message):
            Text(message)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch store.status {
        case .linked:
            Button {
                store.send(.doneButtonTapped)
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity, maxHeight: 20)
            }
            .buttonStyle(FullWidth())
        default:
            Button {
                store.send(.connectButtonTapped)
            } label: {
                Text("Connect bank")
                    .frame(maxWidth: .infinity, maxHeight: 20)
            }
            .buttonStyle(FullWidth())
            .disabled(store.status == .loading || store.status == .linking || store.status == .importing)
        }
    }

    private func makeHandler(token: String) -> (any Handler)? {
        var configuration = LinkTokenConfiguration(token: token) { success in
            let publicToken = success.publicToken
            let institutionName = success.metadata.institution.name
            Task { @MainActor in store.send(.linkSucceeded(publicToken: publicToken, institutionName: institutionName)) }
        }
        configuration.onExit = { exit in
            let message = exit.error.map { $0.displayMessage ?? "Couldn't connect your bank. Please try again." }
            Task { @MainActor in store.send(.linkExited(errorMessage: message)) }
        }
        switch Plaid.create(configuration) {
        case .success(let handler):
            Task { @MainActor in store.send(.linkReady) }
            return handler
        case .failure:
            Task { @MainActor in store.send(.linkExited(errorMessage: "Couldn't open the bank connection. Please try again.")) }
            return nil
        }
    }
}

private extension View {
    /// Attaches Plaid Link once a handler exists for the current link token.
    @ViewBuilder
    func plaidLinkIfReady(isPresented: Binding<Bool>, handler: (any Handler)?) -> some View {
        if let handler {
            plaidLink(isPresented: isPresented, handler: handler)
        } else {
            self
        }
    }
}

#Preview {
    BankLinkView(
        store: Store(initialState: BankLink.State()) {
            BankLink()
        }
    )
}
