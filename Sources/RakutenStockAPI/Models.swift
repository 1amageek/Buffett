import Foundation

/// Represents a stock symbol.
public struct Symbol: Hashable, Codable {
    public var code: String
    public var name: String?

    public init(code: String, name: String? = nil) {
        self.code = code
        self.name = name
    }
}

/// Real-time market quote for a symbol.
public struct MarketQuote: Codable, Equatable {
    public var symbol: Symbol
    public var lastPrice: Double
    public var bid: Double?
    public var ask: Double?
    public var timestamp: Date

    public init(symbol: Symbol, lastPrice: Double, bid: Double? = nil, ask: Double? = nil, timestamp: Date = .init()) {
        self.symbol = symbol
        self.lastPrice = lastPrice
        self.bid = bid
        self.ask = ask
        self.timestamp = timestamp
    }
}

/// Individual trade tick data.
public struct TickData: Codable, Equatable {
    public var symbol: Symbol
    public var price: Double
    public var volume: Int
    public var timestamp: Date

    public init(symbol: Symbol, price: Double, volume: Int, timestamp: Date) {
        self.symbol = symbol
        self.price = price
        self.volume = volume
        self.timestamp = timestamp
    }
}

/// OHLCV (Open, High, Low, Close, Volume) candlestick data.
public struct OHLCVData: Codable, Equatable {
    public var symbol: Symbol
    public var timestamp: Date
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
    public var volume: Int

    public init(symbol: Symbol, timestamp: Date, open: Double, high: Double, low: Double, close: Double, volume: Int) {
        self.symbol = symbol
        self.timestamp = timestamp
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
}
