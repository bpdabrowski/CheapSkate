//
//  Token.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 2/11/23.
//

import Foundation

final class Token: Codable {
  var id: UUID?
  var value: String

  init(value: String) {
    self.value = value
  }
}
