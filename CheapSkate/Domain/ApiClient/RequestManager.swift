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
    func perform<T: Decodable>(_ request: RequestProtocol) async throws -> T
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

    func perform<T: Decodable>(_ request: RequestProtocol) async throws -> T {
        guard let userId else {
            throw NSError()
        }
        let data = try await apiManager.perform(request, userId: userId)
        print("Hi BD! this is the type of data: \(type(of: data))")
        let decoded: T = try parser.parse(data: data)
        return decoded
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
