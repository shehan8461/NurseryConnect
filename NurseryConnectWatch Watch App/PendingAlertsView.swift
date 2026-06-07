import SwiftUI

/// Displays a count of diary entries pending Room Leader review,
/// giving the Keyworker a quick wrist-glance of outstanding work.
struct PendingAlertsView: View {

    @EnvironmentObject private var store: WatchDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Pending Count Badge
                ZStack {
                    Circle()
                        .fill(store.pendingCount > 0
                              ? Color.orange.opacity(0.18)
                              : Color.green.opacity(0.18))
                        .frame(width: 64, height: 64)
                    Text("\(store.pendingCount)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(store.pendingCount > 0 ? .orange : .green)
                }

                Text(store.pendingCount == 1
                     ? "1 Entry Pending"
                     : "\(store.pendingCount) Entries Pending")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("Awaiting Room Leader countersignature")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Divider()

                // Prompt
                if store.pendingCount > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.caption)
                        Text("Open NurseryConnect on iPhone to review")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("All entries reviewed!")
                            .font(.caption2).fontWeight(.semibold)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Diary")
    }
}

#Preview {
    PendingAlertsView()
        .environmentObject(WatchDataStore())
}
