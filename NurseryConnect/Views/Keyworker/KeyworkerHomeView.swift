import SwiftUI
import SwiftData

struct KeyworkerHomeView: View {

    // In a real app the keyworker name would come from an auth session.
    // For demo purposes a fixed name is used that matches the sample data.
    private let keyworkerName = "Sarah Johnson"

    @Query(sort: \DiaryEntry.submittedAt, order: .reverse)
    private var allEntries: [DiaryEntry]

    private var myEntries:         [DiaryEntry] { allEntries.filter { $0.keyworkerName == keyworkerName } }
    private var pendingCount:      Int          { myEntries.filter { $0.status == .pending }.count }
    private var countersignedCount:Int          { myEntries.filter { $0.status == .countersigned }.count }
    private var amendmentCount:    Int          { myEntries.filter { $0.status == .amendmentRequested }.count }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    welcomeCard
                    statsRow
                    if amendmentCount > 0 { amendmentAlert }
                    if !myEntries.isEmpty { recentSubmissions }
                    eyfsReminder
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .navigationTitle("My Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: – Welcome Card

    private var welcomeCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.14))
                    .frame(width: 54, height: 54)
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline).foregroundColor(.secondary)
                Text(keyworkerName)
                    .font(.title3).fontWeight(.bold)
                Text("Keyworker · Sunshine Room")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Date().formatted(.dateTime.weekday(.wide)))
                    .font(.caption2).foregroundColor(.secondary)
                Text(Date().formatted(.dateTime.day().month()))
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.appPrimary)
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: – Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard("My Entries",  "\(myEntries.count)",      "doc.text.fill",           .appPrimary)
            statCard("Pending",     "\(pendingCount)",          "clock.fill",              .appWarning)
            statCard("Countersigned", "\(countersignedCount)",  "checkmark.seal.fill",     .appSuccess)
            statCard("Amendments",  "\(amendmentCount)",        "pencil.circle.fill",      .appDanger)
        }
    }

    private func statCard(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color).font(.subheadline)
            Text(value).font(.title3).fontWeight(.bold)
            Text(title).font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }

    // MARK: – Amendment Alert

    private var amendmentAlert: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.appDanger)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(amendmentCount) entr\(amendmentCount == 1 ? "y" : "ies") need\(amendmentCount == 1 ? "s" : "") amendment")
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.appDanger)
                Text("Review the amendment notes in My Submissions and resubmit.")
                    .font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.appDanger.opacity(0.08))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appDanger.opacity(0.25), lineWidth: 1))
    }

    // MARK: – Recent Submissions

    private var recentSubmissions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Submissions")
                    .font(.headline).fontWeight(.semibold)
                Spacer()
                Text("Last \(min(myEntries.count, 3)) of \(myEntries.count)")
                    .font(.caption).foregroundColor(.secondary)
            }
            ForEach(Array(myEntries.prefix(3))) { entry in
                EntryRowView(entry: entry)
            }
        }
    }

    // MARK: – EYFS Reminder

    private var eyfsReminder: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.appPrimary)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("EYFS Good Practice")
                    .font(.caption).fontWeight(.semibold).foregroundColor(.appPrimary)
                Text("All diary entries must be factual, objective, and submitted on the same day as the observation. Use children's first names only (GDPR).")
                    .font(.caption2).foregroundColor(.secondary).lineSpacing(3)
            }
        }
        .padding(12)
        .background(Color.appPrimary.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appPrimary.opacity(0.18), lineWidth: 1))
    }
}
