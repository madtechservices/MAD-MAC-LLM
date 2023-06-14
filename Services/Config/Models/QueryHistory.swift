//
//  QueryHistory.swift
//  Nea (iOS)
//
//  Created by PEXAVC on 5/20/23.
//

import Foundation
import Granite
import SwiftUI

struct QueryHistory: GraniteModel, Identifiable {
    static func == (lhs: QueryHistory, rhs: QueryHistory) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String = UUID().uuidString
    var date: Date = .init()
    var query: String
    var response: String
    var command: String? //finds prompt
    var subCommandSet: [String: String]? = nil
    var subCommandFileSet: [String: [String: String]]? = nil
    
    var iconName: String?
    var baseColor: String? //hex
    var isSystemPrompt: Bool
}
