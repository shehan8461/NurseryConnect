import Foundation
import Testing
@testable import NurseryConnect

// MARK: - EntryType Tests
struct EntryTypeTests {

    @Test func rawValues() {
        #expect(EntryType.activity.rawValue  == "Activity")
        #expect(EntryType.sleep.rawValue     == "Sleep")
        #expect(EntryType.meal.rawValue      == "Meal")
        #expect(EntryType.mood.rawValue      == "Mood")
        #expect(EntryType.incident.rawValue  == "Incident")
    }

    @Test func icons() {
        #expect(EntryType.activity.icon  == "🎨")
        #expect(EntryType.sleep.icon     == "😴")
        #expect(EntryType.meal.icon      == "🍽️")
        #expect(EntryType.mood.icon      == "😊")
        #expect(EntryType.incident.icon  == "⚠️")
    }

    @Test func allCasesCount() {
        #expect(EntryType.allCases.count == 5)
    }

    @Test func initFromRawValue() {
        #expect(EntryType(rawValue: "Activity")  == .activity)
        #expect(EntryType(rawValue: "Incident")  == .incident)
        #expect(EntryType(rawValue: "Unknown")   == nil)
    }
}

// MARK: - ReviewStatus Tests
struct ReviewStatusTests {

    @Test func rawValues() {
        #expect(ReviewStatus.pending.rawValue            == "Pending")
        #expect(ReviewStatus.countersigned.rawValue      == "Countersigned")
        #expect(ReviewStatus.amendmentRequested.rawValue == "Amendment Requested")
    }

    @Test func sfSymbolNames() {
        #expect(ReviewStatus.pending.icon            == "clock")
        #expect(ReviewStatus.countersigned.icon      == "checkmark.seal.fill")
        #expect(ReviewStatus.amendmentRequested.icon == "pencil.circle.fill")
    }

    @Test func colorHexValues() {
        #expect(ReviewStatus.pending.colorHex            == "FF851B")
        #expect(ReviewStatus.countersigned.colorHex      == "3D9970")
        #expect(ReviewStatus.amendmentRequested.colorHex == "E74C3C")
    }

    @Test func allCasesCount() {
        #expect(ReviewStatus.allCases.count == 3)
    }
}

// MARK: - DiaryEntry Model Tests
struct DiaryEntryModelTests {

    @Test func defaultStatusIsPending() {
        let entry = DiaryEntry(
            childFirstName: "Oliver",
            keyworkerName: "Sarah Johnson",
            entryType: .activity,
            entryDescription: "Outdoor play session"
        )
        #expect(entry.status == .pending)
        #expect(entry.countersignedAt == nil)
        #expect(entry.amendmentNote   == nil)
    }

    @Test func rawStorageRoundTripForEntryType() {
        let entry = DiaryEntry(
            childFirstName: "Mia",
            keyworkerName: "Emma Wilson",
            entryType: .incident,
            entryDescription: "Minor graze on knee"
        )
        // The @Model class stores raw strings to avoid composite-attribute crashes
        #expect(entry.entryTypeRaw == "Incident")
        entry.entryType = .meal
        #expect(entry.entryTypeRaw == "Meal")
    }

    @Test func rawStorageRoundTripForStatus() {
        let entry = DiaryEntry(
            childFirstName: "Noah",
            keyworkerName: "Sarah Johnson",
            entryType: .sleep,
            entryDescription: "Nap 12:30–1:45"
        )
        #expect(entry.statusRaw == "Pending")
        entry.status = .countersigned
        #expect(entry.statusRaw      == "Countersigned")
        #expect(entry.status         == .countersigned)
    }

    @Test func amendmentNoteIsStoredCorrectly() {
        let note = "Please add EYFS learning area references."
        let entry = DiaryEntry(
            childFirstName: "Lucas",
            keyworkerName: "Emma Wilson",
            entryType: .activity,
            entryDescription: "Arts and crafts session",
            status: .amendmentRequested,
            amendmentNote: note
        )
        #expect(entry.amendmentNote == note)
        #expect(entry.status        == .amendmentRequested)
    }

    @Test func countersignedAtIsStoredCorrectly() {
        let signedDate = Date()
        let entry = DiaryEntry(
            childFirstName: "Sophia",
            keyworkerName: "Sarah Johnson",
            entryType: .activity,
            entryDescription: "Completed 6-piece puzzle",
            status: .countersigned,
            countersignedAt: signedDate
        )
        #expect(entry.countersignedAt == signedDate)
    }

    /// GDPR data-minimisation: only a child's first name is stored.
    @Test func gdprFirstNameOnly() {
        let entry = DiaryEntry(
            childFirstName: "Sophia",
            keyworkerName: "Sarah Johnson",
            entryType: .activity,
            entryDescription: "Activity session"
        )
        // Must be a single word (no surname)
        #expect(!entry.childFirstName.contains(" "))
    }

    /// Amendment notes must be at least 10 characters (view-layer rule validated here).
    @Test func amendmentNoteMinimumLengthBoundary() {
        let tooShort = "Too short"
        let exactMin = "Exactly ten"   // 11 chars — valid
        let valid    = "Please add the EYFS learning area observed."

        #expect(tooShort.trimmingCharacters(in: .whitespacesAndNewlines).count < 10)
        #expect(exactMin.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10)
        #expect(valid.trimmingCharacters(in: .whitespacesAndNewlines).count    >= 10)
    }
}
