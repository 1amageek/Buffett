# techContext.md

## Technologies Used

- Swift programming language for iOS/macOS development
- SwiftUI for declarative UI design
- Combine framework for reactive programming
- Swift Package Manager (SPM) for dependency management
- Swift OpenAPI Generator for API client code generation
- Swift Charts for data visualization

## Development Setup

- Xcode IDE for development and debugging
- Localhost communication with kabu Station API for real-time data
- Unit testing with XCTest framework

## Technical Constraints

- Real-time data processing requirements
- Efficient memory and CPU usage for mobile devices
- Secure handling of API keys and user data

## Dependencies

- SBIStockAPI package generated via OpenAPI Generator
- Swift Charts framework for visualization
- Combine framework for reactive data flow
## Technologies Used

* Swift 6.1+
* SwiftUI
* Swift Charts
* Xcode 16+
* Swift Package Manager (SPM)
* Swift OpenAPI Generator (v3.1)
* Combine framework

## Development Setup

* macOS 14 or later
* iOS 17 or later
* kabu Station API local client running on Windows environment

## Technical Constraints

* kabu Station API requires local Windows client application running
* API rate limits (approximately 10 requests per second for data retrieval)
* Maximum of 50 registered symbols for real-time data subscription

## Dependencies

* Swift OpenAPI Generator
* OpenAPIRuntime
* OpenAPIURLSession

## Tool Usage Patterns

* Automated API client generation via OpenAPI specification
* Reactive programming patterns using Combine for responsive UI
* Modular development approach using Swift Package Manager for scalability
