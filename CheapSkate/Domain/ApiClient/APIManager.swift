//
//  APIManager.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/2/24.
//

import Dependencies
import Firebase
import Foundation

protocol APIManagerProtocol {
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
        do {
            // TODO: See if we can make this cleaner.
            switch request.requestType {
            case .POST:
                try await databaseRef.childByAutoId().setValue(request.params)
            case .GET:
                let snapshot = try await databaseRef
                    .queryOrdered(byChild: "date")
                    .queryStarting(
                        atValue: Date().startOfMonth().timeIntervalSince1970,
                        childKey: "date"
                    )
                    .queryEnding(
                        atValue: Date().endOfMonth().timeIntervalSince1970,
                        childKey: "date"
                    )
                    .getData()
                
                guard let json = snapshot.value as? [String: Any] else {
                    throw NSError()
                }

                return try! JSONSerialization.data(withJSONObject: json)
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

extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth())!
    }
}
