import Foundation

@available(iOS 14.0, macOS 11.0, *)
public enum ChartTimePeriod: String, CaseIterable, Identifiable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "All"

    public var id: String { self.rawValue }

    public var displayName: String {
        switch self {
        case .oneDay: return "1 Day"
        case .oneWeek: return "1 Week"
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        case .all: return "All Time"
        }
    }

    // Helper to calculate the start date based on a given end date
    func calculateStartDate(from endDate: Date = Date()) -> Date? {
        let calendar = Calendar.current
        switch self {
        case .oneDay:
            return calendar.date(byAdding: .day, value: -1, to: endDate)
        case .oneWeek:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: endDate)
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: endDate)
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: endDate)
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: endDate)
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: endDate)
        case .all:
            return nil // Represents no specific start date, so all data from the beginning
        }
    }
}
