//
//  SubHeader.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/6/24.
//

import SwiftUI

struct SubHeader: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
    }
}
