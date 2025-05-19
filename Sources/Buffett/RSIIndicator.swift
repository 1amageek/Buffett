import Foundation
import RakutenStockAPI

/// Calculates Relative Strength Index (RSI).
public struct RSIIndicator {
    /// Calculates RSI using raw price values.
    public static func calculate(values: [Double], period: Int = 14) -> [Double?] {
        guard period > 0 else { return [] }
        guard values.count > period else {
            return Array(repeating: nil, count: values.count)
        }

        var results: [Double?] = Array(repeating: nil, count: values.count)
        var gains: [Double] = Array(repeating: 0, count: values.count)
        var losses: [Double] = Array(repeating: 0, count: values.count)

        for i in 1..<values.count {
            let diff = values[i] - values[i - 1]
            if diff >= 0 {
                gains[i] = diff
            } else {
                losses[i] = -diff
            }
        }

        var avgGain = gains[1...period].reduce(0, +) / Double(period)
        var avgLoss = losses[1...period].reduce(0, +) / Double(period)
        let initialRS = avgLoss == 0 ? Double.infinity : avgGain / avgLoss
        results[period] = 100 - 100 / (1 + initialRS)

        if values.count > period + 1 {
            for i in (period + 1)..<values.count {
                avgGain = ((avgGain * Double(period - 1)) + gains[i]) / Double(period)
                avgLoss = ((avgLoss * Double(period - 1)) + losses[i]) / Double(period)
                let rs = avgLoss == 0 ? Double.infinity : avgGain / avgLoss
                results[i] = 100 - 100 / (1 + rs)
            }
        }
        return results
    }

    /// Convenience calculation using `OHLCVData` close prices.
    public static func calculate(for data: [OHLCVData], period: Int = 14) -> [Double?] {
        let closes = data.map { $0.close }
        return calculate(values: closes, period: period)
    }
}
