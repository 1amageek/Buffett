import Foundation
#if canImport(SwiftUI)
import SwiftUI
import Buffett
import RakutenStockAPI

/// Screen that loads and displays a chart for a given symbol using a ``ChartViewModel``.
public struct SymbolChartScreen: View {
    @StateObject private var viewModel: ChartViewModel

    public init(symbol: Symbol, api: StockAPIProtocol = MockStockAPI()) {
        _viewModel = StateObject(wrappedValue: ChartViewModel(symbol: symbol, api: api))
    }

    public var body: some View {
        SymbolChartView(symbol: viewModel.symbol,
                        data: viewModel.data,
                        sma: viewModel.sma,
                        ema: viewModel.ema)
            .task {
                await viewModel.fetch()
            }
    }
}

#if DEBUG
#Preview {
    SymbolChartScreen(symbol: Symbol(code: "AAPL"))
}
#endif
#endif
