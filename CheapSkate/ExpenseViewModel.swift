//
//  ExpenseViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Encodable {
    case groceries
    case food
    case gas
    case misc
}

class ExpenseViewModel {
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    func tabTextColor(cellCategory: ExpenseCategory, selectedCategory: ExpenseCategory) -> Color {
        return cellCategory == selectedCategory ? .white : .black
    }
    
    func tabFillColor(cellCategory: ExpenseCategory, selectedCategory: ExpenseCategory) -> Color {
        return cellCategory == selectedCategory ? .mint : .white
    }
}
