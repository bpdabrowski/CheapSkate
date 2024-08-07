//
//  RequestManager.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/2/24.
//

import Dependencies
import Foundation
import Firebase

protocol RequestManagerProtocol {
    func perform(_ request: RequestProtocol) async throws -> [ExpenseData]
    func fireAndForget(_ request: RequestProtocol) async throws
}

final class RequestManager: RequestManagerProtocol {
    let apiManager: APIManagerProtocol
    let parser: DataParserProtocol
    
    private var userId: String? {
        @Dependency(\.auth) var auth
        return auth.currentUser()?.uid
    }

    init(
        apiManager: APIManagerProtocol = APIManager(), // TODO: Use Dependencies for injection instead of this style.
        parser: DataParserProtocol = DataParser()
    ) {
        self.apiManager = apiManager
        self.parser = parser
    }
    
    func fireAndForget(_ request: RequestProtocol) async throws {
        _ = try await apiManager.perform(request, userId: userId!)
    }

    func perform(_ request: RequestProtocol) async throws -> [ExpenseData] {
        guard let userId else {
            throw NSError()
        }
        let data = try await apiManager.perform(request, userId: userId)
        let decoded: [String: ExpenseData] = try parser.parse(data: data)
        return decoded.map { _, value in
            ExpenseData(category: value.category, amount: value.amount, date: value.date)
        }
    }
}

private enum RequestManagerKey: DependencyKey {
    static var liveValue: RequestManagerProtocol = RequestManager()
    static var testValue: RequestManagerProtocol = unimplemented()
}

extension DependencyValues {
    var requestManager: RequestManagerProtocol {
        get { self[RequestManagerKey.self] }
        set { self[RequestManagerKey.self] = newValue }
    }
}
