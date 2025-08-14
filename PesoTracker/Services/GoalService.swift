import Foundation
import Combine

// Simple request models for API calls
struct SimpleGoalRequest: Codable {
    let targetWeight: Double
    let targetDate: String
}

// MARK: - Goal Service
class GoalService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = GoalService()
    
    // MARK: - Services
    private let apiService = APIService.shared
    
    // Published properties
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Initialization
    private init() {
    }
    
    // MARK: - Create Goal
    @MainActor
    func createGoal(targetWeight: Double, targetDate: Date) async throws -> Goal {
        isLoading = true
        error = nil
        
        do {
            // Create a simple request matching the API format
            let request = SimpleGoalRequest(
                targetWeight: targetWeight,
                targetDate: DateFormatterFactory.shared.apiDateFormatter().string(from: targetDate)
            )
            
            let goal = try await apiService.post(
                endpoint: "/goals",
                body: request,
                responseType: Goal.self
            )
            
            print("✅ [GOAL SERVICE] Goal created successfully: \(goal.id)")
            isLoading = false
            return goal
            
        } catch {
            self.error = "Error al crear la meta: \(error.localizedDescription)"
            isLoading = false
            print("❌ [GOAL SERVICE] Error creating goal: \(error)")
            throw error
        }
    }
    
    // MARK: - Update Goal
    @MainActor
    func updateGoal(goalId: Int, targetWeight: Double, targetDate: Date) async throws -> Goal {
        isLoading = true
        error = nil
        
        do {
            // Create a simple request matching the API format
            let request = SimpleGoalRequest(
                targetWeight: targetWeight,
                targetDate: DateFormatterFactory.shared.apiDateFormatter().string(from: targetDate)
            )
            
            let goal = try await apiService.patch(
                endpoint: "/goals/\(goalId)",
                body: request,
                responseType: Goal.self
            )
            
            print("✅ [GOAL SERVICE] Goal updated successfully: \(goal.id)")
            isLoading = false
            return goal
            
        } catch {
            self.error = "Error al actualizar la meta: \(error.localizedDescription)"
            isLoading = false
            print("❌ [GOAL SERVICE] Error updating goal: \(error)")
            throw error
        }
    }
    
    // MARK: - Get Goal
    @MainActor
    func getGoal(goalId: Int) async throws -> Goal {
        do {
            let goal = try await apiService.get(
                endpoint: "/goals/\(goalId)",
                responseType: Goal.self
            )
            
            print("✅ [GOAL SERVICE] Goal fetched successfully: \(goal.id)")
            return goal
            
        } catch {
            print("❌ [GOAL SERVICE] Error fetching goal: \(error)")
            throw error
        }
    }
    
    // MARK: - Clear Error
    func clearError() {
        error = nil
    }
}