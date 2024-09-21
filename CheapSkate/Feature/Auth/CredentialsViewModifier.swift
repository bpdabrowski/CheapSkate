//
//  CredentialsViewModifier.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/20/24.
//

import SwiftUI

struct CredentialsViewModifier: ViewModifier {
    var secure: Bool
    
    init(secure: Bool = true) {
        self.secure = secure
    }

    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
            .textInputAutocapitalization(TextInputAutocapitalization.never)
            .textFieldStyle(OutlinedTextFieldStyle(icon: secure ? .password : .user))
    }
}

extension SecureField where Label == Text {
    func credentials() -> some View {
        modifier(CredentialsViewModifier(secure: true))
    }
}

extension TextField where Label == Text {
    func credentials() -> some View {
        modifier(CredentialsViewModifier(secure: false))
    }
}
