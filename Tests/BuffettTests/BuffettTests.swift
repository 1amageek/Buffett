import Testing
@testable import Buffett
@testable import RakutenStockAPI

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

@Test
func testEMAIndicator() {
    let values: [Double] = [1, 2, 3, 4, 5]
    let ema = TechnicalIndicators.exponentialMovingAverage(values: values, period: 3)
    #expect(ema[2] == 2.0)
    #expect(ema[3] == 3.0)
    #expect(ema[4] == 4.0)
}

@Test
func testMACDIndicator() {
    let values: [Double] = [1, 2, 3, 4, 5, 6, 7]
    let result = TechnicalIndicators.movingAverageConvergenceDivergence(values: values, fastPeriod: 3, slowPeriod: 5, signalPeriod: 3)
    let macd = result.0
    let signal = result.1
    #expect(macd[6] != nil)
    #expect(signal[6] != nil)
}

@Test
func testRSIIndicator() {
    let values = Array(1...15).map(Double.init)
    let rsi = TechnicalIndicators.relativeStrengthIndex(values: values, period: 14)
    let lastWrapped = rsi.last ?? nil
    let last = lastWrapped ?? 0
    #expect(last > 90)
}

@Test
func testBollingerBands() {
    let values: [Double] = [1, 2, 3, 4, 5]
    let bands = TechnicalIndicators.bollingerBands(values: values, period: 3)
    let upper = bands.0
    let middle = bands.1
    let lower = bands.2
    #expect(middle[2] == 2.0)
    #expect(upper[2]! > middle[2]!)
    #expect(lower[2]! < middle[2]!)
}

@Test
func testVWAP() {
    let symbol = Symbol(code: "TST")
    let data: [OHLCVData] = [
        .init(symbol: symbol, timestamp: .init(), open: 0, high: 0, low: 0, close: 10, volume: 100),
        .init(symbol: symbol, timestamp: .init(), open: 0, high: 0, low: 0, close: 20, volume: 100),
        .init(symbol: symbol, timestamp: .init(), open: 0, high: 0, low: 0, close: 30, volume: 200)
    ]
    let vwap = TechnicalIndicators.volumeWeightedAveragePrice(for: data)
    #expect(vwap[0] == 10)
    #expect(vwap[1] == 15)
    #expect(vwap[2] == 22.5)
}

@Test
func testIchimokuTenkan() {
    let symbol = Symbol(code: "ICH")
    var data: [OHLCVData] = []
    for i in 0..<9 {
        let high = Double(i + 3)
        let low = Double(i + 1)
        data.append(OHLCVData(symbol: symbol, timestamp: .init(), open: 0, high: high, low: low, close: high - 1, volume: 0))
    }
    let ichimoku = TechnicalIndicators.ichimokuCloud(for: data)
    #expect(ichimoku.0[8] == 6)
}
