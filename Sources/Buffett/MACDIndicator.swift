import Foundation
import RakutenStockAPI

/// Calculates Moving Average Convergence Divergence (MACD).
public struct MACDIndicator {
    /// Calculates MACD using raw values.
    public static func calculate(
        values: [Double],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> ([Double?], [Double?]) {
        let fast = EMAIndicator.calculate(values: values, period: fastPeriod)
        let slow = EMAIndicator.calculate(values: values, period: slowPeriod)
        var macd: [Double?] = Array(repeating: nil, count: values.count)
        for i in values.indices {
            if let f = fast[i], let s = slow[i] {
                macd[i] = f - s
            }
        }
        // Compute signal line from non-nil MACD values
        var macdValues: [Double] = []
        var macdIndices: [Int] = []
        for (idx, val) in macd.enumerated() where val != nil {
            macdValues.append(val!)
            macdIndices.append(idx)
        }
        let signalValues = EMAIndicator.calculate(values: macdValues, period: signalPeriod)
        var signal: [Double?] = Array(repeating: nil, count: values.count)
        for (offset, idx) in macdIndices.enumerated() {
            if offset < signalValues.count {
                signal[idx] = signalValues[offset]
            }
        }
        return (macd, signal)
    }

    /// Convenience calculation using `OHLCVData` close prices.
    public static func calculate(
        for data: [OHLCVData],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> ([Double?], [Double?]) {
        let closes = data.map { $0.close }
        return calculate(
            values: closes,
            fastPeriod: fastPeriod,
            slowPeriod: slowPeriod,
            signalPeriod: signalPeriod
        )
    }
}
