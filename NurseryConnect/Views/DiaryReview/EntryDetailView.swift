import SwiftUI

struct EntryDetailView: View {
    let entry: DiaryEntry
    
    var statusColor: Color {
        entry.status.color
    }
    
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Entry Header Card
                    headerCard
                    
                    // Description Card
                    descriptionCard
                    
                    // Amendment Note
                    if entry.status == .amendmentRequested,
                       let note = entry.amendmentNote {
                        amendmentNoteCard(note: note)
                    }
                    
                    // Countersigned Info
                    if entry.status == .countersigned,
                       let signedAt = entry.countersignedAt {
                        countersignedCard(signedAt: signedAt)
                    }
                    
                    // Action Buttons
                    if entry.status == .pending {
                        actionButtons
                    }
                    
                    // GDPR Note
                    gdprNote
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Entry Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text(entry.entryType.icon)
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.entryType.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("For: \(entry.childFirstName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: entry.status.icon)
                    Text(entry.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.12))
                .cornerRadius(20)
            }
            
            Divider()
            
            // Meta Info
            HStack {
                infoItem(
                    icon: "person.fill",
                    label: "Keyworker",
                    value: entry.keyworkerName
                )
                Spacer()
                infoItem(
                    icon: "clock.fill",
                    label: "Submitted",
                    value: entry.submittedAt.formatted(
                        .dateTime.hour().minute()
                    )
                )
                Spacer()
                infoItem(
                    icon: "calendar",
                    label: "Date",
                    value: entry.submittedAt.formatted(
                        .dateTime.day().month()
                    )
                )
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
    
    private func infoItem(
        icon: String,
        label: String,
        value: String
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.appPrimary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Description Card
    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Entry Description", systemImage: "doc.text")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            
            Text(entry.entryDescription)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - Amendment Note Card
    private func amendmentNoteCard(note: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                "Amendment Requested",
                systemImage: "pencil.circle.fill"
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.appDanger)
            
            Text(note)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.appDanger.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appDanger.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Countersigned Card
    private func countersignedCard(signedAt: Date) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(.appSuccess)
            VStack(alignment: .leading, spacing: 4) {
                Text("Countersigned by Room Leader")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appSuccess)
                Text(signedAt.formatted(
                    .dateTime.day().month().hour().minute()
                ))
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.appSuccess.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.appSuccess.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 10) {
            NavigationLink(
                destination: CountersignView(entry: entry)
            ) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Countersign Entry")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.appSuccess)
                .cornerRadius(14)
            }
            
            NavigationLink(
                destination: AmendmentRequestView(entry: entry)
            ) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                    Text("Request Amendment")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.appDanger)
                .padding()
                .background(Color.appDanger.opacity(0.1))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            Color.appDanger.opacity(0.3),
                            lineWidth: 1
                        )
                )
            }
        }
    }
    
    // MARK: - GDPR Note
    private var gdprNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .foregroundColor(.appPrimary)
                .font(.caption)
            Text("Child first name only — UK GDPR data minimisation principle applied")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.appPrimary.opacity(0.06))
        .cornerRadius(8)
    }
}
