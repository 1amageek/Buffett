import Foundation

public extension SBIStockAPI {
    // MARK: - Order Placement (現物・信用)
    
    struct RequestSendOrder: Codable {
        public let Symbol: String
        public let Exchange: Int
        public let SecurityType: Int
        public let Side: String
        public let CashMargin: Int
        public let MarginTradeType: Int?
        public let MarginPremiumUnit: Double?
        public let DelivType: Int
        public let FundType: String?
        public let AccountType: Int
        public let Qty: Int
        public let ClosePositionOrder: Int?
        public let ClosePositions: [Positions]?
        public let FrontOrderType: Int
        public let Price: Double
        public let ExpireDay: Int
        public let ReverseLimitOrder: ReverseLimitOrder?
        
        public struct Positions: Codable {
            public let HoldID: String
            public let Qty: Int
        }
        
        public struct ReverseLimitOrder: Codable {
            public let TriggerSec: Int
            public let TriggerPrice: Double
            public let UnderOver: Int
            public let AfterHitOrderType: Int
            public let AfterHitPrice: Double
        }
    }
    
    struct OrderSuccess: Codable {
        public let Result: Int
        public let OrderId: String
    }
    
    /// Place an order (現物・信用)
    func sendOrder(order: RequestSendOrder) async throws -> OrderSuccess {
        let body = try JSONEncoder().encode(order)
        return try await makeRequest(path: "sendorder", method: "POST", body: body)
    }
    
    // MARK: - Order Cancellation
    
    struct RequestCancelOrder: Codable {
        public let OrderId: String
    }
    
    /// Cancel an order
    func cancelOrder(orderId: String) async throws -> OrderSuccess {
        let cancelRequest = RequestCancelOrder(OrderId: orderId)
        let body = try JSONEncoder().encode(cancelRequest)
        return try await makeRequest(path: "cancelorder", method: "PUT", body: body)
    }
}
