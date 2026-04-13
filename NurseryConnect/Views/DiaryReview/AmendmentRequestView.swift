import SwiftUI
import SwiftData

struct AmendmentRequestView: View {
    let entry: DiaryEntry
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var amendmentNote: String = ""
    @State private var showConfirmation: Bool = false
    @State private var isSubmitted: Bool = false
    @State private var showError: Bool = false
    
    var isNoteValid: Bool {
        amendmentNote.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).count >= 10
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Top Icon
                    ZStack {
                        Circle()
                            .fill(Color.appDanger.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.appDanger)
                    }
                    .padding(.top, 20)
                    
                    Text("Request Amendment")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Provide clear instructions to the keyworker explaining what needs to be corrected or added.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Entry Summary
                    entrySummaryCard
                    
                    // Amendment Input
                    amendmentInputCard
                    
                    // Guidance Card
                    guidanceCard
                    
                    // Submit Button
                    if !isSubmitted {
                        Button {
                            if isNoteValid {
                                showConfirmation = true
                            } else {
                                showError = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Amendment Request")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isNoteValid
                                ? Color.appDanger
                                : Color.gray.opacity(0.4)
                            )
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    } else {
                        // Success State
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.appDanger)
                            Text("Amendment Request Sent!")
                                .font(.headline)
                                .foregroundColor(.appDanger)
                            Text("Keyworker will be notified")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Request Amendment")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Send Amendment Request",
            isPresented: $showConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Send Request") {
                submitAmendment()
            }
        } message: {
            Text("This will notify the keyworker to update their entry.")
        }
        .alert(
            "Note Too Short",
            isPresented: $showError
        ) {
            Button("OK") {}
        } message: {
            Text("Please provide at least 10 characters explaining the amendment needed.")
        }
    }
    
    // MARK: - Entry Summary Card
    private var entrySummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Entry Being Reviewed", systemImage: "doc.text")
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
    
    // MARK: - Amendment Input
    private var amendmentInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                "Amendment Instructions",
                systemImage: "pencil.line"
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.appPrimary)
            
            TextEditor(text: $amendmentNote)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color.appBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            amendmentNote.isEmpty
                            ? Color.secondary.opacity(0.2)
                            : Color.appPrimary.opacity(0.4),
                            lineWidth: 1
                        )
                )
            
            HStack {
                Text("Minimum 10 characters")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(amendmentNote.count) characters")
                    .font(.caption2)
                    .foregroundColor(
                        isNoteValid ? .appSuccess : .secondary
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
    
    // MARK: - Guidance Card
    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Amendment Guidance", systemImage: "info.circle.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.appPrimary)
            
            Text("• Be specific about what information is missing")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("• Reference EYFS requirements where applicable")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("• For incidents: ensure time, location, and witnesses are included")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.appPrimary.opacity(0.06))
        .cornerRadius(10)
    }
    
    // MARK: - Submit Action
    private func submitAmendment() {
        entry.status = .amendmentRequested
        entry.amendmentNote = amendmentNote
            .trimmingCharacters(in: .whitespacesAndNewlines)
        try? modelContext.save()
        
        withAnimation {
            isSubmitted = true
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.5
        ) {
            dismiss()
        }
    }
}
