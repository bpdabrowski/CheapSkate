//
//  FullWidthButtonStyle.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/6/24.
//

import SwiftUI

struct FullWidth: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.mint)
            )
            .foregroundColor(.white)
    }
}
