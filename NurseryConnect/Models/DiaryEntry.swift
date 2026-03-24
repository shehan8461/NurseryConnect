//
//  DiaryEntry.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import Foundation
import SwiftData

enum EntryType: String, Codable, CaseIterable {
    case activity  = "Activity"
    case sleep     = "Sleep"
    case meal      = "Meal"
    case nappy     = "Nappy"
    case mood      = "Mood"
    case incident  = "Incident"
    case milestone = "Milestone"
    
    var icon: String {
        switch self {
        case .activity:  return "🎨"
        case .sleep:     return "😴"
        case .meal:      return "🍽️"
        case .nappy:     return "👶"
        case .mood:      return "😊"
        case .incident:  return "⚠️"
        case .milestone: return "⭐"
        }
    }
    
    var color: String {
        switch self {
        case .activity:  return "3D9970"
        case .sleep:     return "2C5F8A"
        case .meal:      return "FF851B"
        case .nappy:     return "8E44AD"
        case .mood:      return "F39C12"
        case .incident:  return "E74C3C"
        case .milestone: return "27AE60"
        }
    }
}

enum ReviewStatus: String, Codable, CaseIterable {
    case pending             = "Pending"
    case countersigned       = "Countersigned"
    case amendmentRequested  = "Amendment Requested"
    
    var icon: String {
        switch self {
        case .pending:            return "clock"
        case .countersigned:      return "checkmark.seal.fill"
        case .amendmentRequested: return "pencil.circle.fill"
        }
    }
}

@Model
class DiaryEntry {
    var id: UUID
    // GDPR — first name only visible to Room Leader
    var childFirstName: String
    var keyworkerName: String
    var entryType: EntryType
    var entryDescription: String
    var submittedAt: Date
    var status: ReviewStatus
    var countersignedAt: Date?
    var countersignedBy: String?
    var amendmentNote: String?
    
    init(
        id: UUID = UUID(),
        childFirstName: String,
        keyworkerName: String,
        entryType: EntryType,
        entryDescription: String,
        submittedAt: Date = Date(),
        status: ReviewStatus = .pending,
        countersignedAt: Date? = nil,
        countersignedBy: String? = nil,
        amendmentNote: String? = nil
    ) {
        self.id               = id
        self.childFirstName   = childFirstName
        self.keyworkerName    = keyworkerName
        self.entryType        = entryType
        self.entryDescription = entryDescription
        self.submittedAt      = submittedAt
        self.status           = status
        self.countersignedAt  = countersignedAt
        self.countersignedBy  = countersignedBy
        self.amendmentNote    = amendmentNote
    }
}
