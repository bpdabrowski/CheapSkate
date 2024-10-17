//
//  APIManager.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/2/24.
//

import Dependencies
@preconcurrency import Firebase
import Foundation

protocol APIManagerProtocol: Sendable {
  func perform(_ request: RequestProtocol, userId: String) async throws -> Data
}

actor APIManager: APIManagerProtocol {
      private let urlSession: URLSession

      init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
      }

    @discardableResult
    func perform(_ request: RequestProtocol, userId: String) async throws -> Data {
        let databaseRef = createFirebaseRequest(userId: userId).child(request.path)
        let expenseRequest = request as? ExpenseRequest
        do {
            // TODO: See if we can make this cleaner.
            switch expenseRequest {
            case .save:
                try await databaseRef.childByAutoId().setValue(request.params)
            case .getByMonth:
                let snapshot = try await databaseRef
                    .queryOrdered(byChild: "date")
                    .queryStarting(
                        atValue: Date().startOfMonth.timeIntervalSince1970,
                        childKey: "date"
                    )
                    .queryEnding(
                        atValue: Date().endOfMonth.timeIntervalSince1970,
                        childKey: "date"
                    )
                    .getData()
                
                guard let json = snapshot.value as? [String: Any] else {
                    throw NSError()
                }

                return try! JSONSerialization.data(withJSONObject: json)
            case .all:
                let snapshot = try await databaseRef
                    .queryOrdered(byChild: "date")
                    .getData()
                
                guard let json = snapshot.value as? [String: Any] else {
                    throw NSError()
                }

                return try! JSONSerialization.data(withJSONObject: json)
            case .none:
                break
            }
            
        } catch {
            
        }
        return Data()
    }
    
    func createFirebaseRequest(userId: String) -> DatabaseReference {
        return Database.database()
          .reference()
          .child("users")
          .child(userId)
    }
}
