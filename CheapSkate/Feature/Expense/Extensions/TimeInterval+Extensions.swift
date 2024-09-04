//
//  TimeInterval+Extensions.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/1/24.
//

import Foundation

extension TimeInterval {
    var date: Date {
        Date(timeIntervalSince1970: self)
    }
}
