# System Patterns for Buffett Application

## Architecture Pattern

* MVVM (Model-View-ViewModel) is the core architectural pattern.
  - Model: Data models representing stock data, technical indicators, and user annotations.
  - View: SwiftUI views rendering charts, lists, and UI controls.
  - ViewModel: Manages data transformation, business logic, and state binding between Model and View.

## Module Structure

* Modular separation between API logic and UI logic.
  - API Module (RakutenStockAPI): Handles all communication with Rakuten Securities MarketSpeed II API, data fetching, and parsing.
  - UI Module (BuffettApp): Contains SwiftUI views, ViewModels, and user interaction logic.

## Data Flow

* Unidirectional data flow from API to UI.
  - API Module fetches and updates data models.
  - ViewModels observe data models and update Views reactively.
  - User interactions in Views trigger ViewModel actions, which may request API updates or local state changes.

## State Management

* Each stock window manages its own independent state.
* Shared state for stock categories and symbol lists managed at the main app level.
* Use of Swift’s Combine framework or async/await for reactive and asynchronous data updates.

## Testing Patterns

* Unit tests for API data models and API call wrappers.
* Unit tests for ViewModels focusing on data transformation and binding correctness.
* UI tests for critical user flows and chart interactions.

## Performance Optimization

* Efficient data polling with throttling to handle up to 500 stocks.
* Caching of computed technical indicators to avoid redundant calculations.
* Background processing for heavy computations to keep UI responsive.

## Error Handling

* Graceful handling of API errors and network issues.
* User notifications for critical failures.
* Retry mechanisms with exponential backoff for data fetching.

## UI Patterns

* Use of SwiftUI’s `WindowGroup` for multi-window support.
* Dynamic chart components supporting multiple overlays.
* Toggle switches and legends for technical indicator visibility.
* Annotation tools integrated into chart views.

## Design Patterns

* Use of pure functions and structs for technical indicator calculations.
* Dependency injection for API clients to facilitate testing.
* Observer pattern via Combine for reactive UI updates.

This document captures the key system design and architectural patterns guiding Buffett’s development.
