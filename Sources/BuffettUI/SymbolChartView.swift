import Foundation
#if canImport(SwiftUI)
import SwiftUI
import Charts
import RakutenStockAPI

public struct SymbolChartView: View {
    public var symbol: Symbol
    public var data: [OHLCVData]

    public init(symbol: Symbol, data: [OHLCVData]) {
        self.symbol = symbol
        self.data = data
    }

    public var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Time", item.timestamp),
                y: .value("Close", item.close)
            )
        }
        .chartYAxis(.hidden)
        .navigationTitle(symbol.code)
    }
}

#if DEBUG
#Preview {
    let symbol = Symbol(code: "AAPL", name: "Apple")
    let now = Date()
    let sample: [OHLCVData] = [
        .init(symbol: symbol, timestamp: now, open: 99.0, high: 101.0, low: 98.5, close: 100.5, volume: 1000)
    ]
    return SymbolChartView(symbol: symbol, data: sample)
}
#endif
#endif
