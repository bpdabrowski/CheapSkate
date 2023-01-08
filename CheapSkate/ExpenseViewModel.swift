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
    
    func submitButtonColor(viewState: ExpenseViewState) -> Color {
        var color = Color.mint
        
        switch viewState {
        case .idle,
            .submitSuccessful:
            break
        case .submitInProgress:
            color = .gray
        case .submitError:
            color = .red
        }
        
        return color
    }
}
