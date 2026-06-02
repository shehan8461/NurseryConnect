import SwiftUI
import SwiftData

struct NewEntryFormView: View {

    @Environment(\.modelContext) private var modelContext

    // In a real app this comes from an authenticated session.
    private let keyworkerName = "Sarah Johnson"

    @State private var childFirstName:   String    = ""
    @State private var selectedType:     EntryType = .activity
    @State private var description:      String    = ""
    @State private var showValidationAlert: Bool   = false
    @State private var isSaved:          Bool      = false

    private var charCount: Int { description.trimmingCharacters(in: .whitespacesAndNewlines).count }

    private var isValid: Bool {
        !childFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && charCount >= 20
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if isSaved {
                successView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        entryHeaderCard
                        childNameField
                        entryTypePicker
                        descriptionField
                        eyfsGuidance
                        submitButton
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle("New Diary Entry")
        .navigationBarTitleDisplayMode(.large)
        .alert("Incomplete Entry", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter the child's first name and a description of at least 20 characters.")
        }
    }

    // MARK: – Entry Header Card

    private var entryHeaderCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.title3).foregroundColor(.appPrimary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("New Diary Entry")
                    .font(.headline).fontWeight(.bold)
                Text("Keyworker: \(keyworkerName)")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(Date().formatted(.dateTime.hour().minute()))
                .font(.subheadline).fontWeight(.semibold).foregroundColor(.appPrimary)
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: – Child's First Name

    private var childNameField: some View {
        fieldCard(title: "Child's First Name", subtitle: "First name only — GDPR compliant", icon: "person.fill") {
            TextField("e.g. Oliver", text: $childFirstName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .font(.body)
                .padding(.top, 4)
        }
    }

    // MARK: – Entry Type Picker

    private var entryTypePicker: some View {
        fieldCard(title: "Observation Type", subtitle: "Select the category that best describes this entry", icon: "tag.fill") {
            Picker("Entry Type", selection: $selectedType) {
                ForEach(EntryType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top, 4)
        }
    }

    // MARK: – Description Field

    private var descriptionField: some View {
        fieldCard(
            title: "Observation Details",
            subtitle: "Be specific and factual. Minimum 20 characters required.",
            icon: "doc.text.fill"
        ) {
            TextEditor(text: $description)
                .frame(minHeight: 130)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.top, 4)

            HStack {
                Spacer()
                Text("\(charCount) / 20 min")
                    .font(.caption2)
                    .foregroundColor(charCount >= 20 ? .appSuccess : .secondary)
            }
        }
    }

    // MARK: – Field Card Helper

    private func fieldCard<Content: View>(
        title: String,
        subtitle: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline).fontWeight(.semibold)
                    Text(subtitle)
                        .font(.caption2).foregroundColor(.secondary)
                }
            } icon: {
                Image(systemName: icon).foregroundColor(.appPrimary)
            }
            content()
        }
        .padding(16)
        .background(Color.appCard)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: – EYFS Guidance

    private var eyfsGuidance: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("EYFS Entry Guidelines", systemImage: "lightbulb.fill")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundColor(.appWarning)

            VStack(alignment: .leading, spacing: 6) {
                guidePoint("Use the child's first name only (GDPR compliance)")
                guidePoint("Record what you observed, not interpretations")
                guidePoint("Link to EYFS areas of learning where applicable")
                guidePoint("Submit on the same day as the observation")
            }
        }
        .padding(14)
        .background(Color.appWarning.opacity(0.07))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appWarning.opacity(0.22), lineWidth: 1))
    }

    private func guidePoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundColor(.appWarning)
                .padding(.top, 5)
            Text(text)
                .font(.caption2).foregroundColor(.secondary)
        }
    }

    // MARK: – Submit Button

    private var submitButton: some View {
        Button {
            guard isValid else { showValidationAlert = true; return }
            saveEntry()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                Text("Submit Entry")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isValid ? Color.appPrimary : Color.secondary.opacity(0.35))
            .cornerRadius(14)
        }
        .disabled(!isValid)
    }

    // MARK: – Success View

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appSuccess.opacity(0.12))
                    .frame(width: 110, height: 110)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 58))
                    .foregroundColor(.appSuccess)
            }

            VStack(spacing: 8) {
                Text("Entry Submitted!")
                    .font(.title2).fontWeight(.bold)
                Text("Your observation for \(childFirstName) has been submitted and is now pending review by the Room Leader.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button("Submit Another Entry") {
                resetForm()
            }
            .buttonStyle(.bordered)
            .tint(.appPrimary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    // MARK: – Actions

    private func saveEntry() {
        let entry = DiaryEntry(
            childFirstName: childFirstName.trimmingCharacters(in: .whitespacesAndNewlines),
            keyworkerName: keyworkerName,
            entryType: selectedType,
            entryDescription: description.trimmingCharacters(in: .whitespacesAndNewlines),
            submittedAt: Date(),
            status: .pending
        )
        modelContext.insert(entry)
        withAnimation(.spring(response: 0.4)) { isSaved = true }
    }

    private func resetForm() {
        childFirstName  = ""
        selectedType    = .activity
        description     = ""
        isSaved         = false
    }
}
