import Foundation
import RakutenStockAPI

/// Thin facade to access various technical indicator calculations.
public enum TechnicalIndicators {
    public static func simpleMovingAverage(values: [Double], period: Int) -> [Double?] {
        SMAIndicator.calculate(values: values, period: period)
    }

    public static func simpleMovingAverage(for data: [OHLCVData], period: Int) -> [Double?] {
        SMAIndicator.calculate(for: data, period: period)
    }

    public static func exponentialMovingAverage(values: [Double], period: Int) -> [Double?] {
        EMAIndicator.calculate(values: values, period: period)
    }

    public static func exponentialMovingAverage(for data: [OHLCVData], period: Int) -> [Double?] {
        EMAIndicator.calculate(for: data, period: period)
    }

    public static func movingAverageConvergenceDivergence(
        values: [Double],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> ([Double?], [Double?]) {
        MACDIndicator.calculate(values: values, fastPeriod: fastPeriod, slowPeriod: slowPeriod, signalPeriod: signalPeriod)
    }

    public static func movingAverageConvergenceDivergence(
        for data: [OHLCVData],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> ([Double?], [Double?]) {
        MACDIndicator.calculate(for: data, fastPeriod: fastPeriod, slowPeriod: slowPeriod, signalPeriod: signalPeriod)
    }

    public static func relativeStrengthIndex(values: [Double], period: Int = 14) -> [Double?] {
        RSIIndicator.calculate(values: values, period: period)
    }

    public static func relativeStrengthIndex(for data: [OHLCVData], period: Int = 14) -> [Double?] {
        RSIIndicator.calculate(for: data, period: period)
    }

    public static func bollingerBands(values: [Double], period: Int, multiplier: Double = 2.0) -> ([Double?], [Double?], [Double?]) {
        BollingerBandsIndicator.calculate(values: values, period: period, multiplier: multiplier)
    }

    public static func bollingerBands(for data: [OHLCVData], period: Int, multiplier: Double = 2.0) -> ([Double?], [Double?], [Double?]) {
        BollingerBandsIndicator.calculate(for: data, period: period, multiplier: multiplier)
    }

    public static func ichimokuCloud(for data: [OHLCVData]) -> ([Double?], [Double?], [Double?], [Double?], [Double?]) {
        IchimokuCloudIndicator.calculate(for: data)
    }

    public static func volumeWeightedAveragePrice(for data: [OHLCVData]) -> [Double?] {
        VWAPIndicator.calculate(for: data)
    }
}
