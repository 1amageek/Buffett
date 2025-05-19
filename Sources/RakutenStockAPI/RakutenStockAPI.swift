import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Errors that can be thrown by ``RakutenStockAPI``.
public enum APIError: Error, Sendable {
    case invalidResponse
    case httpError(Int)
}

/// Concrete implementation of ``StockAPIProtocol`` backed by Rakuten Securities MarketSpeed II RSS.
///
/// This implementation performs simple HTTP GET requests to a base URL. The
/// actual MarketSpeed II RSS endpoints should be proxied via a local server.
public struct RakutenStockAPI: StockAPIProtocol, Sendable {
    public var baseURL: URL
    @preconcurrency public var session: URLSession

    /// Creates an API instance.
    /// - Parameters:
    ///   - baseURL: Base URL of the local proxy server.
    ///   - session: URLSession instance to use. Defaults to ``URLSession.shared``.
    public init(baseURL: URL = URL(string: "http://localhost:18080")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        try await request(path: "market/quote/\(symbol.code)")
    }

    public func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        try await request(path: "market/ticks/\(symbol.code)")
    }

    public func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        try await request(path: "market/chart/\(symbol.code)")
    }

    /// Performs an HTTP request and decodes the JSON response.
    private func request<T: Decodable>(path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(httpResponse.statusCode) else { throw APIError.httpError(httpResponse.statusCode) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
