import Foundation

// MARK: - Goal Data Provider
class GoalDataProvider {
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // MARK: - API Operations
    
    // MARK: - Load Goals
    func loadGoals() async throws -> [Goal] {
        print("🎯 [GOAL DATA PROVIDER] Loading goals from API...")
        
        let endpoint = Constants.API.Endpoints.goals
        print("🔗 [DEBUG] Calling goals endpoint: \(endpoint)")
        
        let fetchedGoals = try await apiService.get(
            endpoint: endpoint,
            responseType: [Goal].self
        )
        
        print("✅ [DEBUG] Goals loaded: \(fetchedGoals.count) records")
        return fetchedGoals
    }
    
    // MARK: - Create Goal
    func createGoal(targetWeight: Double, targetDate: Date, type: String = "main") async throws -> Goal {
        print("🎯 [GOAL DATA PROVIDER] Creating new goal...")
        
        let dateFormatter = ISO8601DateFormatter()
        
        struct GoalRequest: Codable {
            let targetWeight: Double
            let targetDate: String
            let type: String
        }
        
        let goalData = GoalRequest(
            targetWeight: targetWeight,
            targetDate: dateFormatter.string(from: targetDate),
            type: type
        )
        
        let createdGoal = try await apiService.post(
            endpoint: Constants.API.Endpoints.goals,
            body: goalData,
            responseType: Goal.self
        )
        
        print("✅ [GOAL DATA PROVIDER] Goal created successfully")
        return createdGoal
    }
    
    // MARK: - Update Goal
    func updateGoal(id: String, targetWeight: Double, targetDate: Date, type: String = "main") async throws -> Goal {
        print("🎯 [GOAL DATA PROVIDER] Updating goal...")
        
        let dateFormatter = ISO8601DateFormatter()
        
        struct GoalRequest: Codable {
            let targetWeight: Double
            let targetDate: String
            let type: String
        }
        
        let goalData = GoalRequest(
            targetWeight: targetWeight,
            targetDate: dateFormatter.string(from: targetDate),
            type: type
        )
        
        let updatedGoal = try await apiService.patch(
            endpoint: "\(Constants.API.Endpoints.goals)/\(id)",
            body: goalData,
            responseType: Goal.self
        )
        
        print("✅ [GOAL DATA PROVIDER] Goal updated successfully")
        return updatedGoal
    }
    
    // MARK: - Delete Goal
    func deleteGoal(id: String) async throws {
        print("🎯 [GOAL DATA PROVIDER] Deleting goal...")
        
        _ = try await apiService.delete(
            endpoint: "\(Constants.API.Endpoints.goals)/\(id)",
            responseType: SuccessResponse.self
        )
        
        print("✅ [GOAL DATA PROVIDER] Goal deleted successfully")
    }
}