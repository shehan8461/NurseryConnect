import SwiftUI
import SwiftData

struct RatioBreachLogView: View {
    
    @Query(sort: \RatioSession.sessionDate, order: .reverse)
    private var sessions: [RatioSession]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        // Summary Stats
                        summaryStatsRow
                            .padding(.top, 16)
                        
                        // Session List
                        ForEach(sessions) { session in
                            sessionCard(session: session)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Session Log")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Summary Stats
    private var summaryStatsRow: some View {
        HStack(spacing: 10) {
            miniStat(
                value: "\(sessions.count)",
                label: "Total",
                color: .appPrimary
            )
            miniStat(
                value: "\(sessions.filter { $0.ratioStatus == .compliant }.count)",
                label: "Compliant",
                color: .appSuccess
            )
            miniStat(
                value: "\(sessions.filter { $0.ratioStatus == .borderline }.count)",
                label: "Borderline",
                color: .appWarning
            )
            miniStat(
                value: "\(sessions.filter { $0.ratioStatus == .breached }.count)",
                label: "Breached",
                color: .appDanger
            )
        }
    }
    
    private func miniStat(
        value: String,
        label: String,
        color: Color
    ) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
    
    // MARK: - Session Card
    private func sessionCard(
        session: RatioSession
    ) -> some View {
        // ✅ Replace with this
        let statusColor: Color = {
            switch session.ratioStatus {
            case .compliant:  return .appSuccess
            case .borderline: return .appWarning
            case .breached:   return .appDanger
            }
        }()
        return VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                // Status Badge
                HStack(spacing: 6) {
                    Image(systemName: session.ratioStatus.icon)
                        .font(.caption)
                    Text(session.ratioStatus.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.12))
                .cornerRadius(20)
                
                Spacer()
                
                // Date
                Text(session.sessionDate.formatted(
                    .dateTime.day().month().year()
                ))
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Stats Row
            HStack(spacing: 0) {
                sessionStat(
                    value: "\(session.staffCount)",
                    label: "Staff",
                    icon: "person.fill"
                )
                sessionStat(
                    value: "\(session.childCount)",
                    label: "Children",
                    icon: "figure.child"
                )
                sessionStat(
                    value: "\(session.maxAllowedChildren)",
                    label: "Max",
                    icon: "checkmark.circle"
                )
                sessionStat(
                    value: session.ageGroup.ratioDescription,
                    label: "Ratio",
                    icon: "scalemass"
                )
            }
            
            // Notes
            if let notes = session.notes {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.top, 4)
            }
            
            // Resolved Badge
            if session.isResolved,
               let resolvedAt = session.resolvedAt {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.appSuccess)
                    Text("Resolved at \(resolvedAt.formatted(.dateTime.hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.appSuccess)
                }
            }
        }
        .padding(14)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.05),
            radius: 4, x: 0, y: 1
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    statusColor.opacity(
                        session.ratioStatus == .compliant ? 0 : 0.3
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private func sessionStat(
        value: String,
        label: String,
        icon: String
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.4))
            Text("No sessions recorded yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Save a session from the Staffing Ratio screen")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    NavigationStack {
        RatioBreachLogView()
            .modelContainer(
                for: [DiaryEntry.self, RatioSession.self],
                inMemory: true
            )
    }
}
