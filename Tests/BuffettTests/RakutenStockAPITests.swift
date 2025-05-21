import Testing
import Foundation
@testable import RakutenStockAPI // Import the module to be tested
@testable import Buffett // For Symbol, OHLCVData etc. if they are defined here

// Helper to skip tests if MarketSpeed II is not available
// This is a placeholder. A more robust mechanism might be needed,
// potentially involving environment variables or a configuration file.
// For now, we can rely on manual skipping or conditional execution if tests fail due to MSII absence.
let isMarketSpeedIIAvailable: Bool = {
    // Placeholder: In a real CI environment, this might check an env variable.
    // For local testing, developer needs to ensure MSII is running.
    // For now, let's assume it's available for test writing purposes,
    // but tests should be structured to handle its absence gracefully if possible.
    print("Reminder: RakutenStockAPI tests require MarketSpeed II to be running and logged in.")
    print("If MarketSpeed II is not available, these tests may fail or be skipped.")
    return true // Assume available for now, actual check is hard programmatically from SPM tests.
}()

struct RakutenStockAPITests {

    // Shared API instance for tests
    // This will make actual network calls to local MarketSpeed II
    let api = RakutenStockAPI()
    let testSymbol = Symbol(code: "7203", name: "Toyota Motor Corp") // Toyota, generally a valid symbol

    @Test("Fetch Market Quote - Successful Case")
    @available(macOS 14.0, *) // Or your project's minimum deployment target
    func testFetchMarketQuote_Success() async throws {
        guard isMarketSpeedIIAvailable else { throw SkipError() }

        let quote = try await api.fetchMarketQuote(for: testSymbol)
        
        #expect(quote.symbol.code == testSymbol.code, "Symbol code in the quote should match the requested symbol.")
        #expect(quote.lastPrice > 0, "Last price should be greater than 0 for a valid symbol.")
        // Depending on market hours, bid/ask might be 0, so these are more robust checks:
        #expect(quote.askPrice >= 0, "Ask price should be greater than or equal to 0.")
        #expect(quote.bidPrice >= 0, "Bid price should be greater than or equal to 0.")
        if quote.bidPrice > 0 && quote.askPrice > 0 {
            #expect(quote.askPrice >= quote.bidPrice, "Ask price should be greater than or equal to bid price when both are positive.")
        }
        // Add checks for other relevant properties if necessary, e.g., name, exchange.
        // #expect(quote.name == testSymbol.name) // Name might differ slightly based on API source
        #expect(!quote.change.isNaN, "Change should be a valid number.")
        #expect(!quote.percentChange.isNaN, "Percent change should be a valid number.")
        #expect(quote.high > 0 || quote.lastPrice > 0, "High price should be positive if last price is positive.") // Market might not have opened yet
        #expect(quote.low > 0 || quote.lastPrice > 0, "Low price should be positive if last price is positive.")   // Market might not have opened yet
        if quote.high > 0 && quote.low > 0 {
            #expect(quote.high >= quote.low, "High price should be greater than or equal to low price.")
        }
        #expect(quote.open > 0 || quote.lastPrice > 0, "Open price should be positive if last price is positive.")
        #expect(quote.volume >= 0, "Volume should be greater than or equal to 0.")
    }

    @Test("Fetch Market Quote - Invalid Symbol")
    @available(macOS 14.0, *)
    func testFetchMarketQuote_InvalidSymbol() async throws {
        guard isMarketSpeedIIAvailable else { throw SkipError() }
        let invalidSymbol = Symbol(code: "INVALID", name: "Invalid Symbol")

        var thrownError: Error?
        do {
            _ = try await api.fetchMarketQuote(for: invalidSymbol)
        } catch {
            thrownError = error
        }
        #expect(thrownError != nil, "Fetching market quote for an invalid symbol should throw an error.")

        // Optional: Further inspect the error if specific error types or messages are known.
        // For example, if RakutenStockAPI throws a specific error like `APIError.symbolNotFound`:
        // if let apiError = thrownError as? APIError {
        //     #expect(apiError == APIError.symbolNotFound)
        // } else {
        //     #expect(thrownError is APIError, "Error should be of type APIError")
        // }
        // For now, just checking that *an* error is thrown is sufficient.
    }

