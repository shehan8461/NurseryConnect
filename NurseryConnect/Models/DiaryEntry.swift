import Foundation
import SwiftData

enum EntryType: String, Codable, CaseIterable {
    case activity  = "Activity"
    case sleep     = "Sleep"
    case meal      = "Meal"
    case mood      = "Mood"
    case incident  = "Incident"
    
    var icon: String {
        switch self {
        case .activity: return "🎨"
        case .sleep:    return "😴"
        case .meal:     return "🍽️"
        case .mood:     return "😊"
        case .incident: return "⚠️"
        }
    }
}

enum ReviewStatus: String, Codable, CaseIterable {
    case pending            = "Pending"
    case countersigned      = "Countersigned"
    case amendmentRequested = "Amendment Requested"
    
    var icon: String {
        switch self {
        case .pending:            return "clock"
        case .countersigned:      return "checkmark.seal.fill"
        case .amendmentRequested: return "pencil.circle.fill"
        }
    }
    
    var colorHex: String {
        switch self {
        case .pending:            return "FF851B"
        case .countersigned:      return "3D9970"
        case .amendmentRequested: return "E74C3C"
        }
    }
}

@Model
class DiaryEntry {
    var id: UUID
    var childFirstName: String       // GDPR: first name only
    var keyworkerName: String
    var entryType: EntryType
    var entryDescription: String
    var submittedAt: Date
    var status: ReviewStatus
    var countersignedAt: Date?
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
        self.amendmentNote    = amendmentNote
    }
}
