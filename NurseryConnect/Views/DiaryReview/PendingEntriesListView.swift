import SwiftUI
import SwiftData

struct PendingEntriesListView: View {
    
    @Query private var entries: [DiaryEntry]
    @State private var selectedFilter: ReviewStatus? = nil
    
    var filteredEntries: [DiaryEntry] {
        guard let filter = selectedFilter else {
            return entries.sorted {
                $0.submittedAt > $1.submittedAt
            }
        }
        return entries
            .filter { $0.status == filter }
            .sorted { $0.submittedAt > $1.submittedAt }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filter Bar
                filterBar
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // Entries List
                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredEntries) { entry in
                                NavigationLink(
                                    destination: EntryDetailView(
                                        entry: entry
                                    )
                                ) {
                                    EntryRowView(entry: entry)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("All Diary Entries")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(
                    title: "All",
                    count: entries.count,
                    filter: nil
                )
                filterChip(
                    title: "Pending",
                    count: entries.filter {
                        $0.status == .pending
                    }.count,
                    filter: .pending
                )
                filterChip(
                    title: "Signed",
                    count: entries.filter {
                        $0.status == .countersigned
                    }.count,
                    filter: .countersigned
                )
                filterChip(
                    title: "Amendments",
                    count: entries.filter {
                        $0.status == .amendmentRequested
                    }.count,
                    filter: .amendmentRequested
                )
            }
        }
    }
    
    private func filterChip(
        title: String,
        count: Int,
        filter: ReviewStatus?
    ) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedFilter = filter
            }
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        selectedFilter == filter
                        ? Color.white.opacity(0.3)
                        : Color.appPrimary.opacity(0.1)
                    )
                    .cornerRadius(8)
            }
            .foregroundColor(
                selectedFilter == filter
                ? .white : .appPrimary
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                selectedFilter == filter
                ? Color.appPrimary
                : Color.appCard
            )
            .cornerRadius(20)
            .shadow(
                color: .black.opacity(0.05),
                radius: 3, x: 0, y: 1
            )
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.4))
            Text("No entries found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Try selecting a different filter")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        PendingEntriesListView()
            .modelContainer(
                for: [DiaryEntry.self, RatioSession.self],
                inMemory: true
            )
    }
}
