//
//  CurrencyTextField.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/31/22.
//

import SwiftUI
import ComposableArchitecture

struct CurrencyTextField: UIViewRepresentable {
    
    typealias UIViewType = CurrencyUITextField
    
    let numberFormatter: NumberFormatter
    let currencyField: CurrencyUITextField
    let value: Binding<Double>
    
    init(numberFormatter: NumberFormatter, value: Binding<Double>) {
        self.numberFormatter = numberFormatter
        self.value = value
        currencyField = CurrencyUITextField(formatter: numberFormatter, value: value)
        currencyField.becomeFirstResponder()
    }
    
    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }
    
    func updateUIView(_ uiView: CurrencyUITextField, context: Context) {
        if value.wrappedValue == 0 {
            uiView.text = "$0.00"
        }
    }
}
