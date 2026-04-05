import SwiftUI

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(
                after: hex.startIndex
            )
        }
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8)  / 255.0
        let b = Double(rgbValue & 0x0000FF)          / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - RatioStatus Color Helper
extension RatioStatus {
    var color: Color {
        switch self {
        case .compliant:  return .appSuccess
        case .borderline: return .appWarning
        case .breached:   return .appDanger
        }
    }
}

// MARK: - ReviewStatus Color Helper
extension ReviewStatus {
    var color: Color {
        switch self {
        case .pending:            return .appWarning
        case .countersigned:      return .appSuccess
        case .amendmentRequested: return .appDanger
        }
    }
}
