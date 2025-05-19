import Testing
import Foundation
@testable import BuffettUI
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
    let sma = SMAIndicator.calculate(values: values, period: 3)
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
    let ema = EMAIndicator.calculate(values: values, period: 3)
    #expect(ema[2] == 2.0)
    #expect(ema[3] == 3.0)
    #expect(ema[4] == 4.0)
}

@Test
func testMACDIndicator() {
    let values: [Double] = [1, 2, 3, 4, 5, 6, 7]
    let result = MACDIndicator.calculate(values: values, fastPeriod: 3, slowPeriod: 5, signalPeriod: 3)
    let macd = result.0
    let signal = result.1
    #expect(macd[6] != nil)
    #expect(signal[6] != nil)
}

@Test
func testRSIIndicator() {
    let values = Array(1...15).map(Double.init)
    let rsi = RSIIndicator.calculate(values: values, period: 14)
    let lastWrapped = rsi.last ?? nil
    let last = lastWrapped ?? 0
    #expect(last > 90)
}

@Test
func testRSIInsufficientData() {
    let values = Array(1...10).map(Double.init)
    let rsi = RSIIndicator.calculate(values: values, period: 14)
    #expect(rsi.allSatisfy { $0 == nil })
}

@Test
func testBollingerBands() {
    let values: [Double] = [1, 2, 3, 4, 5]
    let bands = BollingerBandsIndicator.calculate(values: values, period: 3)
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
    let vwap = VWAPIndicator.calculate(for: data)
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
    let ichimoku = IchimokuCloudIndicator.calculate(for: data)
    #expect(ichimoku.0[8] == 6)
}

@Test
func testIchimokuComponentsAll() {
    let symbol = Symbol(code: "ICH")
    let data = Array(repeating: OHLCVData(symbol: symbol, timestamp: .init(), open: 0, high: 10, low: 0, close: 7, volume: 0), count: 80)
    let ichimoku = IchimokuCloudIndicator.calculate(for: data)
    let tenkan = ichimoku.0
    let kijun = ichimoku.1
    let senkouA = ichimoku.2
    let senkouB = ichimoku.3
    let chikou = ichimoku.4
    #expect(tenkan[8] == 5)
    #expect(kijun[25] == 5)
    #expect(senkouA[51] == 5)
    #expect(senkouB[77] == 5)
    #expect(chikou[0] == 7)
}

@Test
func testChartViewModelFetch() async {
    let symbol = Symbol(code: "AAPL")
    let vm = await MainActor.run { ChartViewModel(symbol: symbol, api: MockStockAPI()) }
    await vm.fetch()
    let data = await vm.data
    #expect(!data.isEmpty)
    #expect(data.first?.symbol == symbol)
}

@Test
func testViewModelIndicatorsAndView() async {
    let symbol = Symbol(code: "TST")
    var sample: [OHLCVData] = []
    let now = Date()
    for i in 0..<5 {
        sample.append(
            OHLCVData(symbol: symbol,
                      timestamp: now.addingTimeInterval(Double(i) * 60),
                      open: 0, high: 0, low: 0,
                      close: Double(i + 1), volume: 1)
        )
    }

    let vm = await MainActor.run { ChartViewModel(symbol: symbol, api: MockStockAPI(), smaPeriod: 3, emaPeriod: 3) }
    await MainActor.run {
        vm.data = sample
        vm.updateIndicators()
    }
    let sma = await vm.sma
    let ema = await vm.ema
    #expect(sma[2] == 2)
    #expect(ema[2] == 2)

#if canImport(SwiftUI)
    let view = SymbolChartView(symbol: symbol, data: sample, sma: sma, ema: ema)
    _ = view.body
#endif
}
