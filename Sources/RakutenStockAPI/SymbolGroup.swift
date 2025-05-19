import Foundation

/// Represents a group of related stock symbols.
public struct SymbolGroup: Codable, Equatable, Sendable {
    public var name: String
    public private(set) var symbols: [Symbol]

    public init(name: String, symbols: [Symbol] = []) {
        self.name = name
        self.symbols = symbols
    }

    /// Adds a symbol to the group if it's not already present.
    public mutating func add(_ symbol: Symbol) {
        guard !symbols.contains(symbol) else { return }
        symbols.append(symbol)
    }

    /// Removes a symbol from the group if present.
    public mutating func remove(_ symbol: Symbol) {
        symbols.removeAll { $0 == symbol }
    }
}
