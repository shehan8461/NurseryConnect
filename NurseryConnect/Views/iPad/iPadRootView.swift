import SwiftUI
import SwiftData

// MARK: - Role & Section Enums

enum UserRole: String, CaseIterable {
    case roomLeader = "Room Leader"
    case keyworker  = "Keyworker"

    var icon: String {
        switch self {
        case .roomLeader: return "person.badge.shield.checkmark.fill"
        case .keyworker:  return "person.fill"
        }
    }
}

enum SidebarSection: Hashable {
    case rlDashboard
    case rlDiaryReview
    case rlStaffingRatio
    case rlAnalytics
    case kwDashboard
    case kwNewEntry
    case kwSubmissions
}

// MARK: - iPad Root View

struct iPadRootView: View {

    @State private var selectedRole: UserRole = .roomLeader
    @State private var sidebarSection: SidebarSection? = .rlDashboard
    @State private var selectedEntry: DiaryEntry? = nil

    @Query private var entries: [DiaryEntry]
    @Query(sort: \RatioSession.sessionDate, order: .reverse) private var sessions: [RatioSession]

    var pendingCount: Int {
        entries.filter { $0.status == .pending }.count
    }

    var latestSession: RatioSession? { sessions.first }

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationTitle("NurseryConnect")
        } detail: {
            detailColumn
        }
        .navigationSplitViewStyle(.balanced)
        .tint(.appPrimary)
        .onChange(of: sidebarSection) { _, _ in
            selectedEntry = nil
        }
        // Keyboard shortcut: ⌘N → New Entry (Keyworker)
        .background(
            Button("") {
                if selectedRole == .keyworker {
                    sidebarSection = .kwNewEntry
                }
            }
            .keyboardShortcut("n", modifiers: .command)
            .hidden()
        )
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        List(selection: $sidebarSection) {

            Section("Active Role") {
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        Label(role.rawValue, systemImage: role.icon).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .onChange(of: selectedRole) { _, newRole in
                    sidebarSection = newRole == .roomLeader ? .rlDashboard : .kwDashboard
                    selectedEntry = nil
                }
            }

            if selectedRole == .roomLeader {
                roomLeaderNav
            } else {
                keyworkerNav
            }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    private var roomLeaderNav: some View {
        Section("Overview") {
            Label("Dashboard", systemImage: "house.fill")
                .tag(SidebarSection.rlDashboard)
        }

        Section("Diary Management") {
            HStack {
                Label("Diary Review", systemImage: "book.fill")
                Spacer()
                if pendingCount > 0 { pendingBadge }
            }
            .tag(SidebarSection.rlDiaryReview)
        }

        Section("Staffing") {
            HStack {
                Label("Staffing Ratio", systemImage: "person.2.fill")
                Spacer()
                if latestSession?.ratioStatus == .breached {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.appDanger)
                        .font(.caption)
                }
            }
            .tag(SidebarSection.rlStaffingRatio)
        }

        Section("Insights") {
            Label("Analytics", systemImage: "chart.bar.fill")
                .tag(SidebarSection.rlAnalytics)
        }
    }

    @ViewBuilder
    private var keyworkerNav: some View {
        Section("My Workspace") {
            Label("Dashboard", systemImage: "house.fill")
                .tag(SidebarSection.kwDashboard)
            HStack {
                Label("New Entry", systemImage: "plus.circle.fill")
                Spacer()
                Text("⌘N")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .tag(SidebarSection.kwNewEntry)
            Label("My Submissions", systemImage: "doc.text.fill")
                .tag(SidebarSection.kwSubmissions)
        }
    }

    private var pendingBadge: some View {
        Text("\(pendingCount)")
            .font(.caption2).fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Color.appDanger)
            .clipShape(Capsule())
    }

    // MARK: - Detail Column

    @ViewBuilder
    private var detailColumn: some View {
        switch sidebarSection {
        case .rlDashboard:
            HomeDashboardView()

        case .rlDiaryReview:
            HStack(spacing: 0) {
                EntriesContentView(selectedEntry: $selectedEntry)
                    .frame(width: 300)
                Divider()
                if let entry = selectedEntry {
                    EntryDetailView(entry: entry)
                } else {
                    emptyDetail(icon: "doc.text.magnifyingglass",
                                message: "Select a diary entry to review it here")
                }
            }

        case .kwSubmissions:
            HStack(spacing: 0) {
                EntriesContentView(selectedEntry: $selectedEntry,
                                   filterByKeyworker: "Sarah Johnson")
                    .frame(width: 300)
                Divider()
                if let entry = selectedEntry {
                    EntryDetailView(entry: entry)
                } else {
                    emptyDetail(icon: "doc.text.magnifyingglass",
                                message: "Select a submission to view details")
                }
            }

        case .rlAnalytics:
            AnalyticsDashboardView()

        case .rlStaffingRatio:
            RatioBreachLogView()

        case .kwDashboard:
            NavigationStack {
                KeyworkerHomeView()
            }

        case .kwNewEntry:
            NavigationStack {
                NewEntryFormView()
            }

        case nil:
            emptyDetail(
                icon: "sidebar.left",
                message: "Select a section from the sidebar to get started"
            )
        }
    }

    private func emptyDetail(icon: String, message: String) -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundColor(.appPrimary.opacity(0.25))
                Text(message)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Entries Content View (Content Column List)

struct EntriesContentView: View {

    @Binding var selectedEntry: DiaryEntry?
    var filterByKeyworker: String? = nil

    @Query(sort: \DiaryEntry.submittedAt, order: .reverse)
    private var allEntries: [DiaryEntry]

    @State private var filterStatus: ReviewStatus? = nil

    private var displayedEntries: [DiaryEntry] {
        var result = allEntries
        if let kw = filterByKeyworker {
            result = result.filter { $0.keyworkerName == kw }
        }
        if let fs = filterStatus {
            result = result.filter { $0.status == fs }
        }
        return result
    }

    private var sourceEntries: [DiaryEntry] {
        if let kw = filterByKeyworker {
            return allEntries.filter { $0.keyworkerName == kw }
        }
        return allEntries
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                filterBar
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                if displayedEntries.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text("No entries found")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(selection: $selectedEntry) {
                        ForEach(displayedEntries) { entry in
                            EntryRowView(entry: entry)
                                .tag(entry)
                                .listRowBackground(
                                    selectedEntry?.id == entry.id
                                        ? Color.appPrimary.opacity(0.10)
                                        : Color.appCard
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 4, leading: 12, bottom: 4, trailing: 12))
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle(filterByKeyworker == nil ? "Diary Review" : "My Submissions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", filter: nil, count: sourceEntries.count)
                chip(title: "Pending", filter: .pending, count: sourceEntries.filter { $0.status == .pending }.count)
                chip(title: "Signed", filter: .countersigned, count: sourceEntries.filter { $0.status == .countersigned }.count)
                chip(title: "Amendments", filter: .amendmentRequested, count: sourceEntries.filter { $0.status == .amendmentRequested }.count)
            }
        }
    }

    private func chip(title: String, filter: ReviewStatus?, count: Int) -> some View {
        let active = filterStatus == filter
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { filterStatus = filter }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("\(count)")
                    .font(.caption2).fontWeight(.bold)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(active ? Color.white.opacity(0.25) : Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(active ? Color.appPrimary : Color.appCard)
            .foregroundColor(active ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
