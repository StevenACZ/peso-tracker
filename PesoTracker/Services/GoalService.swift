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
            // Normalize the date and create a simple date string to avoid timezone issues
            let normalizedDate = DateNormalizer.shared.normalizeForWeightEntry(targetDate)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: normalizedDate)
            let dateString = String(format: "%04d-%02d-%02d", 
                                   components.year ?? 2024, 
                                   components.month ?? 1, 
                                   components.day ?? 1)
            
            print("🎯 [GOAL SERVICE] Creating goal with date:")
            print("   Original: \(DateNormalizer.shared.debugDescription(for: targetDate))")
            print("   Normalized: \(DateNormalizer.shared.debugDescription(for: normalizedDate))")
            print("   API String: \(dateString)")
            
            // Create a simple request matching the API format
            let request = SimpleGoalRequest(
                targetWeight: targetWeight,
                targetDate: dateString
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
            self.error = "Error al crear la meta: \(ErrorMessageParser.cleanMessage(from: error))"
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
            // Normalize the date and create a simple date string to avoid timezone issues
            let normalizedDate = DateNormalizer.shared.normalizeForWeightEntry(targetDate)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: normalizedDate)
            let dateString = String(format: "%04d-%02d-%02d", 
                                   components.year ?? 2024, 
                                   components.month ?? 1, 
                                   components.day ?? 1)
            
            print("🎯 [GOAL SERVICE] Updating goal with date:")
            print("   Original: \(DateNormalizer.shared.debugDescription(for: targetDate))")
            print("   Normalized: \(DateNormalizer.shared.debugDescription(for: normalizedDate))")
            print("   API String: \(dateString)")
            
            // Create a simple request matching the API format
            let request = SimpleGoalRequest(
                targetWeight: targetWeight,
                targetDate: dateString
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
            self.error = "Error al actualizar la meta: \(ErrorMessageParser.cleanMessage(from: error))"
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