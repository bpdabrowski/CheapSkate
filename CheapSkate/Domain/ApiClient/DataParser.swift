//
//  DataParser.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/2/24.
//

import Foundation

protocol DataParserProtocol: Sendable {
  func parse<T: Decodable>(data: Data) throws -> T
}

final class DataParser: DataParserProtocol {
  private let jsonDecoder: JSONDecoder

  init(jsonDecoder: JSONDecoder = JSONDecoder()) {
    self.jsonDecoder = jsonDecoder
    self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  func parse<T: Decodable>(data: Data) throws -> T {
    return try jsonDecoder.decode(T.self, from: data)
  }
}
