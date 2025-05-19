import Foundation
import RakutenStockAPI

/// Calculates Simple Moving Average (SMA).
public struct SMAIndicator {
    /// Calculates SMA for an array of `Double` values.
    public static func calculate(values: [Double], period: Int) -> [Double?] {
        guard period > 0 else { return [] }
        var results: [Double?] = Array(repeating: nil, count: values.count)
        var sum: Double = 0
        for idx in values.indices {
            sum += values[idx]
            if idx >= period {
                sum -= values[idx - period]
            }
            if idx >= period - 1 {
                results[idx] = sum / Double(period)
            }
        }
        return results
    }

    /// Convenience calculation using `OHLCVData` close prices.
    public static func calculate(for data: [OHLCVData], period: Int) -> [Double?] {
        let closes = data.map { $0.close }
        return calculate(values: closes, period: period)
    }
}
