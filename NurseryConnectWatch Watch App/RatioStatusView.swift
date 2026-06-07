import SwiftUI

/// Shows the current EYFS staffing ratio compliance status on the Apple Watch.
struct RatioStatusView: View {

    @EnvironmentObject private var store: WatchDataStore

    private var statusColor: Color {
        switch store.ratioStatus {
        case "Ratio Breached":      return .red
        case "Approaching Limit":   return .orange
        default:                    return .green
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var statusIcon: String {
        switch store.ratioStatus {
        case "Ratio Breached":      return "exclamationmark.triangle.fill"
        case "Approaching Limit":   return "exclamationmark.circle.fill"
        default:                    return "checkmark.shield.fill"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {

                // Status Badge
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.18))
                        .frame(width: 64, height: 64)
                    Image(systemName: statusIcon)
                        .font(.system(size: 28))
                        .foregroundColor(statusColor)
                }

                Text(store.ratioStatus)
                    .font(.headline)
                    .foregroundColor(statusColor)
                    .multilineTextAlignment(.center)

                Divider()

                // Staffing Details
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(store.staffCount)")
                            .font(.title3).fontWeight(.bold)
                        Text("Staff")
                            .font(.caption2).foregroundColor(.secondary)
                    }
                    VStack(spacing: 2) {
                        Text("\(store.childCount)")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(statusColor)
                        Text("Children")
                            .font(.caption2).foregroundColor(.secondary)
                    }
                }

                // Last updated
                if let updated = store.lastUpdated {
                    Text("Updated \(relativeTime(updated))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("Waiting for iPhone…")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Alert banner if breached
                if store.isBreached {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                        Text("Ratio Breach – Act Now")
                            .font(.caption2).fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Ratio")
    }
}

#Preview {
    RatioStatusView()
        .environmentObject(WatchDataStore())
}
