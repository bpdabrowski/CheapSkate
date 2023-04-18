//
//  ExpenseEffects.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Foundation
import ComposableArchitecture

class ExpenseClient {
    
    static var urlComponents: URLComponents? {
        let baseURL = "localhost"
        let endpoint = "/api/expenses"
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = baseURL
        urlComponents.port = 8080
        urlComponents.path = endpoint
        return urlComponents
    }
    
    func saveExpense(state: ExpenseData) -> Effect<Void, APIError> {
        guard let url = Self.urlComponents?.url else {
            return Effect(error: APIError.requestError)
        }

        let data: Data
        do {
            data = try JSONEncoder().encode(state)
        } catch {
            return Effect(error: APIError.codingError)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request(url: url, httpMethod: "POST", data: data))
          .mapError { _ in
              return APIError.requestError
          }
          .map { _,_ in }
          .eraseToEffect()
    }
    
    func getExpenses(for date: Date? = nil) -> Effect<[ExpenseData], APIError> {
        guard var urlComponents = Self.urlComponents else {
            return Effect(error: APIError.requestError)
        }
        
        if let date = date {
            urlComponents.path = "\(urlComponents.path)/search"
            urlComponents.queryItems = [
                URLQueryItem(
                    name: "month",
                    value: String(Calendar.current.component(.month, from: date))
                )
            ]
        }
        
        guard let url = urlComponents.url else {
            return Effect(error: APIError.requestError)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request(url: url, httpMethod: "GET"))
            .map(\.data)
            .decode(type: [ExpenseData].self, decoder: JSONDecoder())
            .mapError { _ in APIError.requestError }
            .eraseToEffect()
    }
    
    private func request(url: URL, httpMethod: String, data: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        if let data = data {
            request.httpBody = data
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        if let token = Auth.shared.token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let userId = Auth.shared.userId {
            request.addValue(userId, forHTTPHeaderField: "user-id")
        }

        return request
    }
}


