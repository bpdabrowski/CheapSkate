//
//  Date+Extensions.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/1/24.
//

import Foundation

extension Date {
    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)!.count
    }

    var monthAndYear: DateComponents {
        Calendar.current.dateComponents([.month, .year], from: self)
    }
    
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var startOfMonth: Date {
        Calendar.current.date(from: monthAndYear)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}
