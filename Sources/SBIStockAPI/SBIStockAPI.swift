import Foundation

public enum SBIStockAPIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serverError(Int, Data?)
    case decodingError(Error)
    case unauthorized
    case unknown
}

public class SBIStockAPI {
    private let baseURL: URL
    private var apiToken: String?
    private let session: URLSession
    
    public init(baseURL: URL = URL(string: "http://localhost:18080/kabusapi")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Authentication
    
    public struct RequestToken: Codable {
        public let APIPassword: String
    }
    
    public struct TokenSuccess: Codable {
        public let ResultCode: Int
        public let Token: String
    }
    
    public struct ErrorResponse: Codable {
        public let Code: Int
        public let Message: String
    }
    
    /// Obtain API token by providing API password
    public func requestToken(apiPassword: String) async throws -> String {
        let url = baseURL.appendingPathComponent("token")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RequestToken(APIPassword: apiPassword)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw SBIStockAPIError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SBIStockAPIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let tokenResponse = try JSONDecoder().decode(TokenSuccess.self, from: data)
                if tokenResponse.ResultCode == 0 {
                    self.apiToken = tokenResponse.Token
                    return tokenResponse.Token
                } else {
                    throw SBIStockAPIError.serverError(tokenResponse.ResultCode, data)
                }
            } catch {
                throw SBIStockAPIError.decodingError(error)
            }
        case 401:
            throw SBIStockAPIError.unauthorized
        default:
            throw SBIStockAPIError.serverError(httpResponse.statusCode, data)
        }
    }
    
    // MARK: - Helper for authorized requests
    
    private func makeRequest<T: Codable>(path: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let token = apiToken else {
            throw SBIStockAPIError.unauthorized
        }
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw SBIStockAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(token, forHTTPHeaderField: "X-API-KEY")
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw SBIStockAPIError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SBIStockAPIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw SBIStockAPIError.decodingError(error)
            }
        case 401:
            throw SBIStockAPIError.unauthorized
        default:
            throw SBIStockAPIError.serverError(httpResponse.statusCode, data)
        }
    }
    
    // MARK: - Example: Get Wallet Cash (現物取引余力)
    
    public struct WalletCashSuccess: Codable {
        public let StockAccountWallet: Double?
        public let AuKCStockAccountWallet: Double?
        public let AuJbnStockAccountWallet: Double?
    }
    
    /// Get wallet cash (現物取引余力)
    public func getWalletCash() async throws -> WalletCashSuccess {
        return try await makeRequest(path: "wallet/cash")
    }
    
    // Additional API methods can be implemented similarly...
}
