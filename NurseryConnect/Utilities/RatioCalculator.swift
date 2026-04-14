import Foundation

/// Pure business-logic value type for EYFS staffing-ratio calculations.
/// Keeping this separate from the SwiftData model and the view layer
/// enables straightforward unit testing and clear separation of concerns.
struct RatioCalculator {

    let staffCount: Int
    let childCount: Int
    let ageGroup: AgeGroup

    // MARK: - Core Calculations

    /// Maximum children permitted under EYFS statutory ratios.
    var maxAllowedChildren: Int {
        staffCount * ageGroup.requiredRatio
    }

    /// True when the current child count exceeds the statutory limit.
    var isBreached: Bool {
        guard staffCount > 0 else { return childCount > 0 }
        return childCount > maxAllowedChildren
    }

    /// True when headroom to the statutory limit is 2 or fewer children.
    var isBorderline: Bool {
        guard !isBreached else { return false }
        return (maxAllowedChildren - childCount) <= 2
    }

    /// Derived compliance status used for UI and session logging.
    var status: RatioStatus {
        if isBreached   { return .breached }
        if isBorderline { return .borderline }
        return .compliant
    }
}
