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
    public var data: [OHLCVData] = []
    public var sma: [Double?] = []
    public var ema: [Double?] = []

    public init(symbol: Symbol, api: StockAPIProtocol, smaPeriod: Int = 5, emaPeriod: Int = 5) {
        self.symbol = symbol
        self.api = api
        self.smaPeriod = smaPeriod
        self.emaPeriod = emaPeriod
    }

    /// Fetches chart data from the API and updates ``data``.
    public func fetch() async {
        do {
            data = try await api.fetchChart(for: symbol)
            updateIndicators()
        } catch {
            // For now simply print the error. Proper error handling to be added.
            print("ChartViewModel fetch error: \(error)")
        }
    }

    /// Recalculate indicator arrays based on current ``data``.
    public func updateIndicators() {
        sma = SMAIndicator.calculate(for: data, period: smaPeriod)
        ema = EMAIndicator.calculate(for: data, period: emaPeriod)
    }
}
