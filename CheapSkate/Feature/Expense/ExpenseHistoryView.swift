//
//  ExpenseHistory.swift
//  CheapSkate
//
//  Created by Brendyn Dabrowski on 1/10/23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ExpenseHistory {
    @ObservableState
    struct State: Equatable {
        let chartData: [ExpenseData]
        
        var monthlyExpenses: [(key: DateComponents, value: [Array<ExpenseData>.Element])] {
            return Dictionary(grouping: chartData, by: { dateKey(Date(timeIntervalSince1970: $0.date)) })
                .sorted { $0.key.month ?? 0 > $1.key.month ?? 0 }
                .sorted { $0.key.year ?? 0 > $1.key.year ?? 0 }
        }
        
        private func dateKey(_ date: Date) -> DateComponents {
            return Calendar.current.dateComponents([.month, .year], from: date)
        }
        
        func day(from date: Double) -> String {
            return String(Calendar.current.component(.day, from: Date(timeIntervalSince1970: date)))
        }
    }
}

struct ExpenseHistoryView: View {
    let store: StoreOf<ExpenseHistory>
    
    var body: some View {
        ScrollView() {
            ForEach(store.state.monthlyExpenses, id: \.key) { key, value in
                VStack(alignment: .leading) {
                    Text(formatKey(key))
                        .font(.title)
                        .padding(.leading, 20)
                    expenseList(value.sorted(by: { $0.date > $1.date }))
                    Spacer()
                }
            }
            
            Spacer(minLength: 10)
        }
    }
    
    private func expenseList(_ data: [ExpenseData]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 5) {
                ForEach(data, id: \.id) { series in
                    ZStack {
                        Capsule()
                            .frame(width: 115, height: 35)
                            .foregroundColor(series.category.color)
                        Capsule()
                            .frame(width: 110, height: 30)
                            .foregroundColor(.white)
                        HStack {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundColor(series.category.color)
                                .overlay {
                                    Text(store.state.day(from: series.date))
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                }
                                .padding(.leading, 5)
                            Spacer()
                        }

                        
                        HStack {
                            Spacer()
                            Text(currency(expense: series.amount))
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                                .frame(alignment: .trailing)
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}

extension ExpenseHistoryView {
    func formatKey(_ key: DateComponents) -> String {
        guard let month = key.month,
            let year = key.year else {
            return ""
        }

        let monthSymbol = Calendar.current.monthSymbols[month - 1]
        return "\(monthSymbol) \(year)"
    }
    
    func currency(expense: Double) -> String {
        guard let currencyString = NumberFormatter.currencyFormatter.string(from: NSNumber(value: expense)) else {
            return ""
        }
        return currencyString
    }
}

extension Calendar {
    func isDateInThisMonth(_ date: Date, referenceDate: Date = Date()) -> Bool {
      return isDate(date, equalTo: referenceDate, toGranularity: .month)
    }
}

#Preview {
    ExpenseHistoryView(store: Store(
        initialState: .init(
            chartData: [
                ExpenseData(id: UUID(), category: .food, amount: 6.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .gas, amount: 2.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .groceries, amount: 3.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date().timeIntervalSince1970),
                ExpenseData(id: UUID(), category: .misc, amount: 4.00, date: Date(timeIntervalSinceNow: -200_000).timeIntervalSince1970)
            ]
        )) {
        ExpenseHistory()
    })
}

