import Foundation

/// Simple API wrapper decoding JSON data for testing purposes.
public struct RakutenStockAPI: StockAPIProtocol {
    public enum Endpoint {
        case marketQuote(Symbol)
        case tickList(Symbol)
        case chart(Symbol)
    }

    public enum APIError: Error {
        case decodingFailed
    }

    /// Closure providing raw JSON data for a given endpoint.
    private let dataProvider: (Endpoint) async throws -> Data
    private let decoder: JSONDecoder

    public init(dataProvider: @escaping (Endpoint) async throws -> Data) {
        self.dataProvider = dataProvider
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        let data = try await dataProvider(.marketQuote(symbol))
        do {
            return try decoder.decode(MarketQuote.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    public func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        let data = try await dataProvider(.tickList(symbol))
        do {
            return try decoder.decode([TickData].self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    public func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        let data = try await dataProvider(.chart(symbol))
        do {
            return try decoder.decode([OHLCVData].self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

