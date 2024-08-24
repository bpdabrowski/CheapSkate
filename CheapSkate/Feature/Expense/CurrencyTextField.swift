//
//  CurrencyTextField.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/31/22.
//

import SwiftUI
import ComposableArchitecture

@MainActor
struct CurrencyTextField: UIViewRepresentable {
    
    typealias UIViewType = CurrencyUITextField
    
    let currencyField: CurrencyUITextField
    let value: Binding<Double>
    
    init(value: Binding<Double>) {
        self.value = value
        currencyField = CurrencyUITextField(value: value)
    }
    
    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }
    
    func updateUIView(_ uiView: CurrencyUITextField, context: Context) {
        if value.wrappedValue == 0 {
            uiView.text = "$0.00"
            uiView.tintColor = .systemMint
        }
        
        if !uiView.isFocused {
            uiView.becomeFirstResponder()
        }
    }
}
