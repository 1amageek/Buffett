import Foundation
import RakutenStockAPI

/// Calculates Volume Weighted Average Price (VWAP).
public struct VWAPIndicator {
    /// Calculates VWAP using OHLCV data.
    public static func calculate(for data: [OHLCVData]) -> [Double?] {
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
