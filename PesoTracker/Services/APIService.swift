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
    
    // MARK: - Weight Management
    
    func getWeights(limit: Int? = nil, offset: Int? = nil, startDate: String? = nil, endDate: String? = nil) async throws -> WeightResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/api/weights")!
        var queryItems: [URLQueryItem] = []
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        if let startDate = startDate {
            queryItems.append(URLQueryItem(name: "startDate", value: startDate))
        }
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "endDate", value: endDate))
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        print("⚖️ APIService: Getting weights from \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        do {
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
                let weightResponse = try JSONDecoder().decode(WeightResponse.self, from: data)
                print("✅ APIService: Get weights successful")
                return weightResponse
            } else {
                print("❌ APIService: Get weights failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to get weights"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func addWeight(_ request: AddWeightRequest) async throws -> AddWeightResponse {
        let url = URL(string: "\(baseURL)/api/weights")!
        
        print("⚖️ APIService: Making add weight request to \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                let addWeightResponse = try JSONDecoder().decode(AddWeightResponse.self, from: data)
                print("✅ APIService: Add weight successful")
                return addWeightResponse
            } else {
                print("❌ APIService: Add weight failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to add weight"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func updateWeight(id: Int, request: AddWeightRequest) async throws -> AddWeightResponse {
        let url = URL(string: "\(baseURL)/api/weights/\(id)")!
        
        print("⚖️ APIService: Making update weight request to \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                let updateWeightResponse = try JSONDecoder().decode(AddWeightResponse.self, from: data)
                print("✅ APIService: Update weight successful")
                return updateWeightResponse
            } else {
                print("❌ APIService: Update weight failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to update weight"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func deleteWeight(id: Int) async throws {
        let url = URL(string: "\(baseURL)/api/weights/\(id)")!
        
        print("⚖️ APIService: Making delete weight request to \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        do {
            let (_, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ APIService: Invalid response type")
                throw NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("📊 APIService: Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 204 {
                print("✅ APIService: Delete weight successful")
            } else {
                print("❌ APIService: Delete weight failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete weight"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    // MARK: - Goals Management
    
    func getGoals() async throws -> GoalResponse {
        let url = URL(string: "\(baseURL)/api/goals")!
        
        print("🎯 APIService: Getting goals from \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        do {
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
                let goalResponse = try JSONDecoder().decode(GoalResponse.self, from: data)
                print("✅ APIService: Get goals successful")
                return goalResponse
            } else {
                print("❌ APIService: Get goals failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to get goals"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func createGoal(_ request: CreateGoalRequest) async throws -> CreateGoalResponse {
        let url = URL(string: "\(baseURL)/api/goals")!
        
        print("🎯 APIService: Making create goal request to \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                let createGoalResponse = try JSONDecoder().decode(CreateGoalResponse.self, from: data)
                print("✅ APIService: Create goal successful")
                return createGoalResponse
            } else {
                print("❌ APIService: Create goal failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to create goal"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func updateGoal(id: Int, request: CreateGoalRequest) async throws -> CreateGoalResponse {
        let url = URL(string: "\(baseURL)/api/goals/\(id)")!
        
        print("🎯 APIService: Making update goal request to \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                let updateGoalResponse = try JSONDecoder().decode(CreateGoalResponse.self, from: data)
                print("✅ APIService: Update goal successful")
                return updateGoalResponse
            } else {
                print("❌ APIService: Update goal failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to update goal"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
    
    func deleteGoal(id: Int) async throws {
        let url = URL(string: "\(baseURL)/api/goals/\(id)")!
        
        print("🎯 APIService: Making delete goal request to \(url.absoluteString)")
        
        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        
        do {
            let (_, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ APIService: Invalid response type")
                throw NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("📊 APIService: Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 204 {
                print("✅ APIService: Delete goal successful")
            } else {
                print("❌ APIService: Delete goal failed with status \(httpResponse.statusCode)")
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete goal"])
            }
            
        } catch {
            print("❌ APIService: Network error: \(error.localizedDescription)")
            throw NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network connection error. Please check your internet connection and try again."])
        }
    }
}