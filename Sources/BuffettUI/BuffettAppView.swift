import SwiftUI
import Buffett // For Symbol
import RakutenStockAPI // For StockAPIProtocol and RakutenStockAPI

@available(iOS 14.0, macOS 11.0, *)
public struct BuffettAppView: View {
    // For live testing, use the real API. For UI previews or testing where network is unavailable/undesirable,
    // you might switch this to a mock API.
    private let api: StockAPIProtocol = RakutenStockAPI()

    // Predefined list of symbols for the user to choose from.
    // Using a mix of US and Japanese stock examples.
    // Note: Correct ticker symbols for Rakuten Stock API might differ. These are illustrative.
    private let predefinedSymbols: [Symbol] = [
        Symbol(code: "AAPL", name: "Apple Inc."), // US Stock
        Symbol(code: "GOOGL", name: "Alphabet Inc. (Google)"), // US Stock
        Symbol(code: "MSFT", name: "Microsoft Corp."), // US Stock
        Symbol(code: "TSLA", name: "Tesla Inc."), // US Stock
        Symbol(code: "7203.T", name: "Toyota Motor Corp."), // Japanese Stock (Illustrative .T suffix)
        Symbol(code: "6758.T", name: "Sony Group Corp."), // Japanese Stock (Illustrative .T suffix)
        Symbol(code: "9984.T", name: "SoftBank Group Corp."), // Japanese Stock (Illustrative .T suffix)
        Symbol(code: "1570.T", name: "Nikkei Leveraged ETF") // Example ETF
    ]

    public init() {
        // Default initializer
    }

    public var body: some View {
        NavigationView {
            SymbolListView(symbols: predefinedSymbols, api: api)
                .navigationTitle("Stock Symbols")
        }
    }
}

#if DEBUG
// Local Mock API for BuffettAppView Previews, in case SymbolListView's preview isn't sufficient
// or if we want to test BuffettAppView with a specific mock setup.
// Using the same PreviewMockStockAPI from MultiChartView or defining one if not shared.
@MainActor
private class BuffettAppViewPreviewMockStockAPI: StockAPIProtocol {
    func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        let now = Date()
        // Simulate slightly different data per symbol for preview if needed
        let closePriceStart = Double(symbol.code.hashValue % 50 + 100) // pseudo-random start
        return [
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*2), open: closePriceStart, high: closePriceStart+5, low: closePriceStart-1, close: closePriceStart+2, volume: 1000),
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*1), open: closePriceStart+2, high: closePriceStart+8, low: closePriceStart+1, close: closePriceStart+5, volume: 1200),
            OHLCVData(symbol: symbol, timestamp: now, open: closePriceStart+5, high: closePriceStart+10, low: closePriceStart+3, close: closePriceStart+8, volume: 1100)
        ]
    }
    func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote { fatalError("Not needed for this preview") }
    func fetchTickList(for symbol: Symbol) async throws -> [TickData] { fatalError("Not needed for this preview") }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview("Live API") {
    // This preview will use the live RakutenStockAPI.
    // Ensure you have network connectivity and the API is functional.
    // It might be slow or fail if the API has issues.
    BuffettAppView()
}

@available(iOS 14.0, macOS 11.0, *)
#Preview("Mock API") {
    // This preview uses a mock API for faster and more reliable UI previews.
    let mockAPI = BuffettAppViewPreviewMockStockAPI()
    
    // Create a temporary BuffettAppView that uses the mock API.
    // This requires a way to inject the API, or a temporary struct version.
    // For simplicity of this exercise, we can't directly change `api` in BuffettAppView for preview.
    // A common approach is an internal initializer for testing/previewing:
    // struct BuffettAppView: View {
    //     private let api: StockAPIProtocol
    //     public init() { self.api = RakutenStockAPI() }
    //     internal init(api: StockAPIProtocol) { self.api = api } // For previews/tests
    // ...
    // }
    // Assuming such an internal init `init(api: StockAPIProtocol)` was added to BuffettAppView for previews:
    // return BuffettAppView(api: mockAPI) 
    //
    // If not, we can only preview BuffettAppView with its default API,
    // or wrap SymbolListView directly if we want to guarantee a mock for the preview.
    
    // Let's demonstrate wrapping SymbolListView directly for a guaranteed mock preview,
    // as modifying BuffettAppView's init is outside this step's direct scope.
    let predefinedSymbols: [Symbol] = [
        Symbol(code: "AAPL", name: "Apple Inc."),
        Symbol(code: "7203.T", name: "Toyota Motor Corp.")
    ]
    return NavigationView {
        SymbolListView(symbols: predefinedSymbols, api: mockAPI)
            .navigationTitle("Stock Symbols (Mock)")
    }
}
#endif
