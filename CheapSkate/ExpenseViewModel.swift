//
//  ExpenseViewModel.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Foundation

class ExpenseViewModel: ObservableObject {
    enum ExpenseCategory: String, CaseIterable {
        case groceries
        case food
        case gas
        case misc
    }
}
