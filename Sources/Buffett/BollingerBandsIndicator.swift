import Foundation
import RakutenStockAPI

/// Calculates Bollinger Bands.
public struct BollingerBandsIndicator {
    /// Calculates bands using raw price values.
    public static func calculate(values: [Double], period: Int, multiplier: Double = 2.0) -> ([Double?], [Double?], [Double?]) {
        guard period > 0 else { return ([], [], []) }
        let sma = SMAIndicator.calculate(values: values, period: period)
        var upper: [Double?] = Array(repeating: nil, count: values.count)
        var lower: [Double?] = Array(repeating: nil, count: values.count)
        for idx in values.indices where idx >= period - 1 {
            let window = values[(idx - period + 1)...idx]
            let mean = sma[idx] ?? 0
            let variance = window.reduce(0) { $0 + pow($1 - mean, 2) } / Double(period)
            let std = sqrt(variance)
            upper[idx] = mean + multiplier * std
            lower[idx] = mean - multiplier * std
        }
        return (upper, sma, lower)
    }

    /// Convenience calculation using `OHLCVData` close prices.
    public static func calculate(for data: [OHLCVData], period: Int, multiplier: Double = 2.0) -> ([Double?], [Double?], [Double?]) {
        let closes = data.map { $0.close }
        return calculate(values: closes, period: period, multiplier: multiplier)
    }
}
