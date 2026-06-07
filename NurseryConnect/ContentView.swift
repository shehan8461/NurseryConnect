
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass

    @Query private var entries: [DiaryEntry]
    @Query(sort: \RatioSession.sessionDate, order: .reverse) private var sessions: [RatioSession]

    private var pendingCount:   Int          { entries.filter { $0.status == .pending }.count }
    private var latestSession:  RatioSession? { sessions.first }

    var body: some View {
        Group {
            if sizeClass == .regular {
                // iPad / large display: multi-column NavigationSplitView
                iPadRootView()
            } else {
                // iPhone: existing stack-based navigation (Assignment 1 layout)
                HomeDashboardView()
            }
        }
        .onAppear {
            if !SampleData.hasExistingData(context: modelContext) {
                SampleData.insertSampleData(context: modelContext)
                try? modelContext.save()
            }
            sendWatchUpdate()
        }
        .onChange(of: pendingCount)    { _, _ in sendWatchUpdate() }
        .onChange(of: sessions.count)  { _, _ in sendWatchUpdate() }
    }

    private func sendWatchUpdate() {
        let currentEntries = (try? modelContext.fetch(FetchDescriptor<DiaryEntry>())) ?? entries
        let currentSessions = (
            try? modelContext.fetch(
                FetchDescriptor<RatioSession>(
                    sortBy: [SortDescriptor(\.sessionDate, order: .reverse)]
                )
            )
        ) ?? sessions

        let currentPendingCount = currentEntries.filter { $0.status == .pending }.count
        let currentLatestSession = currentSessions.first

        WatchConnectivityManager.shared.sendUpdate(
            pendingCount: currentPendingCount,
            ratioStatus:  currentLatestSession?.ratioStatus ?? .compliant,
            childCount:   currentLatestSession?.childCount  ?? 0,
            staffCount:   currentLatestSession?.staffCount  ?? 0
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                DiaryEntry.self,
                RatioSession.self,
            ],
            inMemory: true
        )
}
