# Buffett

Buffett is a Swift Package that provides core models, technical indicator utilities and API integrations for building a macOS or iOS stock analysis application. It includes a SwiftUI charting module capable of overlaying indicators such as SMA, EMA and Bollinger Bands.

## Project Structure

- **Sources/Buffett** – Data models, indicator calculations and the `StockAPIProtocol`.
- **Sources/RakutenStockAPI** – Implements `StockAPIProtocol` using Rakuten Securities MarketSpeed II API (RSS) for real market data. The module exposes async methods like `fetchMarketQuote`, `fetchTickList` and `fetchChart`.
- **Tests** – Contains unit tests written with Swift Testing.

## Usage

```swift
import Buffett
import RakutenStockAPI

let api = RakutenStockAPI()
let symbol = Symbol(code: "7203", name: "Toyota")
let quote = try await api.fetchMarketQuote(for: symbol)
print(quote.lastPrice)

let ticks = try await api.fetchTickList(for: symbol)
print(ticks.first?.price ?? 0)

let chart = try await api.fetchChart(for: symbol)
print(chart.count)
```

`RakutenStockAPI` requires that MarketSpeed II is running and logged in on your machine.

## Running Tests

Execute the package tests with:

```bash
swift test
```

This will run all `@Test` cases under `Tests/`.
