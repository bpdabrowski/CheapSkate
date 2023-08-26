//
//  APIError.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Foundation

enum APIError: Error {
    case requestError
    case codingError
    case invalidValue
}

public func apiDecode<A: Decodable>(_ type: A.Type, from data: Data) throws -> A {
  do {
    return try JSONDecoder().decode(A.self, from: data)
  } catch {
      throw APIError.requestError
  }
}
