//
//  NumberFormatter+Extensions.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/15/23.
//

import Foundation

extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter
    }
}
