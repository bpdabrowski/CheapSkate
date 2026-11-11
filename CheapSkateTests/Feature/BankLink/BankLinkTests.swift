//
//  BankLinkTests.swift
//  CheapSkateTests
//

import ComposableArchitecture
import Foundation
import Testing
@testable import CheapSkate

@MainActor
struct BankLinkTests {
    @Test func connectAndImport() async {
        let store = TestStore(initialState: BankLink.State()) {
            BankLink()
        } withDependencies: {
            $0.plaid.createLinkToken = { "link-sandbox-token" }
            $0.plaid.exchangePublicToken = { publicToken, institutionName in
                #expect(publicToken == "public-sandbox-token")
                #expect(institutionName == "First Platypus Bank")
                return PlaidSyncResult(upserted: 12, removed: 0)
            }
        }

        await store.send(.connectButtonTapped) {
            $0.status = .loading
        }
        await store.receive(\.linkTokenResponse.success) {
            $0.linkToken = "link-sandbox-token"
            $0.status = .linking
        }
        await store.send(.linkReady) {
            $0.isLinkPresented = true
        }
        await store.send(.linkSucceeded(publicToken: "public-sandbox-token", institutionName: "First Platypus Bank")) {
            $0.isLinkPresented = false
            $0.linkToken = nil
            $0.status = .importing
        }
        await store.receive(\.exchangeResponse.success) {
            $0.status = .linked(PlaidSyncResult(upserted: 12, removed: 0))
        }
        await store.receive(\.delegate.bankLinked)
    }

    @Test func linkTokenFailure() async {
        let store = TestStore(initialState: BankLink.State()) {
            BankLink()
        } withDependencies: {
            $0.plaid.createLinkToken = { throw NSError(domain: "functions", code: 13) }
        }

        await store.send(.connectButtonTapped) {
            $0.status = .loading
        }
        await store.receive(\.linkTokenResponse.failure) {
            $0.status = .failed("Couldn't start connecting your bank. Please try again.")
        }
    }

    @Test func userClosesLink() async {
        let store = TestStore(
            initialState: BankLink.State(linkToken: "link-sandbox-token", isLinkPresented: true, status: .linking)
        ) {
            BankLink()
        }

        await store.send(.linkExited(errorMessage: nil)) {
            $0.isLinkPresented = false
            $0.linkToken = nil
            $0.status = .idle
        }
    }

    @Test func linkReportsError() async {
        let store = TestStore(
            initialState: BankLink.State(linkToken: "link-sandbox-token", isLinkPresented: true, status: .linking)
        ) {
            BankLink()
        }

        await store.send(.linkExited(errorMessage: "The credentials were not correct.")) {
            $0.isLinkPresented = false
            $0.linkToken = nil
            $0.status = .failed("The credentials were not correct.")
        }
    }

    @Test func importFailure() async {
        let store = TestStore(initialState: BankLink.State(status: .linking)) {
            BankLink()
        } withDependencies: {
            $0.plaid.exchangePublicToken = { _, _ in throw NSError(domain: "functions", code: 13) }
        }

        await store.send(.linkSucceeded(publicToken: "public-sandbox-token", institutionName: nil)) {
            $0.status = .importing
        }
        await store.receive(\.exchangeResponse.failure) {
            $0.status = .failed("Your bank connected, but importing transactions failed. Please try again.")
        }
    }

    @Test func expenseScreenReloadsAfterLinking() async {
        let store = TestStore(initialState: Expense.State(destination: .bankLink(BankLink.State()))) {
            Expense()
        } withDependencies: {
            $0.requestManager = StubRequestManager()
        }
        store.exhaustivity = .off

        await store.send(.destination(.presented(.bankLink(.delegate(.bankLinked)))))
        await store.receive(\.getExpenses)
    }
}

private struct StubRequestManager: RequestManagerProtocol {
    func perform(_ request: RequestProtocol) async throws -> [ExpenseData] { [] }
    func fireAndForget(_ request: RequestProtocol) async throws {}
}
