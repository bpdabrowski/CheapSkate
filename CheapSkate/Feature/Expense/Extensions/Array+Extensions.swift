//
//  Array+Extensions.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/1/24.
//


extension Array where Element == ExpenseData {
    var sum: Double {
        self.map(\.amount).reduce(0, +)
    }
}
