import Foundation
#if canImport(SwiftUI)
import SwiftUI
import Buffett
import RakutenStockAPI

/// Screen that loads and displays a chart for a given symbol using a ``ChartViewModel``.
public struct SymbolChartScreen: View {
    @StateObject private var viewModel: ChartViewModel

    // Custom init to allow injecting ChartViewModel, useful for previews with specific states
    public init(viewModel: ChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Public convenience init
    public init(symbol: Symbol, api: StockAPIProtocol) {
        _viewModel = StateObject(wrappedValue: ChartViewModel(symbol: symbol, api: api))
    }

    public var body: some View {
        VStack(spacing: 0) {
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(ChartTimePeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .onChange(of: viewModel.selectedPeriod) { newValue in
                // When selectedPeriod changes, call applyPeriodFilter to re-filter data
                // This assumes applyPeriodFilter is synchronous and on MainActor.
                viewModel.applyPeriodFilter()
            }

            if viewModel.data.isEmpty && viewModel.allFetchedData.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.data.isEmpty && !viewModel.allFetchedData.isEmpty {
                Text("No data available for the selected period: \(viewModel.selectedPeriod.displayName)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                SymbolChartView(
                    symbol: viewModel.symbol,
                    data: viewModel.data,
                    sma: viewModel.sma,
                    ema: viewModel.ema,
                    bollingerUpper: viewModel.bollingerUpper,
                    bollingerMiddle: viewModel.bollingerMiddle,
                    bollingerLower: viewModel.bollingerLower,
                    macdLine: viewModel.macdLine,
                    macdSignalLine: viewModel.macdSignalLine,
                    macdHistogram: viewModel.macdHistogram,
                    rsi: viewModel.rsi,
                    ichimokuTenkanSen: viewModel.ichimokuTenkanSen,
                    ichimokuKijunSen: viewModel.ichimokuKijunSen,
                    ichimokuSenkouSpanA: viewModel.ichimokuSenkouSpanA,
                    ichimokuSenkouSpanB: viewModel.ichimokuSenkouSpanB,
                    ichimokuChikouSpan: viewModel.ichimokuChikouSpan,
                    vwap: viewModel.vwap
                )
            }
        }
        .navigationTitle(viewModel.symbol.code)
        .task {
            // Initial fetch when the view appears
            await viewModel.fetch()
        }
    }
}

// MARK: - Previews
#if DEBUG

// Local Mock API for SymbolChartScreen Previews
@MainActor
private class SymbolChartScreenPreviewMockStockAPI: StockAPIProtocol {
    var mockChartData: [OHLCVData]?
    var mockError: Error?

    init(mockData: [OHLCVData]? = nil, mockError: Error? = nil) {
        self.mockError = mockError
        if let data = mockData {
            self.mockChartData = data
        } else {
            // Default mock data: ~3 months of daily data
            let symbol = Symbol(code: "PREVIEW", name: "Preview Corp")
            let now = Date()
            self.mockChartData = (0..<90).reversed().map { i in
                let date = Calendar.current.date(byAdding: .day, value: -i, to: now)!
                let close = Double(150 + sin(Double(i) / 10.0) * 20 + Double.random(in: -5...5))
                return OHLCVData(symbol: symbol, timestamp: date, open: close - Double.random(in: 0...5), high: close + Double.random(in: 0...5), low: close - Double.random(in: 0...5), close: close, volume: UInt64.random(in: 10000...50000))
            }
        }
    }

    func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        if let error = mockError {
            throw error
        }
        // Return mock data, ensuring the symbol matches the requested symbol
        var dataWithCorrectSymbol = mockChartData ?? []
        dataWithCorrectSymbol = dataWithCorrectSymbol.map {
            var d = $0; d.symbol = symbol; return d
        }
        return dataWithCorrectSymbol
    }

    func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote { fatalError("Not implemented for preview") }
    func fetchTickList(for symbol: Symbol) async throws -> [TickData] { fatalError("Not implemented for preview") }
}


@available(iOS 14.0, macOS 11.0, *)
#Preview("Default (1 Year)") {
    let symbol = Symbol(code: "AAPL", name: "Apple Inc.")
    let mockAPI = SymbolChartScreenPreviewMockStockAPI()
    let viewModel = ChartViewModel(symbol: symbol, api: mockAPI)
    // ViewModel's selectedPeriod defaults to .oneYear
    return NavigationView {
        SymbolChartScreen(viewModel: viewModel)
    }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview("1 Month") {
    let symbol = Symbol(code: "TSLA", name: "Tesla Inc.")
    let mockAPI = SymbolChartScreenPreviewMockStockAPI()
    let viewModel = ChartViewModel(symbol: symbol, api: mockAPI)
    viewModel.selectedPeriod = .oneMonth // Set specific period for this preview
    return NavigationView {
        SymbolChartScreen(viewModel: viewModel)
    }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview("1 Day (Potentially No Data)") {
    let symbol = Symbol(code: "GOOG", name: "Alphabet Inc.")
    // Use mock data that might not have "today's" data if filtered for 1D from its end.
    // The default mock data ends "today", so 1D *should* show the last day.
    let mockAPI = SymbolChartScreenPreviewMockStockAPI()
    let viewModel = ChartViewModel(symbol: symbol, api: mockAPI)
    viewModel.selectedPeriod = .oneDay
    return NavigationView {
        SymbolChartScreen(viewModel: viewModel)
    }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview("Empty Data for Period (e.g. 1D on old data)") {
    let symbol = Symbol(code: "OLD", name: "Old Data Corp")
    let veryOldData: [OHLCVData] = {
        let s = Symbol(code: "OLD", name: "Old Corp")
        let ancientDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())! // Data ends 2 years ago
        return [
            OHLCVData(symbol: s, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: ancientDate)!, open: 10, high: 12, low: 9, close: 11, volume: 100),
            OHLCVData(symbol: s, timestamp: ancientDate, open: 11, high: 13, low: 10, close: 12, volume: 100)
        ]
    }()
    let mockAPI = SymbolChartScreenPreviewMockStockAPI(mockData: veryOldData)
    let viewModel = ChartViewModel(symbol: symbol, api: mockAPI)
    viewModel.selectedPeriod = .oneDay // This will filter relative to the end of veryOldData, so it should show the last day of veryOldData.
                                      // To truly show "No data for period", the filter logic or data needs to ensure it.
                                      // Let's try to make the filter show no data:
                                      // If allFetchedData is old, selectedPeriod = .oneDay from Date() will show no data.
                                      // The current `applyPeriodFilter` calculates startDate from `allFetchedData.last?.timestamp`.
                                      // So, this will still show the last day of `veryOldData`.
                                      // To test the "No data available for the selected period" message,
                                      // one would need `allFetchedData` to be non-empty, but `selectedPeriod`
                                      // to filter it to empty. E.g. `allFetchedData` is only for last year,
                                      // but `selectedPeriod` is `oneDay` and `calculateStartDate` is based on `Date()`
                                      // *and* `allFetchedData` doesn't have data up to `Date()`.
                                      // This is a bit complex for a simple preview setup. The current preview will show the last day of old data.
    return NavigationView {
        SymbolChartScreen(viewModel: viewModel)
    }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview("API Error") {
    let symbol = Symbol(code: "ERR", name: "Error Corp")
    let mockAPI = SymbolChartScreenPreviewMockStockAPI(mockError: MockStockAPI.MockAPIError()) // Assuming MockAPIError is accessible
    let viewModel = ChartViewModel(symbol: symbol, api: mockAPI)
    return NavigationView {
        SymbolChartScreen(viewModel: viewModel)
    }
}

#endif
#endif
