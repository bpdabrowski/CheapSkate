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
    var user: User
    
    init(value: String, user: User) {
        self.value = value
        self.user = user
    }
}

final class User: Codable {
    var id: UUID?
}
