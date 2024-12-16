//
//  CategoryCell.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 12/14/24.
//

import SwiftUI

struct CategoryCell: View {
    let title: String
    let color: Color
    let action: () -> Void
    @State var selected: Bool
    
    init(title: String, color: Color, action: @escaping () -> Void = { }, selected: Bool = false) {
        self.title = title
        self.color = color
        self.action = action
        self.selected = selected
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 115, height: 60)
                .foregroundColor(color)
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 110, height: 55)
                .foregroundColor(selected ? color : .white)
            Text(title)
                .foregroundColor(selected ? .white : .black)
                .font(.caption)
        }
        .onTapGesture {
            action()
            withAnimation { selected.toggle() }
        }
    }
}
