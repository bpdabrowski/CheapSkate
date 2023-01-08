//
//  ExpenseChartViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/2/23.
//

import Foundation

class ExpenseChartViewModel {
    func chartableDate(from date: Date) -> Date {
        let components = Calendar.current.dateComponents([.day], from: date)
//        let day = Calendar.current.date(from: components)!
//        let dayString = "\(day)"
//        return dayString
//        let dayInt = components.day
//        return dayInt!
        return Calendar.current.date(from: components)!
    }
}
