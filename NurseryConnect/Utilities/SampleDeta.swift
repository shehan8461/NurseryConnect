//
//  SampleDeta.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    
    static func insertSampleData(context: ModelContext) {
        
        // MARK: - Create Room
        let room = Room(
            name: "Sunshine Room",
            ageGroup: .twoYear,
            capacity: 12
        )
        
        // MARK: - Staff Members
        let staff1 = StaffMember(
            name: "Sarah Johnson",
            role: "Keyworker",
            isPresent: true,
            arrivedAt: Date()
        )
        let staff2 = StaffMember(
            name: "Emma Wilson",
            role: "Keyworker",
            isPresent: true,
            arrivedAt: Date()
        )
        let staff3 = StaffMember(
            name: "James Brown",
            role: "Keyworker",
            isPresent: false
        )
        
        room.staffMembers = [staff1, staff2, staff3]
        
        // MARK: - Children Present
        let child1 = ChildPresence(
            firstName: "Oliver",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        let child2 = ChildPresence(
            firstName: "Amelia",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        let child3 = ChildPresence(
            firstName: "Noah",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        let child4 = ChildPresence(
            firstName: "Isabella",
            ageGroup: .twoYear,
            isPresent: false
        )
        let child5 = ChildPresence(
            firstName: "Liam",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        let child6 = ChildPresence(
            firstName: "Sophia",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        let child7 = ChildPresence(
            firstName: "Lucas",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        let child8 = ChildPresence(
            firstName: "Mia",
            ageGroup: .twoYear,
            isPresent: true,
            arrivedAt: Date()
        )
        
        room.childPresences = [
            child1, child2, child3, child4,
            child5, child6, child7, child8
        ]
        
        // MARK: - Diary Entries
        let entry1 = DiaryEntry(
            childFirstName: "Oliver",
            keyworkerName: "Sarah Johnson",
            entryType: .activity,
            entryDescription: "Oliver participated in outdoor play today. He showed great enthusiasm during the sandbox activity and interacted well with peers. Linked to EYFS: Physical Development — Moving and Handling.",
            submittedAt: Date().addingTimeInterval(-3600),
            status: .pending
        )
        
        let entry2 = DiaryEntry(
            childFirstName: "Amelia",
            keyworkerName: "Emma Wilson",
            entryType: .meal,
            entryDescription: "Amelia ate most of her lunch — chicken and roast vegetables. She drank approximately 150ml of water. No allergic reactions observed. Good appetite today.",
            submittedAt: Date().addingTimeInterval(-7200),
            status: .pending
        )
        
        let entry3 = DiaryEntry(
            childFirstName: "Noah",
            keyworkerName: "Sarah Johnson",
            entryType: .sleep,
            entryDescription: "Noah napped from 12:30 PM to 1:45 PM. Settled quickly. Slept on his back throughout. No disturbances noted. Woke up happy and refreshed.",
            submittedAt: Date().addingTimeInterval(-5400),
            status: .pending
        )
        
        let entry4 = DiaryEntry(
            childFirstName: "Liam",
            keyworkerName: "Emma Wilson",
            entryType: .incident,
            entryDescription: "Liam tripped during indoor play and sustained a minor graze on his right knee. First aid applied — cleaned and covered with a plaster. Parents to be notified today per EYFS requirements.",
            submittedAt: Date().addingTimeInterval(-1800),
            status: .pending
        )
        
        let entry5 = DiaryEntry(
            childFirstName: "Sophia",
            keyworkerName: "Sarah Johnson",
            entryType: .milestone,
            entryDescription: "Sophia successfully completed a 6-piece puzzle independently today — a significant milestone. She demonstrated excellent concentration and problem-solving skills. EYFS: Mathematics — Shape, Space and Measure.",
            submittedAt: Date().addingTimeInterval(-9000),
            status: .countersigned,
            countersignedAt: Date().addingTimeInterval(-8000),
            countersignedBy: "Room Leader"
        )
        
        let entry6 = DiaryEntry(
            childFirstName: "Lucas",
            keyworkerName: "James Brown",
            entryType: .mood,
            entryDescription: "Lucas arrived unsettled this morning. Cried for approximately 10 minutes at drop-off. Settled after comfort from keyworker. Mood improved significantly by mid-morning. Parents informed at collection.",
            submittedAt: Date().addingTimeInterval(-10800),
            status: .amendmentRequested,
            amendmentNote: "Please add the time Lucas fully settled and who provided comfort support."
        )
        
        room.diaryEntries = [
            entry1, entry2, entry3,
            entry4, entry5, entry6
        ]
        
        // MARK: - Ratio Breaches
        let breach1 = RatioBreach(
            ageGroup: .twoYear,
            staffCount: 1,
            childCount: 6,
            requiredRatio: 4,
            detectedAt: Date().addingTimeInterval(-86400),
            resolvedAt: Date().addingTimeInterval(-84000),
            notes: "Staff member called in sick. Cover arranged within 20 minutes."
        )
        
        room.ratioBreaches = [breach1]
        
        // MARK: - Insert into Context
        context.insert(room)
        
        print("✅ Sample data inserted successfully")
    }
    
    // MARK: - Check if data already exists
    static func hasExistingData(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Room>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count > 0
    }
}
