//
//  RatioBreach.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import Foundation
import SwiftData

@Model
class RatioBreach {
    var id: UUID
    var ageGroup: AgeGroup
    var staffCount: Int
    var childCount: Int
    var requiredRatio: Int
    var detectedAt: Date
    var resolvedAt: Date?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        ageGroup: AgeGroup,
        staffCount: Int,
        childCount: Int,
        requiredRatio: Int,
        detectedAt: Date = Date(),
        resolvedAt: Date? = nil,
        notes: String? = nil
    ) {
        self.id            = id
        self.ageGroup      = ageGroup
        self.staffCount    = staffCount
        self.childCount    = childCount
        self.requiredRatio = requiredRatio
        self.detectedAt    = detectedAt
        self.resolvedAt    = resolvedAt
        self.notes         = notes
    }
    
    // Was this breach resolved?
    var isResolved: Bool {
        resolvedAt != nil
    }
    
    // How long was the breach active?
    var duration: String {
        guard let resolved = resolvedAt else { return "Ongoing" }
        let minutes = Int(resolved.timeIntervalSince(detectedAt) / 60)
        return "\(minutes) min"
    }
}
