import Foundation

public extension SBIStockAPI {
    // MARK: - Wallet Queries
    
    struct WalletMarginSuccess: Codable {
        public let MarginAccountWallet: Double?
        public let DepositkeepRate: Double?
        public let ConsignmentDepositRate: Double?
        public let CashOfConsignmentDepositRate: Double?
    }
    
    /// Get wallet margin (信用取引余力)
    func getWalletMargin() async throws -> WalletMarginSuccess {
        return try await makeRequest(path: "wallet/margin")
    }
    
    struct WalletFutureSuccess: Codable {
        public let FutureTradeLimit: Double?
        public let MarginRequirement: Double?
        public let MarginRequirementSell: Double?
    }
    
    /// Get wallet future (先物取引余力)
    func getWalletFuture() async throws -> WalletFutureSuccess {
        return try await makeRequest(path: "wallet/future")
    }
    
    struct WalletOptionSuccess: Codable {
        public let OptionBuyTradeLimit: Double?
        public let OptionSellTradeLimit: Double?
        public let MarginRequirement: Double?
    }
    
    /// Get wallet option (オプション取引余力)
    func getWalletOption() async throws -> WalletOptionSuccess {
        return try await makeRequest(path: "wallet/option")
    }
}
