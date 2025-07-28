import Foundation

class WeightDataProvider {
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // MARK: - Data Loading
    func loadPaginatedWeights(page: Int = 1, limit: Int = 5) async throws -> (weights: [Weight], pagination: PaginationInfo) {
        print("⚖️ [DATA PROVIDER] Loading paginated weights...")
        
        let endpoint = "\(Constants.API.Endpoints.weights)?page=\(page)&limit=\(limit)"
        
        // Check authentication
        guard AuthService.shared.isTokenValid() else {
            throw APIError.authenticationFailed
        }
        
        let response = try await apiService.get(
            endpoint: endpoint,
            responseType: PaginatedResponse<Weight>.self
        )
        
        // Sort weights by date (oldest to newest) for table display
        let sortedWeights = response.data.sorted { $0.date < $1.date }
        
        return (weights: sortedWeights, pagination: response.pagination)
    }
    
    func loadAllWeights() async throws -> [Weight] {
        print("⚖️ [DATA PROVIDER] Loading all weights for charts and statistics...")
        
        let endpoint = "\(Constants.API.Endpoints.weights)?page=1&limit=1000"
        
        // Check authentication
        guard AuthService.shared.isTokenValid() else {
            throw APIError.authenticationFailed
        }
        
        let response = try await apiService.get(
            endpoint: endpoint,
            responseType: PaginatedResponse<Weight>.self
        )
        
        // Sort all weights by date (oldest to newest) for consistent ordering
        return response.data.sorted { $0.date < $1.date }
    }
    
    // MARK: - CRUD Operations
    func createWeight(weight: Double, date: Date, notes: String? = nil) async throws -> Weight {
        print("⚖️ [DATA PROVIDER] Creating new weight record...")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        struct WeightRequest: Codable {
            let weight: Double
            let date: String
            let notes: String
        }
        
        let weightData = WeightRequest(
            weight: weight,
            date: dateFormatter.string(from: date),
            notes: notes ?? ""
        )
        
        let result = try await apiService.post(
            endpoint: Constants.API.Endpoints.weights,
            body: weightData,
            responseType: Weight.self
        )
        
        print("✅ [DATA PROVIDER] Weight created successfully")
        return result
    }
    
    func updateWeight(id: String, weight: Double, date: Date, notes: String? = nil) async throws -> Weight {
        print("⚖️ [DATA PROVIDER] Updating weight record...")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        struct WeightRequest: Codable {
            let weight: Double
            let date: String
            let notes: String
        }
        
        let weightData = WeightRequest(
            weight: weight,
            date: dateFormatter.string(from: date),
            notes: notes ?? ""
        )
        
        let result = try await apiService.patch(
            endpoint: "\(Constants.API.Endpoints.weights)/\(id)",
            body: weightData,
            responseType: Weight.self
        )
        
        print("✅ [DATA PROVIDER] Weight updated successfully")
        return result
    }
    
    func deleteWeight(id: String) async throws {
        print("⚖️ [DATA PROVIDER] Deleting weight record...")
        
        _ = try await apiService.delete(
            endpoint: "\(Constants.API.Endpoints.weights)/\(id)",
            responseType: SuccessResponse.self
        )
        
        print("✅ [DATA PROVIDER] Weight deleted successfully")
    }
}