    @Test("Fetch Tick List - Successful Case")
    @available(macOS 14.0, *)
    func testFetchTickList_Success() async throws {
        guard isMarketSpeedIIAvailable else { throw SkipError() }

        let ticks = try await api.fetchTickList(for: testSymbol)
        
        // It's possible for tick lists to be empty depending on market activity and API behavior.
        // However, for a major symbol like Toyota during market hours (or with recent data),
        // we usually expect some ticks. If this test is flaky, this expectation might need adjustment
        // or the test might need to be run when fresh tick data is guaranteed.
        #expect(!ticks.isEmpty, "Tick list for a valid, active symbol should ideally not be empty.")
        
        for tick in ticks {
            #expect(tick.symbol.code == testSymbol.code, "Symbol code in tick data should match the requested symbol.")
            #expect(tick.price > 0, "Tick price should be greater than 0.")
            #expect(tick.volume >= 0, "Tick volume should be greater than or equal to 0.") // Some ticks might be quotes without volume
            #expect(tick.timestamp <= Date(), "Tick timestamp should not be in the future.")
        }
        
        if let firstTick = ticks.first {
            // Redundant check if loop above is comprehensive, but good for clarity
            #expect(firstTick.symbol.code == testSymbol.code)
            #expect(firstTick.price > 0)
        }
    }

    @Test("Fetch Chart Data (OHLCV) - Successful Case")
    @available(macOS 14.0, *)
    func testFetchChart_Success() async throws {
        guard isMarketSpeedIIAvailable else { throw SkipError() }

        let ohlcvData = try await api.fetchChart(for: testSymbol)
        
        #expect(!ohlcvData.isEmpty, "OHLCV chart data for a valid symbol should not be empty.")
        
        for bar in ohlcvData {
            #expect(bar.symbol.code == testSymbol.code, "Symbol code in OHLCV data should match the requested symbol.")
            #expect(bar.open > 0, "Open price should be greater than 0.")
            #expect(bar.high > 0, "High price should be greater than 0.")
            #expect(bar.low > 0, "Low price should be greater than 0.")
            #expect(bar.close > 0, "Close price should be greater than 0.")
            #expect(bar.volume >= 0, "Volume should be greater than or equal to 0.")
            #expect(bar.high >= bar.low, "High price should be greater than or equal to low price.")
            // Further specific checks for OHLCV consistency:
            #expect(bar.high >= bar.open, "High price should be greater than or equal to open price.")
            #expect(bar.high >= bar.close, "High price should be greater than or equal to close price.")
            #expect(bar.low <= bar.open, "Low price should be less than or equal to open price.")
            #expect(bar.low <= bar.close, "Low price should be less than or equal to close price.")
            #expect(bar.timestamp <= Date(), "OHLCV bar timestamp should not be in the future.")
        }
        
        if let firstBar = ohlcvData.first {
            // Redundant if loop is comprehensive, but good for specific first bar checks if needed
            #expect(firstBar.symbol.code == testSymbol.code)
            #expect(firstBar.high >= firstBar.low)
        }
    }

    // Optional: Test for error when MarketSpeed II is not running.
    // This is harder to automate reliably without manual intervention or specific environment setup.
    // Consider if this is feasible or if manual testing covers this.
    // @Test("API Call - MarketSpeed II Not Available")
    // func testApiCall_MarketSpeedIINotAvailable() async throws {
    //     // This test would require ensuring MSII is *not* running.
    //     // Then, expect a specific error related to connection failure.
    // }
}

// Helper to allow skipping tests from within the test function
// (standard #expect(throws: SkipError.self) doesn't work well with async tests directly for skipping)
struct SkipError: Error {}
