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
    public var data: [OHLCVData] = []

    public init(symbol: Symbol, api: StockAPIProtocol) {
        self.symbol = symbol
        self.api = api
    }

    /// Fetches chart data from the API and updates ``data``.
    public func fetch() async {
        do {
            data = try await api.fetchChart(for: symbol)
        } catch {
            // For now simply print the error. Proper error handling to be added.
            print("ChartViewModel fetch error: \(error)")
        }
    }
}
