//
//  OutlineTextFieldStyle.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 9/18/24.
//

import SwiftUI

struct OutlinedTextFieldStyle: TextFieldStyle {
    private var image: Image {
        switch icon {
        case .user:
            return Image(systemName: "person")
        case .password:
            return Image(systemName: "lock")
        }
    }
    
    var icon: Icon = .user
    
    enum Icon {
        case user
        case password
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            image.foregroundColor(.gray)
            configuration
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.mint, lineWidth: 2)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
    }
}
