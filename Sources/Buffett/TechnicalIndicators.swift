import Foundation

/// Utility to calculate technical indicators.
public enum TechnicalIndicators {
    /// Calculates Simple Moving Average (SMA) for an array of values.
    /// - Parameters:
    ///   - values: Array of Double values, typically closing prices.
    ///   - period: Lookback period for the moving average.
    /// - Returns: Array of optional Double where positions before `period` are `nil`.
    public static func simpleMovingAverage(values: [Double], period: Int) -> [Double?] {
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

    /// Convenience for OHLCVData arrays using the close price.
    public static func simpleMovingAverage(for data: [OHLCVData], period: Int) -> [Double?] {
        let closes = data.map { $0.close }
        return simpleMovingAverage(values: closes, period: period)
    }
}
