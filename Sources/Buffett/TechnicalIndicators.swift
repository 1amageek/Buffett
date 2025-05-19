import Foundation
import RakutenStockAPI

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

    /// Calculates Exponential Moving Average (EMA) for an array of values.
    /// - Parameters:
    ///   - values: Array of Double values.
    ///   - period: Lookback period for the EMA.
    /// - Returns: Array of optional Double where positions before `period` are nil.
    public static func exponentialMovingAverage(values: [Double], period: Int) -> [Double?] {
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

    /// Convenience for OHLCVData arrays using the close price.
    public static func exponentialMovingAverage(for data: [OHLCVData], period: Int) -> [Double?] {
        let closes = data.map { $0.close }
        return exponentialMovingAverage(values: closes, period: period)
    }

    /// Calculates MACD (Moving Average Convergence Divergence).
    /// - Parameters:
    ///   - values: Input values, typically closing prices.
    ///   - fastPeriod: Period for the fast EMA.
    ///   - slowPeriod: Period for the slow EMA.
    ///   - signalPeriod: Period for the signal line EMA.
    /// - Returns: Tuple of arrays `(macdLine, signalLine)`.
    public static func movingAverageConvergenceDivergence(
        values: [Double],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> ([Double?], [Double?]) {
        let fast = exponentialMovingAverage(values: values, period: fastPeriod)
        let slow = exponentialMovingAverage(values: values, period: slowPeriod)
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
        let signalValues = exponentialMovingAverage(values: macdValues, period: signalPeriod)
        var signal: [Double?] = Array(repeating: nil, count: values.count)
        for (offset, idx) in macdIndices.enumerated() {
            if offset < signalValues.count {
                signal[idx] = signalValues[offset]
            }
        }
        return (macd, signal)
    }

    /// Convenience for OHLCVData arrays using the close price.
    public static func movingAverageConvergenceDivergence(
        for data: [OHLCVData],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> ([Double?], [Double?]) {
        let closes = data.map { $0.close }
        return movingAverageConvergenceDivergence(
            values: closes,
            fastPeriod: fastPeriod,
            slowPeriod: slowPeriod,
            signalPeriod: signalPeriod
        )
    }

    /// Calculates Relative Strength Index (RSI).
    /// - Parameters:
    ///   - values: Input prices.
    ///   - period: Lookback period (default 14).
    /// - Returns: Array of optional RSI values.
    public static func relativeStrengthIndex(values: [Double], period: Int = 14) -> [Double?] {
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
        if values.count <= period {
            return results
        }
        var avgGain = gains[1...period].reduce(0, +) / Double(period)
        var avgLoss = losses[1...period].reduce(0, +) / Double(period)
        let rs = avgLoss == 0 ? Double.infinity : avgGain / avgLoss
        results[period] = 100 - 100 / (1 + rs)
        if values.count == period + 1 {
            return results
        }
        for i in (period + 1)..<values.count {
            avgGain = ((avgGain * Double(period - 1)) + gains[i]) / Double(period)
            avgLoss = ((avgLoss * Double(period - 1)) + losses[i]) / Double(period)
            let rs = avgLoss == 0 ? Double.infinity : avgGain / avgLoss
            results[i] = 100 - 100 / (1 + rs)
        }
        return results
    }

    /// Convenience for OHLCVData arrays using the close price.
    public static func relativeStrengthIndex(for data: [OHLCVData], period: Int = 14) -> [Double?] {
        let closes = data.map { $0.close }
        return relativeStrengthIndex(values: closes, period: period)
    }

    /// Calculates Bollinger Bands.
    /// - Parameters:
    ///   - values: Input prices.
    ///   - period: Moving average period.
    ///   - multiplier: Standard deviation multiplier (default 2.0).
    /// - Returns: Tuple `(upper, middle, lower)` bands.
    public static func bollingerBands(values: [Double], period: Int, multiplier: Double = 2.0) -> ([Double?], [Double?], [Double?]) {
        guard period > 0 else { return ([], [], []) }
        let sma = simpleMovingAverage(values: values, period: period)
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

    /// Convenience for OHLCVData arrays using the close price.
    public static func bollingerBands(for data: [OHLCVData], period: Int, multiplier: Double = 2.0) -> ([Double?], [Double?], [Double?]) {
        let closes = data.map { $0.close }
        return bollingerBands(values: closes, period: period, multiplier: multiplier)
    }

    /// Calculates Ichimoku Cloud components.
    /// Returns tuple `(tenkan, kijun, senkouA, senkouB, chikou)`.
    public static func ichimokuCloud(for data: [OHLCVData]) -> ([Double?], [Double?], [Double?], [Double?], [Double?]) {
        let count = data.count
        var tenkan = [Double?](repeating: nil, count: count)
        var kijun = [Double?](repeating: nil, count: count)
        var senkouA = [Double?](repeating: nil, count: count)
        var senkouB = [Double?](repeating: nil, count: count)
        var chikou = [Double?](repeating: nil, count: count)

        for i in data.indices {
            if i >= 8 { // 9-period
                let highs = data[(i - 8)...i].map { $0.high }
                let lows = data[(i - 8)...i].map { $0.low }
                let maxH = highs.max() ?? 0
                let minL = lows.min() ?? 0
                tenkan[i] = (maxH + minL) / 2
            }
            if i >= 25 { // 26-period
                let highs = data[(i - 25)...i].map { $0.high }
                let lows = data[(i - 25)...i].map { $0.low }
                let maxH = highs.max() ?? 0
                let minL = lows.min() ?? 0
                kijun[i] = (maxH + minL) / 2
            }
            if i >= 51 { // 52-period
                let highs = data[(i - 51)...i].map { $0.high }
                let lows = data[(i - 51)...i].map { $0.low }
                let maxH = highs.max() ?? 0
                let minL = lows.min() ?? 0
                let value = (maxH + minL) / 2
                if i + 26 < count {
                    senkouB[i + 26] = value
                }
            }
            if i >= 26 {
                chikou[i - 26] = data[i].close
            }
            if let t = tenkan[i], let k = kijun[i], i + 26 < count {
                senkouA[i + 26] = (t + k) / 2
            }
        }
        return (tenkan, kijun, senkouA, senkouB, chikou)
    }

    /// Calculates Volume Weighted Average Price (VWAP).
    /// - Parameter data: OHLCV data array.
    /// - Returns: Array of VWAP values.
    public static func volumeWeightedAveragePrice(for data: [OHLCVData]) -> [Double?] {
        var results: [Double?] = Array(repeating: nil, count: data.count)
        var cumulativePV: Double = 0
        var cumulativeVolume: Double = 0
        for (idx, item) in data.enumerated() {
            cumulativePV += item.close * Double(item.volume)
            cumulativeVolume += Double(item.volume)
            results[idx] = cumulativeVolume == 0 ? nil : cumulativePV / cumulativeVolume
        }
        return results
    }
}
