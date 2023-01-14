//
//  ExpenseHistoryViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/14/23.
//

import Foundation

class ExpenseHistoryViewModel {
    
    func monthlyExpenses(expenseData: [ExpenseData]) -> [(key: DateComponents, value: [Array<ExpenseData>.Element])] {
        return Dictionary(grouping: expenseData, by: { dateKey($0.date) })
            .sorted { $0.key.month ?? 0 > $1.key.month ?? 0 }
            .sorted { $0.key.year ?? 0 > $1.key.year ?? 0 }
    }
    
    func formatKey(_ key: DateComponents) -> String {
        guard let month = key.month,
            let year = key.year else {
            return ""
        }
        let monthSymbol = Calendar.current.monthSymbols[month - 1]
        return "\(monthSymbol) \(year)"
    }
    
    private func dateKey(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.month, .year], from: date)
    }
    
    func currency(expense: Double) -> String {
        guard let currencyString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: expense)) else {
            return ""
        }
        return currencyString
    }
    
    func day(from date: Date) -> String {
        return String(Calendar.current.component(.day, from: date))
    }
}
