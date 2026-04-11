import SwiftUI
import SwiftData

struct RatioSessionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var sessions: [RatioSession]
    
    @State private var staffCount: Int = 2
    @State private var childCount: Int = 6
    @State private var selectedAgeGroup: AgeGroup = .twoYear
    @State private var notes: String = ""
    @State private var showSaveConfirmation: Bool = false
    @State private var isSaved: Bool = false
    
    // Computed ratio values
    var maxAllowedChildren: Int {
        staffCount * selectedAgeGroup.requiredRatio
    }
    
    var isBreached: Bool {
        guard staffCount > 0 else { return childCount > 0 }
        return childCount > maxAllowedChildren
    }
    
    var isBorderline: Bool {
        guard !isBreached else { return false }
        return (maxAllowedChildren - childCount) <= 2
    }
    
    var ratioStatus: RatioStatus {
        if isBreached   { return .breached }
        if isBorderline { return .borderline }
        return .compliant
    }
    
    var statusColor: Color {
        ratioStatus.color
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Live Ratio Status Card
                    ratioStatusCard
                        .padding(.top, 16)
                    
                    // Age Group Picker
                    ageGroupPicker
                    
                    // Staff Counter
                    counterCard(
                        title: "Staff Present",
                        subtitle: "Keyworkers currently in room",
                        icon: "person.fill",
                        color: .appPrimary,
                        count: $staffCount,
                        minimum: 0,
                        maximum: 20
                    )
                    
                    // Children Counter
                    counterCard(
                        title: "Children Present",
                        subtitle: "Children currently in room",
                        icon: "figure.child",
                        color: statusColor,
                        count: $childCount,
                        minimum: 0,
                        maximum: 50
                    )
                    
                    // EYFS Legal Info
                    eyfsInfoCard
                    
                    // Notes Field
                    notesCard
                    
                    // Save Button
                    if !isSaved {
                        Button {
                            showSaveConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Save Session Record")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    } else {
                        savedSuccessView
                    }
                    
                    // View Log Button
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
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Staffing Ratio")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Save Session Record",
            isPresented: $showSaveConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                saveSession()
            }
        } message: {
            Text("This will save the current staffing ratio as an official session record.")
        }
    }
    
    // MARK: - Ratio Status Card
    private var ratioStatusCard: some View {
        VStack(spacing: 14) {
            // Status Header
            HStack {
                Image(systemName: ratioStatus.icon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                Text(ratioStatus.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                Spacer()
                Text(selectedAgeGroup.ratioDescription)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(statusColor)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusColor)
                        .frame(
                            width: maxAllowedChildren > 0
                            ? min(
                                CGFloat(childCount) /
                                CGFloat(maxAllowedChildren) *
                                geometry.size.width,
                                geometry.size.width
                            )
                            : 0,
                            height: 12
                        )
                        .animation(.easeInOut, value: childCount)
                }
            }
            .frame(height: 12)
            
            // Stats Row
            HStack(spacing: 0) {
                ratioStatItem(
                    value: "\(staffCount)",
                    label: "Staff Present",
                    icon: "person.fill"
                )
                Divider().frame(height: 40)
                ratioStatItem(
                    value: "\(childCount)",
                    label: "Children",
                    icon: "figure.child"
                )
                Divider().frame(height: 40)
                ratioStatItem(
                    value: "\(maxAllowedChildren)",
                    label: "Max Allowed",
                    icon: "checkmark.circle"
                )
            }
        }
        .padding(16)
        .background(statusColor.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut, value: ratioStatus)
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
    
    // MARK: - Age Group Picker
    private var ageGroupPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Age Group", systemImage: "person.3.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            
            Picker("Age Group", selection: $selectedAgeGroup) {
                ForEach(AgeGroup.allCases, id: \.self) { group in
                    Text(group.rawValue).tag(group)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - Counter Card
    private func counterCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        count: Binding<Int>,
        minimum: Int,
        maximum: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                // Minus Button
                Button {
                    if count.wrappedValue > minimum {
                        count.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(
                            count.wrappedValue > minimum
                            ? color : .secondary.opacity(0.3)
                        )
                }
                
                Spacer()
                
                // Count Display
                Text("\(count.wrappedValue)")
                    .font(.system(
                        size: 48,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundColor(color)
                    .animation(.easeInOut, value: count.wrappedValue)
                
                Spacer()
                
                // Plus Button
                Button {
                    if count.wrappedValue < maximum {
                        count.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(
                            count.wrappedValue < maximum
                            ? color : .secondary.opacity(0.3)
                        )
                }
            }
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - EYFS Info Card
    private var eyfsInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "EYFS Legal Ratios",
                systemImage: "scalemass.fill"
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.appPrimary)
            
            Divider()
            
            ForEach(AgeGroup.allCases, id: \.self) { group in
                HStack {
                    Text(group.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(group.ratioDescription)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(
                            group == selectedAgeGroup
                            ? .appPrimary : .secondary
                        )
                }
            }
        }
        .padding(16)
        .background(Color.appPrimary.opacity(0.06))
        .cornerRadius(16)
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Session Notes (Optional)", systemImage: "note.text")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            
            TextEditor(text: $notes)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.appBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.secondary.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - Saved Success View
    private var savedSuccessView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.appSuccess)
            Text("Session Saved!")
                .font(.headline)
                .foregroundColor(.appSuccess)
            Text("Record added to session log")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Save Action
    private func saveSession() {
        let session = RatioSession(
            roomName: "Sunshine Room",
            ageGroup: selectedAgeGroup,
            staffCount: staffCount,
            childCount: childCount,
            sessionDate: Date(),
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(session)
        try? modelContext.save()
        
        withAnimation {
            isSaved = true
        }
    }
}

#Preview {
    NavigationStack {
        RatioSessionView()
            .modelContainer(
                for: [DiaryEntry.self, RatioSession.self],
                inMemory: true
            )
    }
}
