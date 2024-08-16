//
//  ExpenseHistoryViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/14/23.
//

import Foundation

class ExpenseHistoryViewModel {
    
    func monthlyExpenses(expenseData: [ExpenseData]) -> [(key: DateComponents, value: [Array<ExpenseData>.Element])] {
        return Dictionary(grouping: expenseData, by: { dateKey(Date(timeIntervalSince1970: $0.date)) })
            .sorted { $0.key.month ?? 0 > $1.key.month ?? 0 }
            .sorted { $0.key.year ?? 0 > $1.key.year ?? 0 }
    }
    
    func sum(of expenseData: [ExpenseData]) -> String {
        let expensesThisMonth = expenseData.filter {
            Calendar.current.isDateInThisMonth(Date(timeIntervalSince1970: $0.date))
        }
        let expenseSum = expensesThisMonth.map(\.amount).reduce(0, +)
        let currencyString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: expenseSum))
        return currencyString!
    }
    
    func averageDailySpend(
        from expenseData: [ExpenseData],
        dayOfMonth: Date = Date(), 
        referenceDate: Date = Date()
    ) -> String {
        return NumberFormatter.currencyFormatter.string(
            from: NSNumber(
                value: averageDailySpend(from: expenseData, dayOfMonth: dayOfMonth, referenceDate: referenceDate)
            )
        )!
    }
    
    private func averageDailySpend(
        from expenseData: [ExpenseData],
        dayOfMonth: Date = Date(),
        referenceDate: Date = Date()
    ) -> Double {
        let expensesThisMonth = expenseData.filter {
            Calendar.current.isDateInThisMonth(Date(timeIntervalSince1970: $0.date), referenceDate: referenceDate)
        }
        let expenseSum = expensesThisMonth.map(\.amount).reduce(0, +)
        let dayOfMonth = Double(day(from: dayOfMonth.timeIntervalSince1970))!
        return expenseSum / dayOfMonth
    }
    
    func extrapolatedSpend(from expenseData: [ExpenseData], date: Date = Date()) -> String {
        let extrapolatedSpend = averageDailySpend(
            from: expenseData,
            dayOfMonth: date, 
            referenceDate: date
        ) * Double(daysInMonth(for: date))
        return NumberFormatter.currencyFormatter.string(from: NSNumber(value: extrapolatedSpend))!
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
    
    func day(from date: Double) -> String {
        return String(Calendar.current.component(.day, from: Date(timeIntervalSince1970: date)))
    }
    
    private func daysInMonth(for date: Date = Date()) -> Int {
        let calendar = Calendar.current

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
}

extension Calendar {
    func isDateInThisMonth(_ date: Date, referenceDate: Date = Date()) -> Bool {
      return isDate(date, equalTo: referenceDate, toGranularity: .month)
    }
}
