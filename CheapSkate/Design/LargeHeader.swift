//
//  LargeHeader.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/6/24.
//

import SwiftUI

struct LargeHeader: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
