# Active Context for Buffett Application

## Current Work Focus

* Implementing the Buffett macOS native application for real-time stock price analysis.
* Integration with Rakuten Securities MarketSpeed II API (RSS) for live data.
* Developing modular architecture separating API logic (RakutenStockAPI) and UI (BuffettApp).
* Building core features including multi-stock charting, technical indicators, and multi-window support.
* Establishing testing frameworks for API, ViewModel, and UI components.

## Recent Changes

* Defined detailed project specifications and milestones.
* Established system architecture and design patterns (MVVM, reactive data flow).
* Set up technical context including development environment and dependencies.
* Created initial data models and API wrappers for Market, TickList, and Chart data.
* Started implementation of charting components using Swift Charts.

## Next Steps

* Complete API wrappers for all required RSS endpoints.
* Implement ViewModels for data binding and transformation.
* Develop UI components for stock lists, categories, and multi-window chart views.
* Integrate technical indicator calculations and overlay support.
* Add annotation and canvas features for user analysis.
* Write unit and UI tests to ensure reliability and correctness.
* Optimize performance for handling up to 500 stocks with real-time updates.

## Active Decisions and Considerations

* Use Swift’s async/await and Combine for asynchronous data handling.
* Polling strategy for data fetching with throttling to balance performance and freshness.
* Modular SPM package structure to separate concerns and enable testing.
* UI design to leverage macOS WindowGroup for independent stock windows.
* Client-side calculation of technical indicators for flexibility and responsiveness.
* Annotation tools integrated directly into chart views for seamless user experience.

This active context reflects the current development priorities and guides ongoing work on Buffett.
