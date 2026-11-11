//
//  ExpenseRequest.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/4/24.
//

import Foundation

enum ExpenseRequest: RequestProtocol {
    case save(ExpenseData)
    case delete(String)
    case getByMonth(Date? = nil)
    case all
    
    var path: String {
        switch self {
        case .save:
            return "expenses"
        case .delete(let remoteId):
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
        guard case .save(let expenseData) = self else {
            return nil
        }
        // TODO: See if we can adjust this to not use JSONSerialization and JSONEncoder.
        return try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(expenseData))
    }
    
    var urlParams: [String : String?] {
        var params = [String: String?]()
        switch self {
        case .save, .delete:
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
        case .delete:
            return .DELETE
        case .getByMonth:
            return .GET
        case .all:
            return .GET
        }
    }
}
