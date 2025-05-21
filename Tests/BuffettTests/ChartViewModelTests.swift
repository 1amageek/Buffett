import Testing
import Foundation
import BuffettUI
import Buffett
import RakutenStockAPI // Assuming Symbol, OHLCVData might be here or in Buffett

// MockStockAPI Implementation
@MainActor // To allow mutations from async contexts if needed, and align with ChartViewModel
class MockStockAPI: StockAPIProtocol {
    var mockChartData: [OHLCVData]?
    var mockError: Error?

    var fetchChartCalledForSymbol: Symbol?
    var fetchChartCallCount = 0

    // Custom error for testing
    struct MockAPIError: Error, LocalizedError {
        var errorDescription: String? { "Simulated API Error" }
    }

    func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        fetchChartCalledForSymbol = symbol
        fetchChartCallCount += 1
        
        if let error = mockError {
            throw error
        }
        return mockChartData ?? []
    }

    // Irrelevant methods for ChartViewModel tests
    func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        fatalError("fetchMarketQuote not implemented for ChartViewModel tests")
    }

    func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        fatalError("fetchTickList not implemented for ChartViewModel tests")
    }
}

// Sample Data for tests
struct SampleData {
    static let symbol = Symbol(code: "7203.T", name: "Toyota Motor Corp") // Example symbol

    static let ohlcvData: [OHLCVData] = [
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1672531200), open: 100, high: 105, low: 99, close: 102, volume: 1000), // Day 1
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1672617600), open: 102, high: 108, low: 101, close: 105, volume: 1200), // Day 2
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1672704000), open: 105, high: 110, low: 103, close: 108, volume: 1100), // Day 3
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1672790400), open: 108, high: 112, low: 107, close: 110, volume: 1300), // Day 4
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1672876800), open: 110, high: 115, low: 109, close: 112, volume: 1400), // Day 5
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1672963200), open: 112, high: 118, low: 111, close: 115, volume: 1500), // Day 6
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1673049600), open: 115, high: 120, low: 114, close: 118, volume: 1600), // Day 7
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1673136000), open: 118, high: 122, low: 117, close: 120, volume: 1700), // Day 8
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1673222400), open: 120, high: 125, low: 119, close: 122, volume: 1800), // Day 9
        OHLCVData(symbol: symbol, timestamp: Date(timeIntervalSince1970: 1673308800), open: 122, high: 128, low: 121, close: 125, volume: 1900)  // Day 10
    ]
    // Add more data if needed for longer period calculations
    
    // Expected values (simplified, actual calculations from Buffett library will be used by the ViewModel)
    // For full verification, these would be manually calculated for the sample data and specific periods.
    // For now, we'll mostly check for non-emptiness and counts.
}

@MainActor // Ensure tests run on the main actor, as ChartViewModel is MainActor
struct ChartViewModelTests {

