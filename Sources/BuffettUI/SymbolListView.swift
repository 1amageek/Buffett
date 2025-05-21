import SwiftUI
import Buffett // For Symbol
import RakutenStockAPI // For StockAPIProtocol

@available(iOS 14.0, macOS 11.0, *)
public struct SymbolListView: View {
    public let symbols: [Symbol]
    public let api: StockAPIProtocol

    public init(symbols: [Symbol], api: StockAPIProtocol) {
        self.symbols = symbols
        self.api = api
    }

    public var body: some View {
        List {
            ForEach(symbols) { symbol in
                NavigationLink(destination: SymbolChartScreen(symbol: symbol, api: api)) {
                    VStack(alignment: .leading) {
                        Text(symbol.code)
                            .font(.headline)
                        Text(symbol.name)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4) // Add some padding for better row spacing
                }
            }
        }
        // The navigationTitle should ideally be set by the parent view (BuffettAppView)
        // to allow for more flexibility if SymbolListView is reused elsewhere.
    }
}

#if DEBUG
// Use the PreviewMockStockAPI defined in MultiChartView.swift or define a local one
// For simplicity, let's assume PreviewMockStockAPI is accessible or re-define a minimal one.

// If PreviewMockStockAPI from MultiChartView is not accessible due to file structure/targets,
// a local one for SymbolListView preview would be:
@MainActor
private class SymbolListPreviewMockStockAPI: StockAPIProtocol {
    func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        // Return minimal data for preview, specific to the symbol
        let now = Date()
        return [
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*1), open: 100, high: 105, low: 99, close: 102, volume: 1000),
            OHLCVData(symbol: symbol, timestamp: now, open: 102, high: 108, low: 101, close: 105, volume: 1200)
        ]
    }

    func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        fatalError("fetchMarketQuote not implemented for preview")
    }

    func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        fatalError("fetchTickList not implemented for preview")
    }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview {
    let sampleSymbols = [
        Symbol(code: "AAPL", name: "Apple Inc."),
        Symbol(code: "7203.T", name: "Toyota Motor Corp."),
        Symbol(code: "6758.T", name: "Sony Group Corp.")
    ]
    
    let mockAPI = SymbolListPreviewMockStockAPI()

    return NavigationView {
        SymbolListView(symbols: sampleSymbols, api: mockAPI)
            .navigationTitle("Stock Symbols") // Title set here for preview context
    }
}
#endif
