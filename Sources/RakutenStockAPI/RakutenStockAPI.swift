import Foundation

/// Concrete implementation of ``StockAPIProtocol`` backed by Rakuten Securities MarketSpeed II RSS.
///
/// This is a placeholder implementation. Actual network calls to the RSS API
/// should be implemented to fetch real market data.
public struct RakutenStockAPI: StockAPIProtocol, Sendable {
    public init() {}

    public func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        // TODO: Replace with real API call to MarketSpeed II RSS.
        throw NSError(domain: "RakutenStockAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }

    public func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        // TODO: Replace with real API call to MarketSpeed II RSS.
        throw NSError(domain: "RakutenStockAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }

    public func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        // TODO: Replace with real API call to MarketSpeed II RSS.
        throw NSError(domain: "RakutenStockAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
}
