//
//  ChildPresence.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import Foundation
import SwiftData

@Model
class ChildPresence {
    var id: UUID
    // GDPR Data Minimisation — first name only
    // Driver/Catering see even less; Room Leader sees first name only
    var firstName: String
    var ageGroup: AgeGroup
    var isPresent: Bool
    var arrivedAt: Date?
    var departedAt: Date?
    
    init(
        id: UUID = UUID(),
        firstName: String,
        ageGroup: AgeGroup,
        isPresent: Bool = false,
        arrivedAt: Date? = nil,
        departedAt: Date? = nil
    ) {
        self.id         = id
        self.firstName  = firstName
        self.ageGroup   = ageGroup
        self.isPresent  = isPresent
        self.arrivedAt  = arrivedAt
        self.departedAt = departedAt
    }
}