    // Test (a): Successful Data Fetching and Indicator Calculation
    @Test func testFetchDataAndCalculateAllIndicatorsSuccessfully() async throws {
        let mockAPI = MockStockAPI()
        mockAPI.mockChartData = SampleData.ohlcvData
        
        let viewModel = ChartViewModel(symbol: SampleData.symbol, api: mockAPI)
        await viewModel.fetch()

        // Assert data is populated
        #expect(viewModel.data.count == SampleData.ohlcvData.count)
        if viewModel.data.count == SampleData.ohlcvData.count {
            #expect(viewModel.data[0].close == SampleData.ohlcvData[0].close)
            #expect(viewModel.data.last?.close == SampleData.ohlcvData.last?.close)
        }
        #expect(mockAPI.fetchChartCallCount == 1)
        #expect(mockAPI.fetchChartCalledForSymbol?.code == SampleData.symbol.code)

        // Assert indicators are calculated (non-empty and expected counts)
        let expectedCount = SampleData.ohlcvData.count
        #expect(viewModel.sma.count == expectedCount)
        #expect(viewModel.ema.count == expectedCount)
        #expect(viewModel.bollingerUpper.count == expectedCount)
        #expect(viewModel.bollingerMiddle.count == expectedCount)
        #expect(viewModel.bollingerLower.count == expectedCount)
        #expect(viewModel.macdLine.count == expectedCount)
        #expect(viewModel.macdSignalLine.count == expectedCount)
        #expect(viewModel.macdHistogram.count == expectedCount)
        #expect(viewModel.rsi.count == expectedCount)
        #expect(viewModel.ichimokuTenkanSen.count == expectedCount)
        #expect(viewModel.ichimokuKijunSen.count == expectedCount)
        #expect(viewModel.ichimokuSenkouSpanA.count == expectedCount)
        #expect(viewModel.ichimokuSenkouSpanB.count == expectedCount)
        #expect(viewModel.ichimokuChikouSpan.count == expectedCount)
        #expect(viewModel.vwap.count == expectedCount)

        // Assert specific calculated values for a few data points (SMA example)
        // Default SMA period is 5
        // SMA5 for SampleData.ohlcvData (close prices: 102, 105, 108, 110, 112, 115, 118, 120, 122, 125)
        // Index 4: (102+105+108+110+112)/5 = 107.4
        // Index 5: (105+108+110+112+115)/5 = 110.0
        // Index 9: (115+118+120+122+125)/5 = 120.0
        if viewModel.sma.count > 4 {
             #expect(viewModel.sma[4] == 107.4)
        }
        if viewModel.sma.count > 5 {
            #expect(viewModel.sma[5] == 110.0)
        }
        if viewModel.sma.count > 9 {
            #expect(viewModel.sma[9] == 120.0)
        }
        
        // Check if at least some values are non-nil for indicators that might have leading nils
        #expect(viewModel.sma.compactMap { $0 }.isEmpty == false)
        #expect(viewModel.ema.compactMap { $0 }.isEmpty == false)
        #expect(viewModel.bollingerUpper.compactMap { $0 }.isEmpty == false)
        // MACD can have many leading nils, especially with default 12, 26, 9 periods.
        // For 10 data points, MACD line, signal, histogram might be all nils or have very few values.
        // Let's check if that's the case or if we get some values.
        // Shortest period for MACD calculation is longPeriod + signalPeriod - 1 = 26 + 9 - 1 = 34.
        // So with 10 data points, all MACD values should be nil.
        #expect(viewModel.macdLine.allSatisfy { $0 == nil })
        #expect(viewModel.macdSignalLine.allSatisfy { $0 == nil })
        #expect(viewModel.macdHistogram.allSatisfy { $0 == nil })

        // RSI default period is 14. With 10 data points, all RSI values should be nil.
        #expect(viewModel.rsi.allSatisfy { $0 == nil })
        
        // Ichimoku Cloud default periods: Tenkan:9, Kijun:26, SenkouB:52.
        // Tenkan-sen (9 periods):
        // Index 8: (max(102..122) + min(102..122))/2 (using first 9 elements)
        // Highs: 105,108,110,112,115,118,120,122,125 (for full data)
        // Lows:  99,101,103,107,109,111,114,117,119 (for full data)
        // Data: 102,105,108,110,112,115,118,120,122 (first 9)
        // Max high in first 9: 122, Min low in first 9: 99. (122+99)/2 = 110.5
        if viewModel.ichimokuTenkanSen.count > 8 {
            #expect(viewModel.ichimokuTenkanSen[8] == 110.5)
        }
         // Kijun-sen (26 periods) will be nil for 10 data points.
        #expect(viewModel.ichimokuKijunSen.allSatisfy { $0 == nil })
        // Senkou Spans are shifted, will be nil.
        #expect(viewModel.ichimokuSenkouSpanA.allSatisfy { $0 == nil })
        #expect(viewModel.ichimokuSenkouSpanB.allSatisfy { $0 == nil })
        // Chikou Span is price shifted back by 26, will be nil.
        #expect(viewModel.ichimokuChikouSpan.allSatisfy { $0 == nil })

        // VWAP is cumulative, should have values from the start
        #expect(viewModel.vwap.compactMap { $0 }.isEmpty == false)
        if viewModel.vwap.count > 0 {
            // Day 1 VWAP: ( (105+99+102)/3 * 1000 ) / 1000 = (105+99+102)/3 = 306/3 = 102
            // Note: Buffett's VWAP uses (High+Low+Close)/3 for typical price.
            #expect(viewModel.vwap[0]! == (SampleData.ohlcvData[0].high + SampleData.ohlcvData[0].low + SampleData.ohlcvData[0].close) / 3.0)
        }
    }

