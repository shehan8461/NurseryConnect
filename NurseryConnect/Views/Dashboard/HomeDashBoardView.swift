import SwiftUI
import SwiftData

struct HomeDashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var rooms: [Room]
    @State private var selectedTab: Int = 0
    @State private var sampleDataLoaded: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if rooms.isEmpty {
                    loadingView
                } else {
                    mainContent
                }
            }
            .navigationTitle("NurseryConnect")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Room Leader identity badge
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.appPrimary)
                        Text("Room Leader")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .onAppear {
            loadSampleDataIfNeeded()
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            
            // Room Header Card
            if let room = rooms.first {
                roomHeaderCard(room: room)
                    .padding(.horizontal)
                    .padding(.top, 16)
            }
            
            // Tab Selector
            tabSelector
                .padding(.horizontal)
                .padding(.top, 16)
            
            // Tab Content
            if let room = rooms.first {
                TabView(selection: $selectedTab) {
                    DiaryReviewSummaryView(room: room)
                        .tag(0)
                    RatioSummaryView(room: room)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
        }
    }
    
    // MARK: - Room Header Card
    private func roomHeaderCard(room: Room) -> some View {
        HStack(spacing: 16) {
            // Room Icon
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.appPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(room.ageGroup.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Today's date
            VStack(alignment: .trailing, spacing: 4) {
                Text(Date().formatted(.dateTime.day().month()))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appPrimary)
                Text(Date().formatted(.dateTime.weekday(.wide)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(
                title: "Diary Review",
                icon: "doc.text.fill",
                badge: rooms.first.map {
                    $0.diaryEntries.filter {
                        $0.status == .pending
                    }.count
                } ?? 0,
                index: 0
            )
            tabButton(
                title: "Staffing Ratio",
                icon: "person.3.fill",
                badge: rooms.first.map {
                    $0.isRatioBreached ? 1 : 0
                } ?? 0,
                index: 1
            )
        }
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private func tabButton(
        title: String,
        icon: String,
        badge: Int,
        index: Int
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                // Badge for pending items
                if badge > 0 {
                    ZStack {
                        Circle()
                            .fill(index == 0 ? Color.appWarning : Color.appDanger)
                            .frame(width: 20, height: 20)
                        Text("\(badge)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .foregroundColor(selectedTab == index ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                selectedTab == index
                ? Color.appPrimary
                : Color.clear
            )
            .cornerRadius(12)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Setting up your room...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Load Sample Data
    private func loadSampleDataIfNeeded() {
        guard !SampleData.hasExistingData(context: modelContext) else {
            return
        }
        SampleData.insertSampleData(context: modelContext)
    }
}

// MARK: - Diary Review Summary (Tab 0)
struct DiaryReviewSummaryView: View {
    let room: Room
    
    var pendingEntries: [DiaryEntry] {
        room.diaryEntries.filter { $0.status == .pending }
            .sorted { $0.submittedAt > $1.submittedAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Stats Row
                HStack(spacing: 12) {
                    statCard(
                        value: "\(pendingEntries.count)",
                        label: "Pending",
                        color: .appWarning,
                        icon: "clock.fill"
                    )
                    statCard(
                        value: "\(room.diaryEntries.filter { $0.status == .countersigned }.count)",
                        label: "Signed",
                        color: .appSuccess,
                        icon: "checkmark.seal.fill"
                    )
                    statCard(
                        value: "\(room.diaryEntries.filter { $0.status == .amendmentRequested }.count)",
                        label: "Amendments",
                        color: .appDanger,
                        icon: "pencil.circle.fill"
                    )
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Pending Entries List
                if pendingEntries.isEmpty {
                    emptyStateView
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Awaiting Your Review")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(pendingEntries) { entry in
                            NavigationLink(
                                destination: EntryDetailView(entry: entry)
                            ) {
                                EntryRowView(entry: entry)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // View All Button
                NavigationLink(
                    destination: PendingEntriesListView(room: room)
                ) {
                    HStack {
                        Text("View All Entries")
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.appPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
    }
    
    private func statCard(
        value: String,
        label: String,
        color: Color,
        icon: String
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.appSuccess)
            Text("All caught up!")
                .font(.headline)
                .fontWeight(.semibold)
            Text("No diary entries pending review")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Ratio Summary (Tab 1)
struct RatioSummaryView: View {
    let room: Room
    
    var ratioColor: Color {
        if room.isRatioBreached    { return .appDanger }
        if room.isRatioBorderline  { return .appWarning }
        return .appSuccess
    }
    
    var ratioStatusText: String {
        if room.isRatioBreached   { return "Ratio Breached" }
        if room.isRatioBorderline { return "Approaching Limit" }
        return "Compliant"
    }
    
    var ratioIcon: String {
        if room.isRatioBreached   { return "exclamationmark.triangle.fill" }
        if room.isRatioBorderline { return "exclamationmark.circle.fill" }
        return "checkmark.shield.fill"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Main Ratio Status Card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: ratioIcon)
                            .font(.title2)
                            .foregroundColor(ratioColor)
                        Text(ratioStatusText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ratioColor)
                        Spacer()
                        Text(room.ageGroup.ratioDescription)
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(ratioColor)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 0) {
                        ratioStatItem(
                            value: "\(room.presentStaffCount)",
                            label: "Staff Present",
                            icon: "person.fill"
                        )
                        Divider().frame(height: 40)
                        ratioStatItem(
                            value: "\(room.presentChildCount)",
                            label: "Children Present",
                            icon: "figure.child"
                        )
                        Divider().frame(height: 40)
                        ratioStatItem(
                            value: "\(room.maxAllowedChildren)",
                            label: "Max Allowed",
                            icon: "checkmark.circle"
                        )
                    }
                }
                .padding(16)
                .background(ratioColor.opacity(0.08))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ratioColor.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 16)
                
                // EYFS Legal Note
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.appPrimary)
                    Text("EYFS legal requirement: \(room.ageGroup.rawValue) — \(room.ageGroup.ratioDescription) staff-to-child ratio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.appPrimary.opacity(0.08))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Navigation Buttons
                VStack(spacing: 10) {
                    NavigationLink(
                        destination: RatioDashboardView(room: room)
                    ) {
                        HStack {
                            Image(systemName: "person.3.fill")
                            Text("Manage Staffing")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                    }
                    
                    NavigationLink(
                        destination: RatioBreachLogView(room: room)
                    ) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                            Text("View Breach Log")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.appPrimary)
                        .padding()
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
    }
    
    private func ratioStatItem(
        value: String,
        label: String,
        icon: String
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeDashboardView()
        .modelContainer(for: [
            Room.self,
            DiaryEntry.self,
            StaffMember.self,
            ChildPresence.self,
            RatioBreach.self,
        ], inMemory: true)
}
