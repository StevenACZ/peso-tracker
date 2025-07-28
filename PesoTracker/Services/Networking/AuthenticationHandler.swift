import Foundation

class AuthenticationHandler {
    
    // MARK: - JWT Token Management
    func getJWTToken() -> String? {
        return KeychainHelper.shared.get(key: Constants.Keychain.jwtToken)
    }
    
    func setAuthorizationHeader(for request: inout URLRequest) {
        if let token = getJWTToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: Constants.API.Headers.authorization)
        }
    }
    
    func getAuthHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        if let token = getJWTToken() {
            headers[Constants.API.Headers.authorization] = "Bearer \(token)"
        }
        return headers
    }
    
    func clearToken() {
        KeychainHelper.shared.delete(key: Constants.Keychain.jwtToken)
    }
    
    func hasValidToken() -> Bool {
        return getJWTToken() != nil
    }
}