    // Test (b): Initialization with Different Periods
    @Test func testIndicatorCalculationsWithCustomPeriods() async throws {
        let mockAPI = MockStockAPI()
        mockAPI.mockChartData = SampleData.ohlcvData
        
        let customSMAPeriod = 3
        let customEMAPeriod = 4
        let customBollingerPeriod = 6
        let customRsiPeriod = 7 // Needs at least 7 data points for a non-nil value at index 6
        let customMacdShort = 3
        let customMacdLong = 6
        let customMacdSignal = 2 // Needs at least long + signal - 1 = 6+2-1 = 7 data points for signal
                                // Needs at least long -1 = 5 data points for MACD line

        let viewModel = ChartViewModel(
            symbol: SampleData.symbol,
            api: mockAPI,
            smaPeriod: customSMAPeriod,
            emaPeriod: customEMAPeriod,
            bollingerPeriod: customBollingerPeriod,
            rsiPeriod: customRsiPeriod,
            macdShortPeriod: customMacdShort,
            macdLongPeriod: customMacdLong,
            macdSignalPeriod: customMacdSignal
        )
        await viewModel.fetch()

        #expect(viewModel.data.count == SampleData.ohlcvData.count)

        // SMA with period 3
        // Data: 102, 105, 108, 110, 112, 115, 118, 120, 122, 125
        // Index 2: (102+105+108)/3 = 105.0
        // Index 9: (120+122+125)/3 = 122.333...
        if viewModel.sma.count > 2 {
            #expect(viewModel.sma[2] == 105.0)
        }
        if viewModel.sma.count > 9 {
            #expect(viewModel.sma[9]! == (120.0+122.0+125.0)/3.0)
        }
        
        // RSI with period 7
        // RSI needs period + 1 data points to calculate first value. So at index 7 (8th element) for period 7.
        // For SampleData.ohlcvData (10 items), RSI(7) should produce values from index 6 onwards.
        #expect(viewModel.rsi.compactMap { $0 }.isEmpty == false)
        if viewModel.rsi.count > 6 {
             #expect(viewModel.rsi[6] != nil) // First possible value
        }
         // With 10 data points, RSI(7) should have 10 - 7 = 3 non-nil values if not accounting for initial smoothing.
         // RSI calculation is complex, so just check for non-nil for now.
        #expect(viewModel.rsi[SampleData.ohlcvData.count - 1] != nil)


        // MACD(3,6,2)
        // MACD Line (EMA(3) - EMA(6)) needs at least 6 data points to be calculated (index 5)
        // MACD Signal (EMA(2) of MACD Line) needs at least 6 (for MACD line) + 2 -1 = 7 data points (index 6)
        if viewModel.macdLine.count > 4 { #expect(viewModel.macdLine[4] == nil) } // EMA(6) not ready
        if viewModel.macdLine.count > 5 { #expect(viewModel.macdLine[5] != nil) } // First MACD line value
        if viewModel.macdSignalLine.count > 5 { #expect(viewModel.macdSignalLine[5] == nil) }
        if viewModel.macdSignalLine.count > 6 { #expect(viewModel.macdSignalLine[6] != nil) } // First signal value
        if viewModel.macdHistogram.count > 6 { #expect(viewModel.macdHistogram[6] != nil ) } // First histogram value
    }

    // Test (c): Test API Error Handling During Fetch
    @Test func testFetchDataWithAPIError() async throws {
        let mockAPI = MockStockAPI()
        mockAPI.mockError = MockStockAPI.MockAPIError()
        
        let viewModel = ChartViewModel(symbol: SampleData.symbol, api: mockAPI)
        // Pre-populate some data to see if it's cleared
        viewModel.data = [SampleData.ohlcvData[0]]
        viewModel.sma = [100.0]
        let initialData = viewModel.data
        let initialSma = viewModel.sma
        
        await viewModel.fetch()

        // Assert that data and indicators are NOT cleared if fetch fails and data was present
        #expect(viewModel.data.count == initialData.count) 
        if !initialData.isEmpty && !viewModel.data.isEmpty {
            #expect(viewModel.data[0].close == initialData[0].close)
        }
        #expect(viewModel.sma.count == initialSma.count)
        if !initialSma.isEmpty && !viewModel.sma.isEmpty {
            #expect(viewModel.sma[0] == initialSma[0])
        }
        // Other indicators would also remain unchanged.
        // This test now verifies the current behavior.
        // A future change to ChartViewModel might involve clearing data/indicators on fetch error.
        
        #expect(mockAPI.fetchChartCallCount == 1)
    }

    // Test (d): Test Fetching with Empty API Response
    @Test func testFetchDataWithEmptyAPIResponse() async throws {
        let mockAPI = MockStockAPI()
        mockAPI.mockChartData = [] // Empty response
        
        let viewModel = ChartViewModel(symbol: SampleData.symbol, api: mockAPI)
        await viewModel.fetch()

        #expect(viewModel.data.isEmpty)
        #expect(viewModel.sma.isEmpty)
        #expect(viewModel.ema.isEmpty)
        #expect(viewModel.bollingerUpper.isEmpty)
        #expect(viewModel.macdLine.isEmpty)
        #expect(viewModel.rsi.isEmpty)
        #expect(viewModel.ichimokuTenkanSen.isEmpty)
        #expect(viewModel.vwap.isEmpty)
        #expect(mockAPI.fetchChartCallCount == 1)
    }

    // Test (e): Test Indicator Calculation when `data` is Empty
    @Test func testUpdateIndicatorsWithEmptyData() {
        let mockAPI = MockStockAPI() // Not strictly needed here but ChartViewModel requires an API
        let viewModel = ChartViewModel(symbol: SampleData.symbol, api: mockAPI)
        
        #expect(viewModel.data.isEmpty) // Should be empty by default

        viewModel.updateIndicators() // Manually call updateIndicators

        #expect(viewModel.data.isEmpty) // Data should remain empty
        #expect(viewModel.sma.isEmpty)
        #expect(viewModel.ema.isEmpty)
        #expect(viewModel.bollingerUpper.isEmpty)
        #expect(viewModel.bollingerMiddle.isEmpty)
        #expect(viewModel.bollingerLower.isEmpty)
        #expect(viewModel.macdLine.isEmpty)
        #expect(viewModel.macdSignalLine.isEmpty)
        #expect(viewModel.macdHistogram.isEmpty)
        #expect(viewModel.rsi.isEmpty)
        #expect(viewModel.ichimokuTenkanSen.isEmpty)
        #expect(viewModel.ichimokuKijunSen.isEmpty)
        #expect(viewModel.ichimokuSenkouSpanA.isEmpty)
        #expect(viewModel.ichimokuSenkouSpanB.isEmpty)
        #expect(viewModel.ichimokuChikouSpan.isEmpty)
        #expect(viewModel.vwap.isEmpty)
    }
}
