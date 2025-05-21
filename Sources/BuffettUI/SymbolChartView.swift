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
    public var macdLine: [Double?]?
    public var macdSignalLine: [Double?]?
    public var macdHistogram: [Double?]?
    public var rsi: [Double?]?
    public var ichimokuTenkanSen: [Double?]?
    public var ichimokuKijunSen: [Double?]?
    public var ichimokuSenkouSpanA: [Double?]?
    public var ichimokuSenkouSpanB: [Double?]?
    public var ichimokuChikouSpan: [Double?]?
    public var vwap: [Double?]?

    let resetID: UUID // Added for reset functionality

    // State for managing the visible x-axis domain for zoom/pan
    @State private var xVisibleDomain: ClosedRange<Date>? // Using Date for time-based x-axis
    @GestureState private var magnifyBy: CGFloat = 1.0
    @State private var lastMagnificationValue: CGFloat = 1.0

    public init(resetID: UUID, // Added for reset functionality
                symbol: Symbol, data: [OHLCVData],
                sma: [Double?]? = nil,
                ema: [Double?]? = nil,
                bollingerUpper: [Double?]? = nil,
                bollingerMiddle: [Double?]? = nil,
                bollingerLower: [Double?]? = nil,
                macdLine: [Double?]? = nil,
                macdSignalLine: [Double?]? = nil,
                macdHistogram: [Double?]? = nil,
                rsi: [Double?]? = nil,
                ichimokuTenkanSen: [Double?]? = nil,
                ichimokuKijunSen: [Double?]? = nil,
                ichimokuSenkouSpanA: [Double?]? = nil,
                ichimokuSenkouSpanB: [Double?]? = nil,
                ichimokuChikouSpan: [Double?]? = nil,
                vwap: [Double?]? = nil) {
        self.resetID = resetID // Initialize resetID
        self.symbol = symbol
        self.data = data
        self.sma = sma
        self.ema = ema
        self.bollingerUpper = bollingerUpper
        self.bollingerMiddle = bollingerMiddle
        self.bollingerLower = bollingerLower
        self.macdLine = macdLine
        self.macdSignalLine = macdSignalLine
        self.macdHistogram = macdHistogram
        self.rsi = rsi
        self.ichimokuTenkanSen = ichimokuTenkanSen
        self.ichimokuKijunSen = ichimokuKijunSen
        self.ichimokuSenkouSpanA = ichimokuSenkouSpanA
        self.ichimokuSenkouSpanB = ichimokuSenkouSpanB
        self.ichimokuChikouSpan = ichimokuChikouSpan
        self.vwap = vwap
    }

    public var body: some View {
        let chartContent = Chart {
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

            // MACD
            if let line = macdLine, let signal = macdSignalLine {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let lValue = line[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("MACD Line", lValue)
                        )
                        .foregroundStyle(.cyan)
                    }
                    if let sValue = signal[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("MACD Signal", sValue)
                        )
                        .foregroundStyle(.mint)
                    }
                }
            }
            if let histogram = macdHistogram {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let hValue = histogram[idx] {
                        // Represent histogram as thinner lines for now, BarMark needs more setup for x width
                        BarMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("MACD Hist", hValue),
                            width: .fixed(1) // Make bars thin
                        )
                        .foregroundStyle(hValue >= 0 ? .gray.opacity(0.5) : .black.opacity(0.5))
                    }
                }
            }

            // RSI
            if let rsiValues = rsi {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let value = rsiValues[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("RSI", value) // Note: RSI scale is 0-100, might need separate axis in a real app
                        )
                        .foregroundStyle(.pink)
                    }
                }
            }
            
            // Ichimoku Cloud
            if let tenkan = ichimokuTenkanSen {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let value = tenkan[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("Tenkan-sen", value)
                        )
                        .foregroundStyle(.brown)
                    }
                }
            }
            if let kijun = ichimokuKijunSen {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let value = kijun[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("Kijun-sen", value)
                        )
                        .foregroundStyle(.purple)
                    }
                }
            }
            // Chikou Span - plotted against current timestamp.
            // TODO: Shift x-axis by -26 periods for accurate representation.
            if let chikou = ichimokuChikouSpan {
                ForEach(Array(data.indices), id: .self) { idx in
                    // Ensure we don't go out of bounds if chikou is shorter
                    if idx < chikou.count, let value = chikou[idx] {
                         LineMark(
                             x: .value("Time", data[idx].timestamp),
                             y: .value("Chikou Span", value)
                         )
                         .foregroundStyle(.yellow)
                    }
                }
            }
            if let senkouA = ichimokuSenkouSpanA, let senkouB = ichimokuSenkouSpanB {
                ForEach(Array(data.indices), id: .self) { idx in
                    // Ensure indices are valid for all arrays involved
                    if idx < data.count && idx < senkouA.count && idx < senkouB.count,
                       let sa = senkouA[idx], let sb = senkouB[idx] {
                        AreaMark(
                            x: .value("Time", data[idx].timestamp),
                            yStart: .value("Senkou A", sa),
                            yEnd: .value("Senkou B", sb)
                        )
                        .foregroundStyle(sa > sb ? .green.opacity(0.2) : .red.opacity(0.2))
                    }
                }
            }

            // VWAP
            if let vwapValues = vwap {
                ForEach(Array(data.indices), id: .self) { idx in
                    if let value = vwapValues[idx] {
                        LineMark(
                            x: .value("Time", data[idx].timestamp),
                            y: .value("VWAP", value)
                        )
                        .foregroundStyle(.blue.opacity(0.7))
                    }
                }
            }
        }
        }
        .chartYAxis(.hidden) // Consider if some indicators like RSI should have their own axis.
        // Apply chartXScale if xVisibleDomain is set, otherwise let the chart decide its domain.
        // This allows for programmatic zoom reset or initial visible range setting.
        .if(xVisibleDomain != nil) { chart in
            chart.chartXScale(domain: xVisibleDomain!)
        }
        .chartScrollableAxes(.horizontal) // Enable horizontal panning
        .gesture(magnificationGesture) // Ensure gesture is correctly placed
        .onChange(of: data) { oldData, newData in
            // Reset the visible domain when the underlying data changes
            // (e.g., due to period selection change)
            xVisibleDomain = nil
            lastMagnificationValue = 1.0 // Reset zoom level on data change
        }
        .onChange(of: resetID) { _, _ in
            xVisibleDomain = nil
            lastMagnificationValue = 1.0
        }
        .navigationTitle(symbol.code)
        // Add a gesture for pinch-to-zoom if needed, though chartXScale might provide some level of this.
        // For more control, a MagnificationGesture could update xVisibleDomain.
        // This is a basic setup; true pinch-to-zoom might require more.

        return chartContent
    }

    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                // Apply the cumulative zoom
                let newMagnification = lastMagnificationValue * value
                updateXVisibleDomain(scale: newMagnification / lastMagnificationValue) // Pass the change in scale
                lastMagnificationValue = newMagnification // Store for next cumulative zoom
                // Note: lastMagnificationValue could grow very large or small.
                // Consider clamping or resetting it under certain conditions if needed.
                // For now, this allows continuous zooming.
            }
    }

    private func updateXVisibleDomain(scale: CGFloat) {
        guard !data.isEmpty else { return }

        let currentDomain: ClosedRange<Date>
        if let existingDomain = xVisibleDomain {
            currentDomain = existingDomain
        } else {
            // If no domain is set, use the full data range
            guard let firstDate = data.first?.timestamp, let lastDate = data.last?.timestamp else { return }
            currentDomain = firstDate...lastDate
        }

        let currentDuration = currentDomain.upperBound.timeIntervalSinceReferenceDate - currentDomain.lowerBound.timeIntervalSinceReferenceDate
        let newDuration = currentDuration / Double(scale) // Zoom in if scale > 1, zoom out if scale < 1

        // For simplicity, zoom around the center of the current domain
        let centerDateInterval = (currentDomain.lowerBound.timeIntervalSinceReferenceDate + currentDomain.upperBound.timeIntervalSinceReferenceDate) / 2.0
        
        var newLowerBound = Date(timeIntervalSinceReferenceDate: centerDateInterval - newDuration / 2.0)
        var newUpperBound = Date(timeIntervalSinceReferenceDate: centerDateInterval + newDuration / 2.0)

        // Ensure the new domain does not exceed the bounds of all available data
        if let overallFirstDate = data.first?.timestamp, let overallLastDate = data.last?.timestamp {
            if newLowerBound < overallFirstDate { newLowerBound = overallFirstDate }
            if newUpperBound > overallLastDate { newUpperBound = overallLastDate }
            
            // Ensure newLowerBound is not after newUpperBound after clamping (can happen if zoom is too much)
            if newLowerBound > newUpperBound {
                if scale > 1 { // Zooming in too much
                    newLowerBound = newUpperBound // Or set to a minimal sensible range around center
                } else { // Zooming out too much (should be covered by overall bounds)
                    // This case should ideally not be problematic if overall bounds are respected
                }
            }
        }
        
        // Prevent an infinitely small domain or inverted domain
        let minDuration: TimeInterval = 60 * 60 * 24 // Minimum 1 day visible, adjust as needed
        if newUpperBound.timeIntervalSinceReferenceDate - newLowerBound.timeIntervalSinceReferenceDate < minDuration {
            if scale > 1 { // Zooming in
                 // Keep the old domain or adjust slightly if possible, but don't go below minDuration
                 // For now, if we hit minDuration, don't zoom in further via this path.
                 // Or, center the minDuration window.
                let center = newLowerBound.addingTimeInterval((newUpperBound.timeIntervalSinceReferenceDate - newLowerBound.timeIntervalSinceReferenceDate) / 2)
                newLowerBound = center.addingTimeInterval(-minDuration / 2)
                newUpperBound = center.addingTimeInterval(minDuration / 2)
                // Recalmp to overall bounds
                if let overallFirstDate = data.first?.timestamp, let overallLastDate = data.last?.timestamp {
                     if newLowerBound < overallFirstDate { newLowerBound = overallFirstDate }
                     if newUpperBound > overallLastDate { newUpperBound = overallLastDate }
                }
                if newLowerBound >= newUpperBound { // If clamping made it invalid
                    xVisibleDomain = currentDomain // Revert to old domain
                    return
                }
            }
            // If zooming out, minDuration check is less critical as it's expanding.
        }

        xVisibleDomain = newLowerBound...newUpperBound
    }
}

