import Foundation
import Testing
@testable import Buffett

private func loadFixture(_ name: String) throws -> Data {
    let url = Bundle.module.url(forResource: "Fixtures/" + name, withExtension: "json")!
    return try Data(contentsOf: url)
}

@Test
func testMarketQuoteDecoding() throws {
    let data = try loadFixture("MarketQuote")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let quote = try decoder.decode(MarketQuote.self, from: data)
    #expect(quote.symbol.code == "AAPL")
    #expect(quote.lastPrice == 150.0)
}

@Test
func testTickDataDecoding() throws {
    let data = try loadFixture("TickData")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let ticks = try decoder.decode([TickData].self, from: data)
    #expect(ticks.count == 2)
    #expect(ticks[1].price == 150.5)
}

@Test
func testOHLCVDataDecoding() throws {
    let data = try loadFixture("OHLCVData")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let chart = try decoder.decode([OHLCVData].self, from: data)
    #expect(chart.first?.open == 149.0)
}

@Test
func testRakutenStockAPISuccess() async throws {
    let provider: (RakutenStockAPI.Endpoint) async throws -> Data = { endpoint in
        switch endpoint {
        case .marketQuote:
            return try loadFixture("MarketQuote")
        case .tickList:
            return try loadFixture("TickData")
        case .chart:
            return try loadFixture("OHLCVData")
        }
    }
    let api = RakutenStockAPI(dataProvider: provider)
    let symbol = Symbol(code: "AAPL", name: "Apple")

    let quote = try await api.fetchMarketQuote(for: symbol)
    #expect(quote.lastPrice == 150.0)

    let ticks = try await api.fetchTickList(for: symbol)
    #expect(ticks.count == 2)

    let chart = try await api.fetchChart(for: symbol)
    #expect(chart.count == 1)
}

@Test
func testRakutenStockAPIDecodingError() async {
    let provider: (RakutenStockAPI.Endpoint) async throws -> Data = { _ in
        Data("invalid".utf8)
    }
    let api = RakutenStockAPI(dataProvider: provider)
    let symbol = Symbol(code: "AAPL")

    do {
        _ = try await api.fetchMarketQuote(for: symbol)
        #expect(false, "Should throw")
    } catch is RakutenStockAPI.APIError {
        #expect(true)
    } catch {
        #expect(false, "Unexpected error")
    }
}

@Test
func testRakutenStockAPITransportError() async {
    struct TestError: Error {}
    let provider: (RakutenStockAPI.Endpoint) async throws -> Data = { _ in
        throw TestError()
    }
    let api = RakutenStockAPI(dataProvider: provider)
    let symbol = Symbol(code: "AAPL")

    do {
        _ = try await api.fetchTickList(for: symbol)
        #expect(false, "Should throw")
    } catch is TestError {
        #expect(true)
    } catch {
        #expect(false, "Unexpected error")
    }
}
