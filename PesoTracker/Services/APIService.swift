//
//  APIService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "http://100.111.122.121:3000"
    
    func login(_ request: LoginRequest) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/api/auth/login")!
        
        print("🌐 APIService: Making login request to \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a custom URLSession configuration for development
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 APIService: Request body: \(jsonString)")
            }
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ APIService: Invalid response type")
                throw NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("📊 APIService: Response status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 APIService: Response body: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("✅ APIService: Login successful")
                return authResponse
            } else {
                print("❌ APIService: Login failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/api/auth/register")!
        
        print("🌐 APIService: Making register request to \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a custom URLSession configuration for development
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 APIService: Request body: \(jsonString)")
            }
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ APIService: Invalid response type")
                throw NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("📊 APIService: Response status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 APIService: Response body: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("✅ APIService: Register successful")
                return authResponse
            } else {
                print("❌ APIService: Register failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
}