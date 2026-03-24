
//  EntryRowView.swift
//  NurseryConnect
//
//  Created by shehan salitha on 2026-03-24.
//

import SwiftUI

struct EntryRowView: View {
    let entry: DiaryEntry
    var body: some View {
        HStack(spacing: 12) {
            Text(entry.entryType.icon)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.childFirstName)
                    .fontWeight(.semibold)
                Text(entry.entryType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: entry.status.icon)
                .foregroundColor(.appWarning)
        }
        .padding(12)
        .background(Color.appCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

