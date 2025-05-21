import SwiftUI
import Buffett // For Symbol
import RakutenStockAPI // For StockAPIProtocol and Symbol (if not in Buffett)

@available(iOS 14.0, macOS 11.0, *)
public struct MultiChartView: View {
    public let symbols: [Symbol]
    public let api: StockAPIProtocol
    private let gridItems: [GridItem]

    public init(symbols: [Symbol], api: StockAPIProtocol, columns: Int = 2) {
        self.symbols = symbols
        self.api = api
        self.gridItems = Array(repeating: GridItem(.flexible()), count: max(1, columns)) // Ensure at least 1 column
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing: 20) {
                ForEach(symbols) { symbol in
                    VStack {
                        Text(symbol.code)
                            .font(.headline)
                            .padding(.top)
                        
                        // Assuming SymbolChartScreen is designed to fetch its own data via its ViewModel
                        SymbolChartScreen(symbol: symbol, api: api)
                            .frame(height: 300) // Example height, adjust as needed
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Multiple Charts") // Or any other appropriate title
    }
}

#if DEBUG
// Local Mock API for Previews
@MainActor
class PreviewMockStockAPI: StockAPIProtocol {
    var mockChartData: [OHLCVData]? = {
        let symbol = Symbol(code: "DUMMY", name: "Dummy Corp")
        let now = Date()
        return [
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*4), open: 100, high: 105, low: 99, close: 102, volume: 1000),
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*3), open: 102, high: 108, low: 101, close: 105, volume: 1200),
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*2), open: 105, high: 110, low: 103, close: 108, volume: 1100),
            OHLCVData(symbol: symbol, timestamp: now.addingTimeInterval(-86400*1), open: 108, high: 112, low: 107, close: 110, volume: 1300),
            OHLCVData(symbol: symbol, timestamp: now, open: 110, high: 115, low: 109, close: 112, volume: 1400)
        ]
    }()
    var mockError: Error?

    func fetchChart(for symbol: Symbol) async throws -> [OHLCVData] {
        if let error = mockError {
            throw error
        }
        // Return the same mock data for any symbol in preview for simplicity
        var dataWithCorrectSymbol = mockChartData ?? []
        dataWithCorrectSymbol = dataWithCorrectSymbol.map {
            var d = $0
            d.symbol = symbol // Ensure the data has the correct symbol
            return d
        }
        return dataWithCorrectSymbol
    }

    func fetchMarketQuote(for symbol: Symbol) async throws -> MarketQuote {
        fatalError("fetchMarketQuote not implemented for PreviewMockStockAPI")
    }

    func fetchTickList(for symbol: Symbol) async throws -> [TickData] {
        fatalError("fetchTickList not implemented for PreviewMockStockAPI")
    }
}

@available(iOS 14.0, macOS 11.0, *)
#Preview {
    let sampleSymbols = [
        Symbol(code: "AAPL", name: "Apple Inc."),
        Symbol(code: "GOOG", name: "Alphabet Inc."),
        Symbol(code: "MSFT", name: "Microsoft Corp."),
        Symbol(code: "TSLA", name: "Tesla Inc.")
    ]
    
    let mockAPI = PreviewMockStockAPI()

    return NavigationView { // Often useful to have a NavigationView for previews
        MultiChartView(symbols: sampleSymbols, api: mockAPI, columns: 2)
    }
}
#endif
