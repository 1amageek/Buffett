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
    public var annotations: [PriceAnnotation] // Added annotations

    // State for managing the visible x-axis domain for zoom/pan
    @State private var xVisibleDomain: ClosedRange<Date>? // Using Date for time-based x-axis

    public init(symbol: Symbol, data: [OHLCVData],
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
                vwap: [Double?]? = nil,
                annotations: [PriceAnnotation] = []) { // Added annotations with default
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
            // Chikou Span (Lagging Span): Current closing price plotted 26 periods in the past.
            // The `ichimokuChikouSpan` array from the ViewModel is not directly used for Y-values here,
            // as its current calculation (chikou[k] = data[k+26].close) would represent a leading span if plotted directly.
            // We use `data[idx].close` as the Y-value and shift its X-coordinate.
            // The presence of `ichimokuChikouSpan` acts as a flag to plot this indicator.
            if ichimokuChikouSpan != nil { // Check if the indicator should be plotted
                let offsetPeriod = 26 
                ForEach(Array(data.indices), id: .self) { idx in
                    if idx >= offsetPeriod {
                        let currentCloseForChikou = data[idx].close // Y-value is current close
                        let pastTimestampForChikou = data[idx - offsetPeriod].timestamp // X-value is 26 periods ago
                        
                        LineMark(
                            x: .value("Time", pastTimestampForChikou),
                            y: .value("Chikou Span", currentCloseForChikou)
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

            // Price Annotations
            ForEach(annotations) { annotation in
                RuleMark(y: .value("Annotation", annotation.priceLevel))
                    .foregroundStyle(annotation.color)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text(annotation.label ?? String(format: "%.2f", annotation.priceLevel))
                            .font(.caption)
                            .foregroundColor(annotation.color)
                            .padding(.leading, 4)
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
        .navigationTitle(symbol.code)
        // Add a gesture for pinch-to-zoom if needed, though chartXScale might provide some level of this.
        // For more control, a MagnificationGesture could update xVisibleDomain.
        // This is a basic setup; true pinch-to-zoom might require more.

        return VStack {
            chartContent
            HStack {
                Button("Zoom In") { zoomIn() }
                    .padding()
                    .disabled(data.isEmpty)
                Button("Zoom Out") { zoomOut() }
                    .padding()
                    .disabled(data.isEmpty || xVisibleDomain == nil) // Can't zoom out if already at full view
                Button("Reset Zoom") { xVisibleDomain = nil }
                    .padding()
                    .disabled(data.isEmpty)
            }
            .padding(.bottom)
        }
    }

    // MARK: - Zoom Functions
    private func getDefaultXDomain() -> ClosedRange<Date> {
        guard !data.isEmpty, let firstDate = data.first?.timestamp, let lastDate = data.last?.timestamp else {
            // Fallback for no data: a small default range around now.
            let now = Date()
            return now.addingTimeInterval(-3600)...now
        }
        return firstDate...lastDate
    }

    private func zoomIn() {
        guard !data.isEmpty else { return }
        let currentDomain = xVisibleDomain ?? getDefaultXDomain()
        let fullDomain = getDefaultXDomain() // For clamping

        let duration = currentDomain.upperBound.timeIntervalSince(currentDomain.lowerBound)
        // Zoom in by 25%, but ensure new duration is at least a minimum interval (e.g., 3 data points if possible, or a fixed time)
        let minDuration: TimeInterval
        if data.count >= 3 {
            // Smallest interval between first 3 data points as a guess, or a fixed sensible minimum
            let firstThreeTimestamps = data.prefix(3).map { $0.timestamp }
            let interval1 = firstThreeTimestamps.count > 1 ? firstThreeTimestamps[1].timeIntervalSince(firstThreeTimestamps[0]) : TimeInterval(3600*24)
            let interval2 = firstThreeTimestamps.count > 2 ? firstThreeTimestamps[2].timeIntervalSince(firstThreeTimestamps[1]) : TimeInterval(3600*24)
            minDuration = max(TimeInterval(3600), min(interval1, interval2) * 2) // at least 1 hour, or 2x smallest interval found
        } else {
            minDuration = TimeInterval(3600 * 24) // Default to 1 day if less than 3 data points
        }

        let newDuration = max(minDuration, duration * 0.75)


        let centerDate = currentDomain.lowerBound.addingTimeInterval(duration / 2)
        var newLowerBound = centerDate.addingTimeInterval(-newDuration / 2)
        var newUpperBound = centerDate.addingTimeInterval(newDuration / 2)

        // Clamp to available data
        newLowerBound = max(newLowerBound, fullDomain.lowerBound)
        newUpperBound = min(newUpperBound, fullDomain.upperBound)
        
        // Ensure newLowerBound is not after newUpperBound after clamping
        if newLowerBound > newUpperBound {
            newLowerBound = newUpperBound.addingTimeInterval(-minDuration) // fallback
            newLowerBound = max(newLowerBound, fullDomain.lowerBound)
        }
         if newUpperBound.timeIntervalSince(newLowerBound) < minDuration && newLowerBound == fullDomain.lowerBound {
            newUpperBound = newLowerBound.addingTimeInterval(minDuration)
            newUpperBound = min(newUpperBound, fullDomain.upperBound)
        } else if newUpperBound.timeIntervalSince(newLowerBound) < minDuration && newUpperBound == fullDomain.upperBound {
             newLowerBound = newUpperBound.addingTimeInterval(-minDuration)
             newLowerBound = max(newLowerBound, fullDomain.lowerBound)
        }


        xVisibleDomain = newLowerBound...newUpperBound
    }

    private func zoomOut() {
        guard !data.isEmpty, let currentDomain = xVisibleDomain else {
            xVisibleDomain = nil // Reset if no current domain or no data
            return
        }

        let fullDataDomain = getDefaultXDomain()
        let duration = currentDomain.upperBound.timeIntervalSince(currentDomain.lowerBound)
        let newDuration = duration * 1.33 // Zoom out

        // If new duration is larger than or very close to full data range, reset to show all
        if newDuration >= fullDataDomain.upperBound.timeIntervalSince(fullDataDomain.lowerBound) * 0.98 {
            xVisibleDomain = nil
            return
        }

        let centerDate = currentDomain.lowerBound.addingTimeInterval(duration / 2)
        var newLowerBound = centerDate.addingTimeInterval(-newDuration / 2)
        var newUpperBound = centerDate.addingTimeInterval(newDuration / 2)
        
        // Clamp to available data, but allow it to reach full extent
        newLowerBound = max(newLowerBound, fullDataDomain.lowerBound)
        newUpperBound = min(newUpperBound, fullDataDomain.upperBound)
        
        // If clamping makes the domain smaller than intended (e.g. hit both ends of fullDomain), reset.
        if newLowerBound == fullDataDomain.lowerBound && newUpperBound == fullDataDomain.upperBound {
            xVisibleDomain = nil
        } else {
            xVisibleDomain = newLowerBound...newUpperBound
        }
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

    let sampleAnnotations: [PriceAnnotation] = [
        PriceAnnotation(priceLevel: 103.0, label: "Support"),
        PriceAnnotation(priceLevel: 105.5, color: .red, label: "Resistance")
    ]

    return SymbolChartView(
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
        vwap: vwapSample,
        annotations: sampleAnnotations
    )
}
#endif
#endif
