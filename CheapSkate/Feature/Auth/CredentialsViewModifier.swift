//
//  CredentialsViewModifier.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/20/24.
//

import SwiftUI

struct CredentialsViewModifier: ViewModifier {
    var secure: Bool
    var showPassword: Bool
    var visibilityAction: () -> Void
    
    init(
        secure: Bool = true,
        showPassword: Bool,
        visibilityAction: @escaping () -> Void
    ) {
        self.secure = secure
        self.showPassword = showPassword
        self.visibilityAction = visibilityAction
    }

    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
            .textInputAutocapitalization(TextInputAutocapitalization.never)
            .textFieldStyle(OutlinedTextFieldStyle(icon: secure ? .password : .user))
        
        if secure {
            HStack {
                Spacer()
                Button(
                    action: { visibilityAction() },
                    label: {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .padding(.trailing, 10)
                            .foregroundStyle(.gray)
                    }
                )
            }
        }
    }
}

extension View {
    func secureCredentials(
        showPassword: Bool,
        visibilityAction: @escaping () -> Void
    ) -> some View {
        modifier(
            CredentialsViewModifier(
                secure: true,
                showPassword: showPassword,
                visibilityAction: visibilityAction
            )
        )
    }
}

extension TextField where Label == Text {
    func credentials() -> some View {
        modifier(CredentialsViewModifier(secure: false, showPassword: false, visibilityAction: { }))
    }
}
