import SwiftUI

struct EntryRowView: View {
    let entry: DiaryEntry
    
    var statusColor: Color {
        switch entry.status {
        case .pending:            return .appWarning
        case .countersigned:      return .appSuccess
        case .amendmentRequested: return .appDanger
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Entry Type Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(entry.entryType.icon)
                    .font(.title3)
            }
            
            // Entry Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.childFirstName)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(entry.entryType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(entry.keyworkerName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status + Time
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: entry.status.icon)
                    .foregroundColor(statusColor)
                    .font(.subheadline)
                Text(entry.submittedAt.formatted(
                    .dateTime.hour().minute()
                ))
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.05),
            radius: 4, x: 0, y: 1
        )
    }
}
