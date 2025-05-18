# systemPatterns.md

## System Architecture

- Modular architecture separating API logic (SBIStockAPI package) from UI
- Swift Package Manager (SPM) used for dependency management and modularization
- MVVM (Model-View-ViewModel) design pattern for clear separation of concerns

## Key Technical Decisions

- Swift OpenAPI Generator (v3.1) for strongly-typed and maintainable API client code generation
- Localhost communication with kabu Station API for real-time market data

## Design Patterns

- Repository pattern for data management
- ObservableObject and Combine framework for reactive UI updates

## Component Relationships

- SBIStockAPI as a standalone package, consumed by Buffett's main application
- ViewModels responsible for business logic and communication between views and data layers

## Critical Implementation Paths

- API data fetching and processing
- Technical indicators calculation logic
- Efficient and responsive UI rendering via SwiftUI and Swift Charts
