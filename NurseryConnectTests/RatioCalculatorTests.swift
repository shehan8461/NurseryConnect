import Testing
@testable import NurseryConnect

// MARK: - AgeGroup EYFS Ratio Tests
struct AgeGroupTests {

    @Test func underTwoStatutoryRatio() {
        // EYFS 2024: 1 adult per 3 children under 2
        #expect(AgeGroup.underTwo.requiredRatio == 3)
    }

    @Test func twoYearStatutoryRatio() {
        // EYFS 2024: 1 adult per 4 two-year-olds
        #expect(AgeGroup.twoYear.requiredRatio == 4)
    }

    @Test func threeToFiveStatutoryRatio() {
        // EYFS 2024: 1 adult per 8 children aged 3–5
        #expect(AgeGroup.threeToFive.requiredRatio == 8)
    }

    @Test func ratioDescriptions() {
        #expect(AgeGroup.underTwo.ratioDescription    == "1:3")
        #expect(AgeGroup.twoYear.ratioDescription     == "1:4")
        #expect(AgeGroup.threeToFive.ratioDescription == "1:8")
    }

    @Test func rawValues() {
        #expect(AgeGroup.underTwo.rawValue    == "Under 2s")
        #expect(AgeGroup.twoYear.rawValue     == "2 Year Olds")
        #expect(AgeGroup.threeToFive.rawValue == "3-5 Year Olds")
    }

    @Test func allCasesCount() {
        #expect(AgeGroup.allCases.count == 3)
    }
}

// MARK: - RatioStatus Tests
struct RatioStatusTests {

    @Test func rawValues() {
        #expect(RatioStatus.compliant.rawValue  == "Compliant")
        #expect(RatioStatus.borderline.rawValue == "Approaching Limit")
        #expect(RatioStatus.breached.rawValue   == "Ratio Breached")
    }

    @Test func sfSymbolNames() {
        #expect(RatioStatus.compliant.icon  == "checkmark.shield.fill")
        #expect(RatioStatus.borderline.icon == "exclamationmark.circle.fill")
        #expect(RatioStatus.breached.icon   == "exclamationmark.triangle.fill")
    }

    @Test func colorHexValues() {
        #expect(RatioStatus.compliant.colorHex  == "3D9970")
        #expect(RatioStatus.borderline.colorHex == "FF851B")
        #expect(RatioStatus.breached.colorHex   == "E74C3C")
    }
}

// MARK: - RatioCalculator Tests
struct RatioCalculatorTests {

    // MARK: maxAllowedChildren

    @Test func maxAllowedChildrenTwoYear() {
        let calc = RatioCalculator(staffCount: 2, childCount: 0, ageGroup: .twoYear)
        // 2 staff × 4 = 8
        #expect(calc.maxAllowedChildren == 8)
    }

    @Test func maxAllowedChildrenUnderTwo() {
        let calc = RatioCalculator(staffCount: 3, childCount: 0, ageGroup: .underTwo)
        // 3 staff × 3 = 9
        #expect(calc.maxAllowedChildren == 9)
    }

    @Test func maxAllowedChildrenThreeToFive() {
        let calc = RatioCalculator(staffCount: 2, childCount: 0, ageGroup: .threeToFive)
        // 2 staff × 8 = 16
        #expect(calc.maxAllowedChildren == 16)
    }

    // MARK: Compliant status

    @Test func compliantWhenWellWithinLimit() {
        // 2 staff × 4 = max 8; 5 children → compliant (headroom 3 > 2)
        let calc = RatioCalculator(staffCount: 2, childCount: 5, ageGroup: .twoYear)
        #expect(calc.status    == .compliant)
        #expect(!calc.isBreached)
        #expect(!calc.isBorderline)
    }

    @Test func compliantForUnderTwoGroup() {
        // 3 staff × 3 = 9; 6 children → headroom 3 → compliant
        let calc = RatioCalculator(staffCount: 3, childCount: 6, ageGroup: .underTwo)
        #expect(calc.status == .compliant)
    }

    @Test func zeroStaffZeroChildrenIsBorderline() {
        // 0 staff → maxAllowed = 0; headroom = 0 ≤ 2 → borderline (not breached)
        let calc = RatioCalculator(staffCount: 0, childCount: 0, ageGroup: .twoYear)
        #expect(calc.status == .borderline)
        #expect(!calc.isBreached)
    }

    // MARK: Borderline status

    @Test func borderlineWhenHeadroomIsOne() {
        // 1 staff × 4 = max 4; 3 children → headroom 1 ≤ 2 → borderline
        let calc = RatioCalculator(staffCount: 1, childCount: 3, ageGroup: .twoYear)
        #expect(calc.status == .borderline)
        #expect(!calc.isBreached)
        #expect(calc.isBorderline)
    }

    @Test func borderlineAtExactMaximum() {
        // 1 staff × 4 = 4; 4 children → headroom 0 ≤ 2 → borderline (not breached)
        let calc = RatioCalculator(staffCount: 1, childCount: 4, ageGroup: .twoYear)
        #expect(calc.status == .borderline)
        #expect(!calc.isBreached)
    }

    @Test func borderlineWhenHeadroomIsTwo() {
        // 2 staff × 4 = 8; 6 children → headroom 2 ≤ 2 → borderline
        let calc = RatioCalculator(staffCount: 2, childCount: 6, ageGroup: .twoYear)
        #expect(calc.status == .borderline)
    }

    @Test func compliantWhenHeadroomIsThree() {
        // 2 staff × 4 = 8; 5 children → headroom 3 > 2 → compliant
        let calc = RatioCalculator(staffCount: 2, childCount: 5, ageGroup: .twoYear)
        #expect(calc.status == .compliant)
    }

    // MARK: Breached status

    @Test func breachedWhenChildCountExceedsLimit() {
        // 1 staff × 4 = 4; 5 children → breached
        let calc = RatioCalculator(staffCount: 1, childCount: 5, ageGroup: .twoYear)
        #expect(calc.status == .breached)
        #expect(calc.isBreached)
        #expect(!calc.isBorderline)
    }

    @Test func zeroStaffWithChildrenIsBreached() {
        // 0 staff, any children → always breached
        let calc = RatioCalculator(staffCount: 0, childCount: 1, ageGroup: .twoYear)
        #expect(calc.status == .breached)
        #expect(calc.isBreached)
    }

    @Test func breachedForUnderTwoGroup() {
        // 1 staff × 3 = 3; 4 children → breached
        let calc = RatioCalculator(staffCount: 1, childCount: 4, ageGroup: .underTwo)
        #expect(calc.status == .breached)
    }

    @Test func breachedForThreeToFiveGroup() {
        // 1 staff × 8 = 8; 9 children → breached
        let calc = RatioCalculator(staffCount: 1, childCount: 9, ageGroup: .threeToFive)
        #expect(calc.status == .breached)
    }

    // MARK: Edge cases

    @Test func singleStaffSingleChildCompliant() {
        // 1 × 4 = 4; 1 child → headroom 3 > 2 → compliant
        let calc = RatioCalculator(staffCount: 1, childCount: 1, ageGroup: .twoYear)
        #expect(calc.status == .compliant)
    }

    @Test func largeStaffCountCompliant() {
        // 10 staff × 8 = 80; 50 children → well compliant
        let calc = RatioCalculator(staffCount: 10, childCount: 50, ageGroup: .threeToFive)
        #expect(calc.status == .compliant)
        #expect(calc.maxAllowedChildren == 80)
    }
}
