//
//  PlaidClient.swift
//  CheapSkate
//

import Dependencies
import FirebaseFunctions
import Foundation

struct PlaidSyncResult: Equatable, Decodable, Sendable {
    var upserted: Int
    var removed: Int
}

/// Calls the Plaid Cloud Functions in cheapskate-backend. The Plaid secret and
/// access tokens stay on the server; the app only ever sees link and public tokens.
struct PlaidClient: Sendable {
    var createLinkToken: @Sendable () async throws -> String
    var exchangePublicToken: @Sendable (_ publicToken: String, _ institutionName: String?) async throws -> PlaidSyncResult
    var syncNow: @Sendable () async throws -> PlaidSyncResult
}

private struct EmptyRequest: Encodable {}

private struct LinkTokenResponse: Decodable {
    var linkToken: String
}

private struct ExchangePublicTokenRequest: Encodable {
    var publicToken: String
    var institutionName: String?
}

extension PlaidClient: DependencyKey {
    static var liveValue: PlaidClient {
        PlaidClient(
            createLinkToken: {
                let callable: Callable<EmptyRequest, LinkTokenResponse> = Functions.functions().httpsCallable("createLinkToken")
                return try await callable.call(EmptyRequest()).linkToken
            },
            exchangePublicToken: { publicToken, institutionName in
                let callable: Callable<ExchangePublicTokenRequest, PlaidSyncResult> = Functions.functions().httpsCallable("exchangePublicToken")
                return try await callable.call(ExchangePublicTokenRequest(publicToken: publicToken, institutionName: institutionName))
            },
            syncNow: {
                let callable: Callable<EmptyRequest, PlaidSyncResult> = Functions.functions().httpsCallable("syncNow")
                return try await callable.call(EmptyRequest())
            }
        )
    }

    static var testValue: PlaidClient {
        PlaidClient(
            createLinkToken: { unimplemented("\(Self.self).createLinkToken", placeholder: "") },
            exchangePublicToken: { _, _ in unimplemented("\(Self.self).exchangePublicToken", placeholder: PlaidSyncResult(upserted: 0, removed: 0)) },
            syncNow: { unimplemented("\(Self.self).syncNow", placeholder: PlaidSyncResult(upserted: 0, removed: 0)) }
        )
    }
}

extension DependencyValues {
    var plaid: PlaidClient {
        get { self[PlaidClient.self] }
        set { self[PlaidClient.self] = newValue }
    }
}
