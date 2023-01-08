//
//  ExpenseRepository.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/30/22.
//

import ComposableArchitecture
import Foundation

class ExpenseRepository {
    
    let expenseClient = ExpenseClient()
    
    func saveExpense(state: ExpenseData) -> Effect<Void, APIError> {
        guard state.amount != 0 else {
            return Effect(error: APIError.invalidValue)
        }
        return expenseClient.saveExpense(state: state)
    }
    
    func getExpenses(for month: Int) -> Effect<[ExpenseData], APIError> {
        return expenseClient.getExpenses()
        
//        let minute: TimeInterval = 60.0
//        let hour: TimeInterval = 60.0 * minute
//        let day: TimeInterval = 24 * hour
//
//        let minusSevenDays = Date(timeIntervalSinceNow: day * -7)
//        let minusSixDays = Date(timeIntervalSinceNow: day * -6)
//        let minusFiveDays = Date(timeIntervalSinceNow: day * -5)
//        let minusFourDays = Date(timeIntervalSinceNow: day * -4)
//        let minusThreeDays = Date(timeIntervalSinceNow: day * -3)
//        let minusTwoDays = Date(timeIntervalSinceNow: day * -2)
//        let minusOneDay = Date(timeIntervalSinceNow: day * -1)
//        let oneDay = Date(timeIntervalSinceNow: day)
//        let twoDays = Date(timeIntervalSinceNow: day * 2)
//        let threeDays = Date(timeIntervalSinceNow: day * 3)
//        let fourDays = Date(timeIntervalSinceNow: day * 4)
//        let fiveDays = Date(timeIntervalSinceNow: day * 5)
//        let sixDays = Date(timeIntervalSinceNow: day * 6)
//        let sevenDays = Date(timeIntervalSinceNow: day * 7)
//        let expenses = [
//            ExpenseData(category: .food, amount: 40.00, date: minusSevenDays),
//            ExpenseData(category: .food, amount: 40.00, date: minusSixDays),
//            ExpenseData(category: .food, amount: 40.00, date: minusFiveDays),
//            ExpenseData(category: .food, amount: 40.00, date: minusFourDays),
//            ExpenseData(category: .food, amount: 40.00, date: minusThreeDays),
//            ExpenseData(category: .food, amount: 40.00, date: minusTwoDays),
//            ExpenseData(category: .food, amount: 40.00, date: minusOneDay),
//            ExpenseData(category: .food, amount: 40.00, date: Date()),
//            ExpenseData(category: .food, amount: 5.00, date: oneDay),
//            ExpenseData(category: .food, amount: 6.00, date: oneDay),
//            ExpenseData(category: .food, amount: 7.00, date: twoDays),
//            ExpenseData(category: .food, amount: 8.00, date: threeDays),
//            ExpenseData(category: .food, amount: 5.00, date: fourDays),
//            ExpenseData(category: .food, amount: 5.00, date: fourDays),
//            ExpenseData(category: .food, amount: 5.00, date: fiveDays),
//            ExpenseData(category: .food, amount: 5.00, date: fiveDays),
//            ExpenseData(category: .food, amount: 40.00, date: fiveDays),
//            ExpenseData(category: .groceries, amount: 5.00, date: oneDay),
//            ExpenseData(category: .groceries, amount: 5.00, date: twoDays),
//            ExpenseData(category: .groceries, amount: 5.00, date: twoDays),
//            ExpenseData(category: .groceries, amount: 5.00, date: twoDays),
//            ExpenseData(category: .groceries, amount: 5.00, date: threeDays),
//            ExpenseData(category: .groceries, amount: 5.00, date: sixDays),
//            ExpenseData(category: .groceries, amount: 5.00, date: sixDays),
//            ExpenseData(category: .misc, amount: 5.00, date: oneDay),
//            ExpenseData(category: .misc, amount: 5.00, date: twoDays),
//            ExpenseData(category: .misc, amount: 5.00, date: twoDays),
//            ExpenseData(category: .misc, amount: 5.00, date: threeDays),
//            ExpenseData(category: .misc, amount: 5.00, date: fourDays),
//            ExpenseData(category: .misc, amount: 5.00, date: sevenDays),
//            ExpenseData(category: .misc, amount: 5.00, date: sevenDays),
//            ExpenseData(category: .gas, amount: 5.00, date: oneDay),
//            ExpenseData(category: .gas, amount: 5.00, date: twoDays),
//            ExpenseData(category: .gas, amount: 5.00, date: twoDays),
//            ExpenseData(category: .gas, amount: 5.00, date: twoDays),
//            ExpenseData(category: .gas, amount: 5.00, date: fourDays),
//            ExpenseData(category: .gas, amount: 5.00, date: fourDays),
//            ExpenseData(category: .gas, amount: 5.00, date: fourDays),
//            ExpenseData(category: .gas, amount: 5.00, date: sevenDays),
//            ExpenseData(category: .gas, amount: 5.00, date: sevenDays)
//        ]
//        return Effect(value: expenses)
    }
}
