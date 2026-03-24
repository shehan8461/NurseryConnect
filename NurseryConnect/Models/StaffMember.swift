//
//  StaffMember.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import Foundation
import SwiftData

@Model
class StaffMember {
    var id: UUID
    var name: String
    var role: String
    var isPresent: Bool
    var arrivedAt: Date?
    var leftAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        role: String = "Keyworker",
        isPresent: Bool = false,
        arrivedAt: Date? = nil,
        leftAt: Date? = nil
    ) {
        self.id        = id
        self.name      = name
        self.role      = role
        self.isPresent = isPresent
        self.arrivedAt = arrivedAt
        self.leftAt    = leftAt
    }
}
