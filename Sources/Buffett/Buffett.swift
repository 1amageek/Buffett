import Foundation
import RakutenStockAPI

/// Mock implementation used for testing.
public struct MockStockAPI: StockAPIProtocol, Sendable {
    public init() {}

    public func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        .init(symbol: symbol, lastPrice: 100.0, bid: 99.5, ask: 100.5)
    }

    public func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        let now = Date()
        return [
            .init(symbol: symbol, price: 100.0, volume: 100, timestamp: now),
            .init(symbol: symbol, price: 100.5, volume: 200, timestamp: now.addingTimeInterval(60))
        ]
    }

    public func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        let now = Date()
        return [
            .init(symbol: symbol, timestamp: now, open: 99.0, high: 101.0, low: 98.5, close: 100.5, volume: 1000)
        ]
    }
}
