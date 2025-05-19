import Foundation

/// Protocol defining available stock API methods.
public protocol StockAPIProtocol: Sendable {
    func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote
    func fetchTickList(for symbol: Symbol) async throws -> [TickData]
    func fetchChart(for symbol: Symbol) async throws -> [OHLCVData]
}
