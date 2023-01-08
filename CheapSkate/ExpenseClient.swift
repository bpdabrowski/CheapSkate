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
          .mapError { _ in APIError.requestError }
          .map { _,_ in }
          .eraseToEffect()
    }
    
    func getExpenses() -> Effect<[ExpenseData], APIError> {
        let baseURL = "localhost"
        let endpoint = "/api/expenses/search"
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = baseURL
        urlComponents.port = 8080
        urlComponents.path = endpoint
        urlComponents.queryItems = [URLQueryItem(name: "month", value: "1")]
        guard let url = urlComponents.url else {
            return Effect(error: APIError.requestError)
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ExpenseData].self, decoder: JSONDecoder())
            .mapError { _ in APIError.requestError }
            .eraseToEffect()
    }
    
    private func request(url: URL, httpMethod: String, data: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}


