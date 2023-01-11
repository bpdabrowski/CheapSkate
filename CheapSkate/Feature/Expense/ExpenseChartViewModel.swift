//
//  ExpenseChartViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/2/23.
//

import Foundation
import ComposableArchitecture

class ExpenseChartViewModel {
    
    private static var currencyFormatter: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter
    }
    
    func measurementsByMonth(_ month: Date?) -> String {
        guard let month = month else {
            return ""
        }
        
        let thisMonth = Calendar.current.component(.month, from: month)
        return Calendar.current.veryShortMonthSymbols[thisMonth - 1]
    }
    
    func total(for category: ExpenseCategory, expenseData: [ExpenseData]) -> String {
        let dictionary = Dictionary(grouping: expenseData, by: { $0.category })
        guard let categoryTotal = dictionary[category]?.map(\.amount).reduce(0, +),
            let currencyString = ExpenseChartViewModel.currencyFormatter.string(from: NSNumber(value: categoryTotal)) else {
            return ""
        }
        return "\(category.rawValue.capitalized) - \(currencyString)"
    }
    
    func total(expenseData: [ExpenseData]) -> String {
        let totalExpenses = expenseData.map(\.amount).reduce(0, +)
        guard let currencyString = ExpenseChartViewModel.currencyFormatter.string(from: NSNumber(value: totalExpenses)) else {
            return ""
        }
        return currencyString
    }
}