// Helper to conditionally apply modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#if DEBUG
#Preview {
    let symbol = Symbol(code: "AAPL", name: "Apple")
    let now = Date()
    // Create a slightly larger sample for better indicator visualization
    let sampleTimestamps = (0..<10).map { Calendar.current.date(byAdding: .day, value: $0, to: now)! }
    let sampleClosePrices = [100.5, 101.2, 100.8, 102.0, 103.5, 103.0, 104.2, 105.0, 104.5, 106.0]
    
    let sampleData: [OHLCVData] = sampleTimestamps.enumerated().map { idx, ts in
        OHLCVData(symbol: symbol, timestamp: ts, open: sampleClosePrices[idx] - 0.5, high: sampleClosePrices[idx] + 0.5, low: sampleClosePrices[idx] - 1.0, close: sampleClosePrices[idx], volume: 1000 + UInt64(idx * 100))
    }

    // Sample indicator data (ensure counts match sampleData or handle nil/shorter arrays)
    // For simplicity, let's make them the same length as sampleData, with some nil values
    let count = sampleData.count
    let smaSample: [Double?] = (0..<count).map { i in i > 2 ? sampleClosePrices[i-2...i].reduce(0, +) / 3.0 : nil } // Simple moving average
    let emaSample: [Double?] = (0..<count).map { i in i > 2 ? sampleClosePrices[i] * 0.5 + (smaSample[i-1] ?? sampleClosePrices[i-1]) * 0.5 : nil } // Simplified EMA
    
    let macdLineSample: [Double?] = (0..<count).map { i in i > 4 ? Double(i % 5 - 2) * 0.1 : nil } // Oscillating
    let macdSignalSample: [Double?] = (0..<count).map { i in i > 5 ? Double((i-1) % 5 - 2) * 0.1 : nil }
    let macdHistogramSample: [Double?] = (0..<count).map { i in
        if let line = macdLineSample[i], let signal = macdSignalSample[i] { return line - signal }
        return nil
    }
    
    let rsiSample: [Double?] = (0..<count).map { i in Double(50 + (i % 10 - 5) * 5) } // 0-100 range
    
    let tenkanSample: [Double?] = (0..<count).map { i in sampleClosePrices[i] * 0.98 }
    let kijunSample: [Double?] = (0..<count).map { i in sampleClosePrices[i] * 0.96 }
    let senkouASample: [Double?] = (0..<count).map { i in i < count - 3 ? (tenkanSample[i+1]! + kijunSample[i+1]!) / 2 : nil } // Shifted slightly for effect
    let senkouBSample: [Double?] = (0..<count).map { i in i < count - 3 ? (tenkanSample[i+2]! + kijunSample[i+2]!) / 2 * 0.99 : nil } // Shifted slightly
    let chikouSample: [Double?] = (0..<count).map { i in i > 2 ? sampleClosePrices[i-2] : nil } // Shifted back
    
    let vwapSample: [Double?] = (0..<count).map { i in sampleClosePrices[i] * 0.99 }


    return SymbolChartView(
        resetID: UUID(), // Added for preview
        symbol: symbol,
        data: sampleData,
        sma: smaSample,
        ema: emaSample,
        // Bollinger Bands data could also be added here if desired
        macdLine: macdLineSample,
        macdSignalLine: macdSignalSample,
        macdHistogram: macdHistogramSample,
        rsi: rsiSample,
        ichimokuTenkanSen: tenkanSample,
        ichimokuKijunSen: kijunSample,
        ichimokuSenkouSpanA: senkouASample,
        ichimokuSenkouSpanB: senkouBSample,
        ichimokuChikouSpan: chikouSample,
        vwap: vwapSample
    )
}
#endif
#endif
