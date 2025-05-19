import Foundation
import RakutenStockAPI

/// Calculates Ichimoku Cloud components.
public struct IchimokuCloudIndicator {
    /// Returns tuple `(tenkan, kijun, senkouA, senkouB, chikou)` for given data.
    public static func calculate(for data: [OHLCVData]) -> ([Double?], [Double?], [Double?], [Double?], [Double?]) {
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
}
