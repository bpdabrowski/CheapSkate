//
//  AuthErrorView.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/6/24.
//

import SwiftUI

struct AuthErrorView: View {
    var text: String
    
    init?(text: String?) {
        guard let text else {
            return nil
        }
        
        self.text = text
    }
    
    var body: some View {
        HStack {
            Image(systemName: "x.circle.fill")
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
        }
        .foregroundColor(.red)
    }
}
