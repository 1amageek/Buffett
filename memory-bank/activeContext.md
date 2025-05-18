# activeContext.md

## Current Work Focus

- Enhancing real-time data integration with kabu Station API
- Improving technical indicator calculations and accuracy
- Refining Swift Charts visualizations for better user experience
- Modularizing codebase for easier maintenance and scalability

## Recent Changes

- Updated API client to latest OpenAPI specification
- Refactored ViewModels to use Combine for reactive updates
- Improved error handling for API communication failures

## Next Steps

- Implement additional technical indicators requested by users
- Optimize data fetching to reduce latency and CPU usage
- Add unit and integration tests for new features
- Enhance UI responsiveness and accessibility

## Active Decisions and Considerations

- Choosing between local caching strategies for market data
- Balancing real-time updates with battery and resource consumption
- Planning for multi-platform support (iOS and macOS)
- Evaluating potential integration with other financial data sources
## Current Work Focus

* Establishing robust integration with SBI Securities' kabu Station API using Swift OpenAPI Generator
* Developing modular Swift Package (SBIStockAPI) for clean separation of API logic from UI components

## Recent Changes

* Decided to utilize Swift OpenAPI Generator for maintaining strongly typed and easily maintainable API client code

## Next Steps

* Implement and validate data retrieval from kabu Station API
* Begin development of technical indicators computation logic
* Design initial Swift Charts-based visualization

* Propose and implement detailed flow for integration and visualization
## Active Decisions and Considerations

* Using MVVM architecture for clear separation between data models, view models, and views
* Keeping API logic separate to ensure modularity and reusability

## Important Patterns and Preferences

* Prioritize clarity and performance in data visualization
* Ensure robust error handling and user-friendly messaging for API interactions

## Learnings and Project Insights

* Swift OpenAPI Generator significantly simplifies API client maintenance and reduces errors through strongly typed interfaces
