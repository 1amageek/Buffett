import Foundation
#if canImport(SwiftUI)
import SwiftUI
import Charts
import RakutenStockAPI

public struct SymbolChartView: View {
    public var symbol: Symbol
    public var data: [OHLCVData]
    public var sma: [Double?]?
    public var ema: [Double?]?
    public var bollingerUpper: [Double?]?
    public var bollingerMiddle: [Double?]?
    public var bollingerLower: [Double?]?

    public init(symbol: Symbol, data: [OHLCVData],
                sma: [Double?]? = nil,
                ema: [Double?]? = nil,
                bollingerUpper: [Double?]? = nil,
                bollingerMiddle: [Double?]? = nil,
                bollingerLower: [Double?]? = nil) {
        self.symbol = symbol
        self.data = data
        self.sma = sma
        self.ema = ema
        self.bollingerUpper = bollingerUpper
        self.bollingerMiddle = bollingerMiddle
        self.bollingerLower = bollingerLower
    }

    public var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: .offset) { _, item in
                LineMark(
                    x: .value("Time", item.timestamp),
                    y: .value("Close", item.close)
                )
            }

            if let sma = sma {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let value = sma[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("SMA", value)
                        )
                        .foregroundStyle(.blue)
                    }
                }
            }

            if let ema = ema {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let value = ema[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("EMA", value)
                        )
                        .foregroundStyle(.orange)
                    }
                }
            }

            if let upper = bollingerUpper,
               let middle = bollingerMiddle,
               let lower = bollingerLower {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let u = upper[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("BB Upper", u)
                        )
                        .foregroundStyle(.green)
                    }
                    if let m = middle[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("BB Middle", m)
                        )
                        .foregroundStyle(.purple)
                    }
                    if let l = lower[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("BB Lower", l)
                        )
                        .foregroundStyle(.red)
                    }
                }
            }
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
