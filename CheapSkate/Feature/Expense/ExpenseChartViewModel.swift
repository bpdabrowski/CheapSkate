//
//  ExpenseChartViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/2/23.
//

import Foundation
import ComposableArchitecture

class ExpenseChartViewModel {
    
    func measurementsByMonth(_ interval: Double?) -> String {
        guard let interval = interval else {
            return ""
        }
        
        let thisMonth = Calendar.current.component(.month, from: Date(timeIntervalSince1970: interval))
        return Calendar.current.veryShortMonthSymbols[thisMonth - 1]
    }
    
    func total(for category: ExpenseCategory, expenseData: [ExpenseData]) -> String {
        let dictionary = Dictionary(grouping: expenseData, by: \.category)
        let formattedCategory = category.rawValue.capitalized
        guard let categoryTotal = dictionary[category]?.map(\.amount).reduce(0, +),
            let currencyString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: categoryTotal)) else {
            return "\(formattedCategory) - \(NumberFormatter.currencyFormatter.string(from: NSNumber(value: 0))!)"
        }
        return "\(formattedCategory) - \(currencyString)"
    }
    
    func total(expenseData: [ExpenseData]) -> String {
        let totalExpenses = expenseData.map(\.amount).reduce(0, +)
        guard let currencyString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: totalExpenses)) else {
            return ""
        }
        return currencyString
    }
    
    func xAxisDomain(expenseData: [ExpenseData], defaultDate: Date = Date()) -> ClosedRange<Date> {
        guard let interval = expenseData.map(\.date).first else {
            return defaultDate.startOfMonth()...defaultDate.endOfMonth()
        }
        let date = Date(timeIntervalSince1970: interval)
        return date.startOfMonth()...date.endOfMonth()
    }
}
