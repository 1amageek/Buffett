# Technical Context for Buffett Application

## Technologies Used

* Swift 6.1+ for native macOS application development.
* SwiftUI for declarative UI construction.
* Swift Charts for advanced charting and visualization.
* Swift Package Manager (SPM) for dependency management and modularization.
* Combine framework and async/await for reactive and asynchronous programming.
* Swift Testing framework for unit and UI testing.
* Rakuten Securities MarketSpeed II API (RSS) for real-time stock data.

## Development Environment

* macOS 14 or later.
* Xcode 16 or later.
* Swift toolchain compatible with Swift 6.1+.
* Local development and testing on macOS machines.

## Dependencies and Libraries

* Swift Charts: Provides native charting components optimized for performance and integration with SwiftUI.
* Swift OpenAPI Generator (planned): For generating API client code from OpenAPI specifications.
* Combine: For reactive data streams and state management.
* Swift Testing: For writing and running unit and UI tests.

## Build and Packaging

* Use Swift Package Manager to manage modules and dependencies.
* Separate modules for API logic (RakutenStockAPI) and UI (BuffettApp).
* Continuous integration setup recommended for automated testing and builds.

## Constraints and Considerations

* API access requires MarketSpeed II Windows application running and logged in.
* Data fetching is pull-based (polling), requiring efficient scheduling and throttling.
* Performance optimization critical for handling up to 500 stocks with multiple indicators.
* UI responsiveness must be maintained with asynchronous data handling and background processing.

## Testing Strategy

* Unit tests for API wrappers and data models.
* Unit tests for ViewModels and business logic.
* UI tests for key user interactions and chart rendering.
* Performance tests to ensure scalability and responsiveness.

## Future Technical Plans

* Integration of Swift OpenAPI Generator for API client code generation.
* Expansion of testing coverage and automation.
* Potential use of caching layers or local databases for historical data.
* Exploration of advanced concurrency patterns for performance.

This technical context provides the foundation for development and maintenance of the Buffett application.
