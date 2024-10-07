//
//  CredentialField.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 10/6/24.
//

import SwiftUI

struct CredentialField: View {
    var labelText: String
    var text: Binding<String>
    var isSecure: Bool = false
    var body: some View {
        Text(labelText)
            .frame(
                maxWidth: .infinity,
                alignment: .init(horizontal: .leading, vertical: .center)
            )
        
        if isSecure {
            SecureField(labelText, text: text)
                .credentials()
                .padding(.bottom, 15)
        } else {
            TextField(labelText, text: text)
                .credentials()
                .padding(.bottom, 15)
        }
    }
}
