import Foundation
import Observation
import Buffett
import RakutenStockAPI

/// ViewModel responsible for loading chart data for a symbol.
@Observable
@MainActor
public final class ChartViewModel {
    public let symbol: Symbol
    private let api: StockAPIProtocol
    private let smaPeriod: Int
    private let emaPeriod: Int
    private let bollingerPeriod: Int
    private let rsiPeriod: Int
    private let macdShortPeriod: Int
    private let macdLongPeriod: Int
    private let macdSignalPeriod: Int
    // Ichimoku Cloud default periods are often fixed (e.g., 9, 26, 52)
    // but can be made configurable if needed. For now, let's assume fixed,
    // or add them if specific configurability is required by the task later.
    // For VWAP, it's typically calculated based on the data available for a period (e.g., daily VWAP).
    // It might not need a "period" parameter in the same way as SMA/EMA.
    // Let's assume VWAPIndicator.calculate will handle its period internally or use the whole dataset.

    public var data: [OHLCVData] = []
    public var sma: [Double?] = []
    public var ema: [Double?] = []
    public var bollingerUpper: [Double?] = []
    public var bollingerMiddle: [Double?] = []
    public var bollingerLower: [Double?] = []

    @Published public var selectedPeriod: ChartTimePeriod = .oneYear // Default to fetching 1 year, then filtering
    private var allFetchedData: [OHLCVData] = [] // Store all data fetched from API
    @Published public var priceAnnotations: [PriceAnnotation] = []

    public var macdLine: [Double?] = []
    public var macdSignalLine: [Double?] = []
    public var macdHistogram: [Double?] = []
    public var rsi: [Double?] = []
    public var ichimokuTenkanSen: [Double?] = []
    public var ichimokuKijunSen: [Double?] = []
    public var ichimokuSenkouSpanA: [Double?] = []
    public var ichimokuSenkouSpanB: [Double?] = []
    public var ichimokuChikouSpan: [Double?] = []
    public var vwap: [Double?] = []

    public init(symbol: Symbol, api: StockAPIProtocol,
                smaPeriod: Int = 5,
                emaPeriod: Int = 5,
                bollingerPeriod: Int = 20,
                rsiPeriod: Int = 14,
                macdShortPeriod: Int = 12,
                macdLongPeriod: Int = 26,
                macdSignalPeriod: Int = 9) {
        self.symbol = symbol
        self.api = api
        self.smaPeriod = smaPeriod
        self.emaPeriod = emaPeriod
        self.bollingerPeriod = bollingerPeriod
        self.rsiPeriod = rsiPeriod
        self.macdShortPeriod = macdShortPeriod
        self.macdLongPeriod = macdLongPeriod
        self.macdSignalPeriod = macdSignalPeriod
    }

    /// Fetches chart data from the API and updates ``data``.
    public func fetch() async {
        do {
            // For now, assume api.fetchChart fetches a reasonably large dataset (e.g., 1 year or more if available)
            // This fetchedData will be stored in allFetchedData.
            let fetchedData = try await api.fetchChart(for: symbol)
            allFetchedData = fetchedData.sorted(by: { $0.timestamp < $1.timestamp }) // Ensure sorted
            applyPeriodFilter() // Apply the current selectedPeriod filter
        } catch {
            // For now simply print the error. Proper error handling to be added.
            print("ChartViewModel fetch error: \(error)")
            // Consider clearing data if fetch fails:
            // allFetchedData = []
            // data = []
            // updateIndicators() // This would clear indicators
        }
    }

    /// Filters `allFetchedData` into `data` based on `selectedPeriod` and updates indicators.
    public func applyPeriodFilter() { // Made public to be callable from Picker's onChange if needed directly
        guard !allFetchedData.isEmpty else {
            self.data = []
            updateIndicators()
            return
        }

        let endDate = allFetchedData.last?.timestamp ?? Date()
        // Calculate start date based on selectedPeriod using its helper method
        let startDate = selectedPeriod.calculateStartDate(from: endDate)

        if let strongStartDate = startDate {
            self.data = allFetchedData.filter { $0.timestamp >= strongStartDate && $0.timestamp <= endDate }
        } else { // .all case
            self.data = allFetchedData
        }
        
        // Ensure data is not empty after filtering before updating indicators,
        // though updateIndicators itself has a guard for empty data.
        // If filter results in empty (e.g. 1D period but no data for today in allFetchedData),
        // indicators will be cleared by updateIndicators.
        updateIndicators()
    }

    // MARK: - Price Annotations
    public func addPriceAnnotation(at price: Double, label: String? = nil, color: Color = .orange) {
        let newAnnotation = PriceAnnotation(priceLevel: price, color: color, label: label)
        priceAnnotations.append(newAnnotation)
    }

    public func removePriceAnnotation(id: UUID) {
        priceAnnotations.removeAll { $0.id == id }
    }
    
    public func removePriceAnnotation(annotation: PriceAnnotation) { // Convenience
        removePriceAnnotation(id: annotation.id)
    }


    /// Recalculate indicator arrays based on current ``data``.
    public func updateIndicators() {
        guard !data.isEmpty else {
            sma = []
            ema = []
            bollingerUpper = []
            bollingerMiddle = []
            bollingerLower = []
            macdLine = []
            macdSignalLine = []
            macdHistogram = []
            rsi = []
            ichimokuTenkanSen = []
            ichimokuKijunSen = []
            ichimokuSenkouSpanA = []
            ichimokuSenkouSpanB = []
            ichimokuChikouSpan = []
            vwap = []
            return
        }

        sma = SMAIndicator.calculate(for: data, period: smaPeriod)
        ema = EMAIndicator.calculate(for: data, period: emaPeriod)
        let bollingerBands = BollingerBandsIndicator.calculate(for: data, period: bollingerPeriod)
        bollingerUpper = bollingerBands.0
        bollingerMiddle = bollingerBands.1
        bollingerLower = bollingerBands.2

        let macdResult = MACDIndicator.calculate(for: data, shortPeriod: macdShortPeriod, longPeriod: macdLongPeriod, signalPeriod: macdSignalPeriod)
        macdLine = macdResult.macdLine
        macdSignalLine = macdResult.signalLine
        macdHistogram = macdResult.histogram

        rsi = RSIIndicator.calculate(for: data, period: rsiPeriod)

        // Assuming default periods for Ichimoku Cloud if not passed in init.
        // These are standard periods: tenkan: 9, kijun: 26, senkouB: 52.
        // senkouSpanADelay and chikouSpanDelay are typically 26.
        // The Buffett library's IchimokuCloudIndicator.calculate method should use appropriate defaults
        // or have parameters for these if customization is needed.
        // For now, we rely on the library's defaults or its internal handling.
        let ichimokuResult = IchimokuCloudIndicator.calculate(for: data) // Add periods if the lib requires
        ichimokuTenkanSen = ichimokuResult.tenkanSen
        ichimokuKijunSen = ichimokuResult.kijunSen
        ichimokuSenkouSpanA = ichimokuResult.senkouSpanA
        ichimokuSenkouSpanB = ichimokuResult.senkouSpanB
        ichimokuChikouSpan = ichimokuResult.chikouSpan
        
        vwap = VWAPIndicator.calculate(for: data)
    }
}
