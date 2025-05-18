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

@Test
func testSymbolGroupAddRemove() {
    var group = SymbolGroup(name: "Tech")
    let apple = Symbol(code: "AAPL")
    group.add(apple)
    #expect(group.symbols.contains(apple))
    group.remove(apple)
    #expect(!group.symbols.contains(apple))
}

@Test
func testSMAIndicator() {
    let values: [Double] = [1, 2, 3, 4, 5]
    let sma = TechnicalIndicators.simpleMovingAverage(values: values, period: 3)
    // Expect first two elements to be nil
    #expect(sma[0] == nil)
    #expect(sma[1] == nil)
    #expect(sma[2] == 2.0)
    #expect(sma[3] == 3.0)
    #expect(sma[4] == 4.0)
}
