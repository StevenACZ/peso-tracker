import Foundation

// MARK: - JWT Helper
struct JWTHelper {
    
    // MARK: - JWT Token Validation
    static func isTokenExpired(_ token: String, bufferMinutes: Int = 2) -> Bool {
        guard let payload = decodeJWTPayload(token),
              let exp = payload["exp"] as? TimeInterval else {
            print("🔐 [JWT] Could not decode token expiration - treating as expired")
            return true
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp)
        let bufferDate = Date().addingTimeInterval(TimeInterval(bufferMinutes * 60))
        
        let isExpired = bufferDate >= expirationDate
        
        if isExpired {
            print("🔐 [JWT] Token expires at \(expirationDate), treating as expired (buffer: \(bufferMinutes) min)")
        } else {
            let remainingMinutes = Int(expirationDate.timeIntervalSince(Date()) / 60)
            print("🔐 [JWT] Token valid for \(remainingMinutes) more minutes")
        }
        
        return isExpired
    }
    
    // MARK: - JWT Payload Decoding
    private static func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else {
            print("🔐 [JWT] Invalid token format - expected 3 parts, got \(parts.count)")
            return nil
        }
        
        let payloadPart = String(parts[1])
        
        // Add padding if needed for base64 decoding
        let paddedPayload = addBase64Padding(payloadPart)
        
        guard let data = Data(base64Encoded: paddedPayload) else {
            print("🔐 [JWT] Could not base64 decode payload")
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            print("🔐 [JWT] Could not parse JSON payload: \(error)")
            return nil
        }
    }
    
    // MARK: - Base64 Padding Helper
    private static func addBase64Padding(_ string: String) -> String {
        let remainder = string.count % 4
        if remainder > 0 {
            return string + String(repeating: "=", count: 4 - remainder)
        }
        return string
    }
    
    // MARK: - Token Info (Debug)
    static func getTokenInfo(_ token: String) -> [String: Any]? {
        return decodeJWTPayload(token)
    }
}