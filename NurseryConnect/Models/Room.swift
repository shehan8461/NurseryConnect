//
//  Room.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import Foundation
import SwiftData

enum AgeGroup: String, Codable, CaseIterable {
    case underTwo = "Under 2s"
    case twoYear  = "2 Year Olds"
    case threeToFive = "3-5 Year Olds"
    
    // EYFS legal required ratios
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

@Model
class Room {
    var id: UUID
    var name: String
    var ageGroup: AgeGroup
    var capacity: Int
    
    @Relationship(deleteRule: .cascade)
    var staffMembers: [StaffMember]
    
    @Relationship(deleteRule: .cascade)
    var childPresences: [ChildPresence]
    
    @Relationship(deleteRule: .cascade)
    var ratioBreaches: [RatioBreach]
    
    @Relationship(deleteRule: .cascade)
    var diaryEntries: [DiaryEntry]
    
    init(
        id: UUID = UUID(),
        name: String,
        ageGroup: AgeGroup,
        capacity: Int
    ) {
        self.id             = id
        self.name           = name
        self.ageGroup       = ageGroup
        self.capacity       = capacity
        self.staffMembers   = []
        self.childPresences = []
        self.ratioBreaches  = []
        self.diaryEntries   = []
    }
    
    // MARK: - Ratio Logic
    var presentStaffCount: Int {
        staffMembers.filter { $0.isPresent }.count
    }
    
    var presentChildCount: Int {
        childPresences.filter { $0.isPresent }.count
    }
    
    // How many children current staff can legally supervise
    var maxAllowedChildren: Int {
        presentStaffCount * ageGroup.requiredRatio
    }
    
    // true = EYFS ratio is breached
    var isRatioBreached: Bool {
        guard presentStaffCount > 0 else { return presentChildCount > 0 }
        return presentChildCount > maxAllowedChildren
    }
    
    // true = getting close to limit (within 2 children)
    var isRatioBorderline: Bool {
        guard !isRatioBreached else { return false }
        return (maxAllowedChildren - presentChildCount) <= 2
    }
    
}
