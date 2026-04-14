import SwiftUI
import SwiftData

struct CountersignView: View {
    let entry: DiaryEntry
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation: Bool = false
    @State private var isCountersigned: Bool = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Top Icon
                    ZStack {
                        Circle()
                            .fill(Color.appSuccess.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.appSuccess)
                    }
                    .padding(.top, 20)
                    
                    Text("Countersign Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You are about to countersign this diary entry. This action creates a permanent legal record under EYFS statutory requirements.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Entry Summary Card
                    entrySummaryCard
                    
                    // Signer Info Card
                    signerInfoCard
                    
                    // Legal Notice
                    legalNotice
                    
                    // Countersign Button
                    if !isCountersigned {
                        Button {
                            showConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Countersign Entry")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appSuccess)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    } else {
                        // Success State
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.appSuccess)
                            Text("Successfully Countersigned!")
                                .font(.headline)
                                .foregroundColor(.appSuccess)
                            Text("Returning to entries...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Countersign")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Confirm Countersignature",
            isPresented: $showConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Countersign") {
                countersignEntry()
            }
        } message: {
            Text("Are you sure? This will finalise the entry as a permanent legal record.")
        }
    }
    
    // MARK: - Entry Summary Card
    private var entrySummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Entry Summary", systemImage: "doc.text.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            
            Divider()
            
            HStack {
                Text("Child:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.childFirstName)
                    .fontWeight(.medium)
            }
            HStack {
                Text("Type:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(entry.entryType.icon) \(entry.entryType.rawValue)")
                    .fontWeight(.medium)
            }
            HStack {
                Text("Keyworker:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.keyworkerName)
                    .fontWeight(.medium)
            }
            HStack {
                Text("Submitted:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.submittedAt.formatted(
                    .dateTime.day().month().hour().minute()
                ))
                .fontWeight(.medium)
            }
        }
        .font(.subheadline)
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - Signer Info Card
    private var signerInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Countersigning As", systemImage: "person.badge.checkmark")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            
            Divider()
            
            HStack {
                Text("Role:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("Room Leader")
                    .fontWeight(.medium)
            }
            HStack {
                Text("Date & Time:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(Date().formatted(
                    .dateTime.day().month().hour().minute()
                ))
                .fontWeight(.medium)
            }
        }
        .font(.subheadline)
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8, x: 0, y: 2
        )
    }
    
    // MARK: - Legal Notice
    private var legalNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.appWarning)
                .font(.subheadline)
            Text("By countersigning, you confirm this entry is accurate and complete. This creates an immutable record for EYFS compliance and Ofsted inspection purposes.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.appWarning.opacity(0.08))
        .cornerRadius(10)
    }
    
    // MARK: - Countersign Action
    private func countersignEntry() {
        entry.status = .countersigned
        entry.countersignedAt = Date()
        try? modelContext.save()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isCountersigned = true
        }

        // Structured concurrency: replaces DispatchQueue.main.asyncAfter
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            await MainActor.run { dismiss() }
        }
    }
}
