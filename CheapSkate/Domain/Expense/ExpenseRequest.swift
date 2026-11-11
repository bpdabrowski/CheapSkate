//
//  ExpenseRequest.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/4/24.
//

import Foundation

enum ExpenseRequest: RequestProtocol {
    case save(ExpenseData)
    case update(String, ExpenseData)
    case delete(String)
    case getByMonth(Date? = nil)
    case all
    
    var path: String {
        switch self {
        case .save:
            return "expenses"
        case .update(let remoteId, _),
            .delete(let remoteId):
            return "expenses/\(remoteId)"
        case .getByMonth:
            return "expenses"
        case .all:
            return "expenses"
        }
    }
    
    var headers: [String : String] {
        [
            "Accept": "application/json"
        ]
    }
    
    var params: Any? {
        switch self {
        case .save(let expenseData):
            // TODO: See if we can adjust this to not use JSONSerialization and JSONEncoder.
            return try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(expenseData))
        case .update(_, let expenseData):
            // Only the editable fields, so the stored id and date are left untouched.
            return [
                "category": expenseData.category.rawValue,
                "amount": expenseData.amount
            ]
        case .delete, .getByMonth, .all:
            return nil
        }
    }
    
    var urlParams: [String : String?] {
        var params = [String: String?]()
        switch self {
        case .save, .update, .delete:
            break
        case .getByMonth(let date):
            if let date {
                params = ["month": String(Calendar.current.component(.month, from: date))]
            }
        case .all:
            break
        }
        
        return params
    }
    
    var requestType: RequestType {
        switch self {
        case .save:
            return .POST
        case .update:
            return .PATCH
        case .delete:
            return .DELETE
        case .getByMonth:
            return .GET
        case .all:
            return .GET
        }
    }
}
