import SwiftUI
import SwiftData
import Charts

// MARK: - Chart Data Models

struct EntryTypePoint: Identifiable {
    let id = UUID()
    let type: EntryType
    let count: Int
}

struct StatusPoint: Identifiable {
    let id = UUID()
    let status: ReviewStatus
    let count: Int
}

struct RatioPoint: Identifiable {
    let id = UUID()
    let sessionLabel: String
    let childCount: Int
    let maxAllowed: Int
    let statusColor: Color
    let statusLabel: String
}

// MARK: - Analytics Dashboard View

struct AnalyticsDashboardView: View {

    @Query(sort: \DiaryEntry.submittedAt, order: .reverse)
    private var entries: [DiaryEntry]

    @Query(sort: \RatioSession.sessionDate, order: .reverse)
    private var sessions: [RatioSession]

    private var entryTypeData: [EntryTypePoint] {
        EntryType.allCases.map { type in
            EntryTypePoint(type: type, count: entries.filter { $0.entryType == type }.count)
        }
    }

    private var statusData: [StatusPoint] {
        ReviewStatus.allCases.map { status in
            StatusPoint(status: status, count: entries.filter { $0.status == status }.count)
        }
    }

    private var ratioData: [RatioPoint] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return Array(sessions.prefix(8)).reversed().enumerated().map { index, session in
            RatioPoint(
                sessionLabel: "\(index + 1). \(formatter.string(from: session.sessionDate))",
                childCount: session.childCount,
                maxAllowed: max(session.maxAllowedChildren, 1),
                statusColor: session.ratioStatus.color,
                statusLabel: session.ratioStatus.rawValue
            )
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    summaryRow
                        .padding(.top, 16)

                    // Chart 1 – Entry Type Distribution
                    chartCard(
                        title: "Entry Type Distribution",
                        subtitle: "Count of diary entries per observation category"
                    ) {
                        Chart(entryTypeData) { point in
                            BarMark(
                                x: .value("Type", point.type.rawValue),
                                y: .value("Count", point.count)
                            )
                            .foregroundStyle(by: .value("Type", point.type.rawValue))
                            .cornerRadius(6)
                            .annotation(position: .top) {
                                if point.count > 0 {
                                    Text("\(point.count)")
                                        .font(.caption2).fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisValueLabel().font(.caption2)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                                AxisGridLine()
                                AxisValueLabel().font(.caption2)
                            }
                        }
                        .frame(height: 200)
                    }

                    // Chart 2 – Entry Status Overview (Sector Chart)
                    chartCard(
                        title: "Entry Status Overview",
                        subtitle: "Review status distribution across all diary entries"
                    ) {
                        HStack(alignment: .top, spacing: 24) {
                            if #available(iOS 17, *) {
                                Chart(statusData) { point in
                                    SectorMark(
                                        angle: .value("Count", max(point.count, 1)),
                                        innerRadius: .ratio(0.52),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(point.status.color)
                                    .opacity(0.85)
                                }
                                .frame(width: 160, height: 160)
                            } else {
                                // Fallback for iOS 16
                                Chart(statusData) { point in
                                    BarMark(
                                        x: .value("Count", point.count),
                                        y: .value("Status", point.status.rawValue)
                                    )
                                    .foregroundStyle(point.status.color)
                                    .cornerRadius(4)
                                }
                                .frame(height: 100)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(statusData) { point in
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(point.status.color)
                                            .frame(width: 12, height: 12)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(point.status.rawValue)
                                                .font(.caption).fontWeight(.semibold)
                                            Text("\(point.count) entries")
                                                .font(.caption2).foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            Spacer()
                        }
                    }

                    // Chart 3 – Ratio Session Compliance
                    chartCard(
                        title: "Ratio Compliance History",
                        subtitle: "Children present vs maximum allowed across recent sessions"
                    ) {
                        if ratioData.isEmpty {
                            Text("No session data recorded yet")
                                .foregroundColor(.secondary)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                        } else {
                            Chart {
                                ForEach(ratioData) { point in
                                    // Max allowed bar (background reference)
                                    BarMark(
                                        x: .value("Session", point.sessionLabel),
                                        y: .value("Max Allowed", point.maxAllowed)
                                    )
                                    .foregroundStyle(Color.secondary.opacity(0.12))
                                    .cornerRadius(4)

                                    // Actual children bar
                                    BarMark(
                                        x: .value("Session", point.sessionLabel),
                                        y: .value("Children", point.childCount)
                                    )
                                    .foregroundStyle(point.statusColor.opacity(0.85))
                                    .cornerRadius(4)
                                    .annotation(position: .top, alignment: .center) {
                                        Text("\(point.childCount)")
                                            .font(.system(size: 9)).fontWeight(.bold)
                                            .foregroundColor(point.statusColor)
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisValueLabel()
                                        .font(.system(size: 9))
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel().font(.caption2)
                                }
                            }
                            .frame(height: 220)

                            // Legend
                            HStack(spacing: 16) {
                                legendItem(color: .appSuccess, label: "Compliant")
                                legendItem(color: .appWarning, label: "Borderline")
                                legendItem(color: .appDanger, label: "Breached")
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 12, height: 8)
                                    Text("Max Allowed")
                                        .font(.caption2).foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Summary Cards

    private var summaryRow: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            summaryCard("Total Entries", "\(entries.count)", "doc.text.fill", .appPrimary)
            summaryCard("Pending", "\(entries.filter { $0.status == .pending }.count)", "clock.fill", .appWarning)
            summaryCard("Countersigned", "\(entries.filter { $0.status == .countersigned }.count)", "checkmark.seal.fill", .appSuccess)
            summaryCard("Ratio Breaches", "\(sessions.filter { $0.ratioStatus == .breached }.count)", "exclamationmark.triangle.fill", .appDanger)
        }
    }

    private func summaryCard(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.title2).fontWeight(.bold)
            Text(title)
                .font(.caption2).foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .cornerRadius(14)
    }

    // MARK: - Chart Card

    private func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline).fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption).foregroundColor(.secondary)
            }
            content()
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 8)
            Text(label)
                .font(.caption2).foregroundColor(.secondary)
        }
    }
}
