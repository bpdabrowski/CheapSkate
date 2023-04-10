//
//  ExpenseViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable {
    case food
    case gas
    case groceries
    case misc
    
    var color: Color {
        switch self {
        case .food:
            return .blue
        case .gas:
            return .green
        case .groceries:
            return .orange
        case .misc:
            return .purple
        }
    }
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
        return cellCategory == selectedCategory ? cellCategory.color : .white
    }
    
    func submitButtonColor(viewState: ExpenseViewState) -> Color {
        var color = Color.mint
        
        switch viewState {
        case .idle,
            .submitSuccessful,
            .logout:
            break
        case .submitInProgress:
            color = .gray
        case .submitError:
            color = .red
        }
        
        return color
    }
    
    func total(expenses: [ExpenseData]) -> Double {
        return expenses.map(\.amount).reduce(0, +)
    }
}
