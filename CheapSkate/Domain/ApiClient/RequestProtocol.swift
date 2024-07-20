//
//  RequestProtocol.swift
//  CheapSkate
//
//  Created by Dabrowski, Brendyn (B.) on 2/2/24.
//

import Dependencies
import Firebase
import Foundation

protocol RequestProtocol {
    // TODO: Do we need all of these properties or can we slim it down now that we are on firebase?
    var path: String { get }
    var requestType: RequestType { get }
    var headers: [String: String] { get }
    var params: Any? { get }
    var urlParams: [String: String?] { get }
    var addAuthorizationToken: Bool { get }
    var addUserId: Bool { get }
}

// MARK: - Default RequestProtocol
extension RequestProtocol {

    var host: String {
        return ""
    }

    var addAuthorizationToken: Bool {
      true
    }
    
    var addUserId: Bool {
        true
    }
    
    var params: Any? {
      nil
    }

    var urlParams: [String: String?] {
      [:]
    }

    var headers: [String: String] {
      [:]
    }
}

enum RequestType: String {
    case GET
    case POST
}
