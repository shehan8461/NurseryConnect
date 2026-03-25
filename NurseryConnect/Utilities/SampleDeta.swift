import Foundation
import SwiftData

@MainActor
class SampleData {
    
    static func insertSampleData(context: ModelContext) {
        insertDiaryEntries(context: context)
        insertRatioSessions(context: context)
        print("✅ Sample data inserted successfully")
    }
    
    // MARK: - Diary Entries
    private static func insertDiaryEntries(context: ModelContext) {
        let entries = [
            
            // Pending entries
            DiaryEntry(
                childFirstName: "Oliver",
                keyworkerName: "Sarah Johnson",
                entryType: .activity,
                entryDescription: "Oliver joined outdoor play and showed great enthusiasm in the sandbox activity. Strong peer interaction observed throughout the session. Linked to EYFS: Physical Development — Moving and Handling.",
                submittedAt: Date().addingTimeInterval(-3600),
                status: .pending
            ),
            DiaryEntry(
                childFirstName: "Amelia",
                keyworkerName: "Emma Wilson",
                entryType: .meal,
                entryDescription: "Amelia ate most of her lunch — chicken and roast vegetables. Drank approximately 150ml of water. No allergic reactions observed. Good appetite today overall.",
                submittedAt: Date().addingTimeInterval(-7200),
                status: .pending
            ),
            DiaryEntry(
                childFirstName: "Noah",
                keyworkerName: "Sarah Johnson",
                entryType: .sleep,
                entryDescription: "Noah napped from 12:30 PM to 1:45 PM. Settled quickly without distress. Slept on his back throughout the session. No disturbances noted. Woke up happy and refreshed.",
                submittedAt: Date().addingTimeInterval(-5400),
                status: .pending
            ),
            DiaryEntry(
                childFirstName: "Liam",
                keyworkerName: "Emma Wilson",
                entryType: .incident,
                entryDescription: "Liam tripped during indoor play and sustained a minor graze on his right knee. First aid was applied immediately — area cleaned and covered with a plaster. Parents notified same day per EYFS statutory requirements.",
                submittedAt: Date().addingTimeInterval(-1800),
                status: .pending
            ),
            DiaryEntry(
                childFirstName: "Mia",
                keyworkerName: "Sarah Johnson",
                entryType: .mood,
                entryDescription: "Mia arrived happy and settled quickly. Engaged well during morning circle time. Showed excitement during the singing session. Positive interactions with peers throughout the day.",
                submittedAt: Date().addingTimeInterval(-2700),
                status: .pending
            ),
            
            // Countersigned entries
            DiaryEntry(
                childFirstName: "Sophia",
                keyworkerName: "Sarah Johnson",
                entryType: .activity,
                entryDescription: "Sophia successfully completed a 6-piece puzzle independently — a significant milestone. Demonstrated excellent concentration and problem-solving skills. EYFS: Mathematics — Shape, Space and Measure.",
                submittedAt: Date().addingTimeInterval(-9000),
                status: .countersigned,
                countersignedAt: Date().addingTimeInterval(-8000)
            ),
            DiaryEntry(
                childFirstName: "Oliver",
                keyworkerName: "Emma Wilson",
                entryType: .sleep,
                entryDescription: "Oliver napped from 1:00 PM to 2:00 PM. Settled well. Slept on back. No issues noted during rest period.",
                submittedAt: Date().addingTimeInterval(-18000),
                status: .countersigned,
                countersignedAt: Date().addingTimeInterval(-17000)
            ),
            
            // Amendment requested entries
            DiaryEntry(
                childFirstName: "Lucas",
                keyworkerName: "Emma Wilson",
                entryType: .activity,
                entryDescription: "Lucas participated in arts and crafts session.",
                submittedAt: Date().addingTimeInterval(-10800),
                status: .amendmentRequested,
                amendmentNote: "Please add more detail about Lucas's engagement level, what he created, and any EYFS learning areas observed during the session."
            ),
            DiaryEntry(
                childFirstName: "Amelia",
                keyworkerName: "Sarah Johnson",
                entryType: .incident,
                entryDescription: "Amelia had a fall.",
                submittedAt: Date().addingTimeInterval(-14400),
                status: .amendmentRequested,
                amendmentNote: "Incident report is incomplete. Please add: exact time, location in room, nature of injury, first aid given, and witness names. EYFS requires same-day full documentation."
            ),
        ]
        
        entries.forEach { context.insert($0) }
    }
    
    // MARK: - Ratio Sessions
    private static func insertRatioSessions(context: ModelContext) {
        let sessions = [
            
            // Today - compliant
            RatioSession(
                roomName: "Sunshine Room",
                ageGroup: .twoYear,
                staffCount: 2,
                childCount: 6,
                sessionDate: Date(),
                notes: "Normal morning session. All staff present."
            ),
            
            // Yesterday - breached then resolved
            RatioSession(
                roomName: "Sunshine Room",
                ageGroup: .twoYear,
                staffCount: 1,
                childCount: 6,
                sessionDate: Date().addingTimeInterval(-86400),
                notes: "Staff member called in sick unexpectedly. Cover arranged within 20 minutes.",
                resolvedAt: Date().addingTimeInterval(-85200)
            ),
            
            // 2 days ago - borderline
            RatioSession(
                roomName: "Sunshine Room",
                ageGroup: .twoYear,
                staffCount: 2,
                childCount: 7,
                sessionDate: Date().addingTimeInterval(-172800),
                notes: "Afternoon session. Approaching ratio limit — monitored closely."
            ),
            
            // 3 days ago - compliant
            RatioSession(
                roomName: "Sunshine Room",
                ageGroup: .twoYear,
                staffCount: 3,
                childCount: 10,
                sessionDate: Date().addingTimeInterval(-259200),
                notes: "Full staff morning. Extra children present for settling visits."
            ),
            
            // 4 days ago - breached
            RatioSession(
                roomName: "Sunshine Room",
                ageGroup: .twoYear,
                staffCount: 1,
                childCount: 5,
                sessionDate: Date().addingTimeInterval(-345600),
                notes: "Two staff members at training. Temporary breach logged and escalated to Setting Manager.",
                resolvedAt: Date().addingTimeInterval(-344000)
            ),
        ]
        
        sessions.forEach { context.insert($0) }
    }
    
    // MARK: - Check existing data
    static func hasExistingData(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<DiaryEntry>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count > 0
    }
}
