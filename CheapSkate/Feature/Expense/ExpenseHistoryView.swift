//
//  ExpenseHistory.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/10/23.
//

import SwiftUI
import ComposableArchitecture

struct ExpenseHistoryView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("January")
                .font(.system(size: 60))
            categorySelector()
            Text("January")
                .font(.system(size: 60))
            categorySelector()
            Text("January")
                .font(.system(size: 60))
            categorySelector()
            Spacer()
        }.padding(.leading, 20)
    }
    
    private func categorySelector() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 210, height: 105)
                            .foregroundColor(category.color)
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 205, height: 100)
                            .foregroundColor(.white)
                        VStack {
                            HStack {
                                Text("15.74")
                                Spacer()
                                Text(category.rawValue.capitalized)
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            Text("January 10, 2023")
                                .padding(.top, 10)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    }
                }
            }.padding(.bottom, 10)
        }
    }
}

struct ExpenseHistory_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseHistoryView()
    }
}
