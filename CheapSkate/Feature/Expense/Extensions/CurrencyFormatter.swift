//
//  Double+Extensions.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/1/24.
//

import Foundation

extension Double {
    var currency: String {
        let locale = Locale.current
        let formatter = FloatingPointFormatStyle<Double>.Currency(
            code: locale.currency?.identifier ?? "USD",
            locale: locale
        )
        return formatter.format(self)
    }
}

extension Int {
    var currency: String {
        let locale = Locale.current
        let formatter = IntegerFormatStyle<Int>.Currency(
            code: locale.currency?.identifier ?? "USD",
            locale: locale
        ).precision(.fractionLength(0))
        return formatter.format(self)
    }
}
