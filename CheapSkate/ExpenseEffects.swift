//
//  ExpenseEffects.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/28/22.
//

import Foundation
import ComposableArchitecture

func putExpenseEffect(state: ExpenseState) -> Effect<Void, APIError> {
    print("Hi BD! \(state)")
    return Effect(value: ())
}
