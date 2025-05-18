import Testing
@testable import Buffett

@Test
func testMockAPI() async throws {
    let api = MockStockAPI()
    let symbol = Symbol(code: "AAPL", name: "Apple")

    let quote = try await api.fetchMarketQuote(for: symbol)
    #expect(quote.symbol == symbol)
    #expect(quote.lastPrice == 100.0)

    let ticks = try await api.fetchTickList(for: symbol)
    #expect(!ticks.isEmpty)
    #expect(ticks.first?.symbol == symbol)

    let chart = try await api.fetchChart(for: symbol)
    #expect(chart.count == 1)
    #expect(chart.first?.open == 99.0)
}
