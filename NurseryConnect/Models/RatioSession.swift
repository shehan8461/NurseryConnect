//
//  RatioSession.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-25.
//

import Foundation
import SwiftData

enum AgeGroup: String, Codable, CaseIterable {
    case underTwo    = "Under 2s"
    case twoYear     = "2 Year Olds"
    case threeToFive = "3-5 Year Olds"
    
    // EYFS statutory ratios
    var requiredRatio: Int {
        switch self {
        case .underTwo:     return 3  // 1:3
        case .twoYear:      return 4  // 1:4
        case .threeToFive:  return 8  // 1:8
        }
    }
    
    var ratioDescription: String {
        return "1:\(requiredRatio)"
    }
}

enum RatioStatus: String, Codable {
    case compliant  = "Compliant"
    case borderline = "Approaching Limit"
    case breached   = "Ratio Breached"
    
    var icon: String {
        switch self {
        case .compliant:  return "checkmark.shield.fill"
        case .borderline: return "exclamationmark.circle.fill"
        case .breached:   return "exclamationmark.triangle.fill"
        }
    }
    
    var colorHex: String {
        switch self {
        case .compliant:  return "3D9970"
        case .borderline: return "FF851B"
        case .breached:   return "E74C3C"
        }
    }
}

@Model
class RatioSession {
    var id: UUID
    var roomName: String
    var ageGroup: AgeGroup
    var staffCount: Int
    var childCount: Int
    var sessionDate: Date
    var notes: String?
    var resolvedAt: Date?
    
    init(
        id: UUID = UUID(),
        roomName: String = "Sunshine Room",
        ageGroup: AgeGroup = .twoYear,
        staffCount: Int = 0,
        childCount: Int = 0,
        sessionDate: Date = Date(),
        notes: String? = nil,
        resolvedAt: Date? = nil
    ) {
        self.id          = id
        self.roomName    = roomName
        self.ageGroup    = ageGroup
        self.staffCount  = staffCount
        self.childCount  = childCount
        self.sessionDate = sessionDate
        self.notes       = notes
        self.resolvedAt  = resolvedAt
    }
    
    // MARK: - Computed Properties
    var maxAllowedChildren: Int {
        staffCount * ageGroup.requiredRatio
    }
    
    var isBreached: Bool {
        guard staffCount > 0 else { return childCount > 0 }
        return childCount > maxAllowedChildren
    }
    
    var isBorderline: Bool {
        guard !isBreached else { return false }
        return (maxAllowedChildren - childCount) <= 2
    }
    
    var ratioStatus: RatioStatus {
        if isBreached   { return .breached }
        if isBorderline { return .borderline }
        return .compliant
    }
    
    var isResolved: Bool {
        resolvedAt != nil
    }
    
    var duration: String {
        guard let resolved = resolvedAt else { return "Ongoing" }
        let minutes = Int(resolved.timeIntervalSince(sessionDate) / 60)
        return "\(minutes) min"
    }
}
