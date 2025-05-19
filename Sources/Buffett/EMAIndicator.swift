import Foundation
import RakutenStockAPI

/// Calculates Exponential Moving Average (EMA).
public struct EMAIndicator {
    /// Calculates EMA for an array of `Double` values.
    public static func calculate(values: [Double], period: Int) -> [Double?] {
        guard period > 0 else { return [] }
        var results: [Double?] = Array(repeating: nil, count: values.count)
        let k = 2.0 / (Double(period) + 1.0)
        var ema: Double = 0
        for idx in values.indices {
            if idx == period - 1 {
                let sma = values[0...idx].reduce(0, +) / Double(period)
                ema = sma
                results[idx] = sma
            } else if idx >= period {
                ema = (values[idx] - ema) * k + ema
                results[idx] = ema
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
