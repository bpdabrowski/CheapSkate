//
//  ExpenseChartViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/2/23.
//

import Foundation

class ExpenseChartViewModel {
    func measurementsByMonth(_ month: Date?) -> String {
        guard let month = month else {
            return "No Expenses This Month"
        }
        
        let thisMonth = Calendar.current.component(.month, from: month)
        return Calendar.current.monthSymbols[thisMonth - 1]
    }
}
