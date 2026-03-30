//
//  HomeDashboardView.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-30.
//

import SwiftUI
import SwiftData

struct HomeDashboardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DiaryEntry]
    @Query private var sessions: [RatioSession]
    @State private var selectedTab: Int = 0
    
    var pendingCount: Int {
        entries.filter { $0.status == .pending }.count
    }
    
    var latestSession: RatioSession? {
        sessions.sorted { $0.sessionDate > $1.sessionDate }.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Room Header
                    roomHeaderCard
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Tab Selector
                    tabSelector
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        DiaryReviewSummaryView(entries: entries)
                            .tag(0)
                        RatioOverviewView(
                            sessions: sessions,
                            latestSession: latestSession
                        )
                        .tag(1)
                    }
                    .tabViewStyle(
                        .page(indexDisplayMode: .never)
                    )
                    .animation(.easeInOut, value: selectedTab)
                }
            }
            .navigationTitle("NurseryConnect")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
            if entries.isEmpty && sessions.isEmpty {
                SampleData.insertSampleData(
                    context: modelContext
                )
            }
        }
    }
    
    // MARK: - Room Header
    private var roomHeaderCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Sunshine Room")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("2 Year Olds")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(Date().formatted(
                    .dateTime.day().month()
                ))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
                Text(Date().formatted(
                    .dateTime.weekday(.wide)
                ))
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(
                title: "Diary Review",
                icon: "doc.text.fill",
                badge: pendingCount,
                index: 0
            )
            tabButton(
                title: "Staffing Ratio",
                icon: "person.3.fill",
                badge: latestSession?.isBreached == true ? 1 : 0,
                index: 1
            )
        }
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.06),
            radius: 6, x: 0, y: 2
        )
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
                if badge > 0 {
                    ZStack {
                        Circle()
                            .fill(index == 0
                                  ? Color.appWarning
                                  : Color.appDanger)
                            .frame(width: 20, height: 20)
                        Text("\(badge)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .foregroundColor(
                selectedTab == index ? .white : .secondary
            )
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
}

// MARK: - Diary Review Summary
struct DiaryReviewSummaryView: View {
    let entries: [DiaryEntry]
    
    var pendingEntries: [DiaryEntry] {
        entries.filter { $0.status == .pending }
            .sorted { $0.submittedAt > $1.submittedAt }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stats Row
                HStack(spacing: 12) {
                    statCard(
                        value: "\(entries.filter { $0.status == .pending }.count)",
                        label: "Pending",
                        color: .appWarning,
                        icon: "clock.fill"
                    )
                    statCard(
                        value: "\(entries.filter { $0.status == .countersigned }.count)",
                        label: "Signed",
                        color: .appSuccess,
                        icon: "checkmark.seal.fill"
                    )
                    statCard(
                        value: "\(entries.filter { $0.status == .amendmentRequested }.count)",
                        label: "Amendments",
                        color: .appDanger,
                        icon: "pencil.circle.fill"
                    )
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Recent Pending
                if !pendingEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Awaiting Review")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(pendingEntries.prefix(3)) { entry in
                            NavigationLink(
                                destination: EntryDetailView(
                                    entry: entry
                                )
                            ) {
                                EntryRowView(entry: entry)
                                    .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.appSuccess)
                        Text("All caught up!")
                            .font(.headline)
                        Text("No entries pending review")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                }
                
                // View All Button
                NavigationLink(
                    destination: PendingEntriesListView()
                ) {
                    HStack {
                        Text("View All Entries")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.appPrimary)
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
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.05),
            radius: 4, x: 0, y: 1
        )
    }
}

// MARK: - Ratio Overview
struct RatioOverviewView: View {
    let sessions: [RatioSession]
    let latestSession: RatioSession?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                if let session = latestSession {
                    // Status Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: session.ratioStatus.icon)
                                .font(.title2)
                                .foregroundColor(
                                    Color(hex: session.ratioStatus.colorHex)
                                )
                            Text(session.ratioStatus.rawValue)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    Color(hex: session.ratioStatus.colorHex)
                                )
                            Spacer()
                            Text(session.ageGroup.ratioDescription)
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(
                                    Color(hex: session.ratioStatus.colorHex)
                                )
                        }
                        Divider()
                        HStack(spacing: 0) {
                            ratioStat(
                                value: "\(session.staffCount)",
                                label: "Staff",
                                icon: "person.fill"
                            )
                            Divider().frame(height: 40)
                            ratioStat(
                                value: "\(session.childCount)",
                                label: "Children",
                                icon: "figure.child"
                            )
                            Divider().frame(height: 40)
                            ratioStat(
                                value: "\(session.maxAllowedChildren)",
                                label: "Max Allowed",
                                icon: "checkmark.circle"
                            )
                        }
                    }
                    .padding(16)
                    .background(
                        Color(hex: session.ratioStatus.colorHex)
                            .opacity(0.08)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                Color(hex: session.ratioStatus.colorHex)
                                    .opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                
                // EYFS Note
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.appPrimary)
                    Text("EYFS legal requirement: 2 Year Olds — 1:4 staff-to-child ratio")
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
                        destination: RatioSessionView()
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
                        destination: RatioBreachLogView()
                    ) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                            Text("View Session Log")
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
    
    private func ratioStat(
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
        .modelContainer(
            for: [DiaryEntry.self, RatioSession.self],
            inMemory: true
        )
}
