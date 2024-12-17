//
//  BudgetStyleViewModifier.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/15/24.
//

import SwiftUI

extension Text {
    func budgetStyle() -> some View {
        modifier(BudgetStyleViewModifier())
    }
}

struct BudgetStyleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: 20)
            .padding(30)
            .font(.system(size: 52))
            .foregroundStyle(.gray)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.gray)
                    .opacity(0.2)
            )
    }
}
