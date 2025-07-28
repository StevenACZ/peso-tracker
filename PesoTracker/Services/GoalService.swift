import Foundation

class GoalService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = GoalService()
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // Published properties
    @Published var isLoading = false
    @Published var goals: [Goal] = []
    @Published var error: String?
    
    // MARK: - Initialization
    private init() {
        print("🎯 [GOAL SERVICE] Initializing goal service")
    }
    
    // MARK: - Load Goals
    @MainActor
    func loadGoals() async {
        isLoading = true
        error = nil
        
        do {
            print("🎯 [GOAL SERVICE] Loading goals from API...")
            
            let endpoint = Constants.API.Endpoints.goals
            print("🔗 [DEBUG] Calling goals endpoint: \(endpoint)")
            
            let fetchedGoals = try await apiService.get(
                endpoint: endpoint,
                responseType: [Goal].self
            )
            
            print("✅ [DEBUG] Goals loaded: \(fetchedGoals.count) records")
            goals = fetchedGoals
            
        } catch {
            print("❌ [DEBUG] Error loading goals: \(error)")
            self.error = "Error al cargar metas: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Create Goal
    @MainActor
    func createGoal(targetWeight: Double, targetDate: Date, type: String = "main") async -> Bool {
        do {
            print("🎯 [GOAL SERVICE] Creating new goal...")
            
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
            
            let _ = try await apiService.post(
                endpoint: Constants.API.Endpoints.goals,
                body: goalData,
                responseType: Goal.self
            )
            
            print("✅ [GOAL SERVICE] Goal created successfully")
            
            // Reload goals after creation
            await loadGoals()
            
            return true
            
        } catch {
            print("❌ [GOAL SERVICE] Error creating goal: \(error)")
            self.error = "Error al crear meta: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Update Goal
    @MainActor
    func updateGoal(id: String, targetWeight: Double, targetDate: Date, type: String = "main") async -> Bool {
        do {
            print("🎯 [GOAL SERVICE] Updating goal...")
            
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
            
            let _ = try await apiService.patch(
                endpoint: "\(Constants.API.Endpoints.goals)/\(id)",
                body: goalData,
                responseType: Goal.self
            )
            
            print("✅ [GOAL SERVICE] Goal updated successfully")
            
            // Reload goals after update
            await loadGoals()
            
            return true
            
        } catch {
            print("❌ [GOAL SERVICE] Error updating goal: \(error)")
            self.error = "Error al actualizar meta: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Delete Goal
    @MainActor
    func deleteGoal(id: String) async -> Bool {
        do {
            print("🎯 [GOAL SERVICE] Deleting goal...")
            
            let _ = try await apiService.delete(
                endpoint: "\(Constants.API.Endpoints.goals)/\(id)",
                responseType: SuccessResponse.self
            )
            
            print("✅ [GOAL SERVICE] Goal deleted successfully")
            
            // Reload goals after deletion
            await loadGoals()
            
            return true
            
        } catch {
            print("❌ [GOAL SERVICE] Error deleting goal: \(error)")
            self.error = "Error al eliminar meta: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper Methods
    func getMainGoal() -> Goal? {
        return goals.first { $0.type == .main }
    }
    
    func getActiveGoals() -> [Goal] {
        return goals.filter { !$0.isCompleted && !$0.isOverdue }
    }
    
    func getCompletedGoals() -> [Goal] {
        return goals.filter { $0.isCompleted }
    }
    
    func getOverdueGoals() -> [Goal] {
        return goals.filter { $0.isOverdue && !$0.isCompleted }
    }
    
    // MARK: - Progress Calculation
    func getProgressPercentage(currentWeight: Double, startWeight: Double) -> Double {
        guard let goal = getMainGoal() else { return 0.0 }
        
        return goal.progressPercentage(
            currentWeight: currentWeight,
            startWeight: startWeight
        )
    }
    
    func getDaysToGoal() -> Int? {
        guard let goal = getMainGoal() else { return nil }
        return goal.daysRemaining
    }
    
    func getGoalProgress(currentWeight: Double, startWeight: Double) -> String {
        guard let goal = getMainGoal() else { return "No disponible" }
        
        let totalChange = abs(startWeight - goal.targetWeight)
        let currentChange = abs(startWeight - currentWeight)
        let remaining = totalChange - currentChange
        
        return String(format: "%.1f kg restantes", remaining)
    }
    
    // MARK: - Statistics
    var totalGoals: Int {
        return goals.count
    }
    
    var completedGoals: Int {
        return goals.filter { $0.isCompleted }.count
    }
    
    var activeGoals: Int {
        return goals.filter { !$0.isCompleted && !$0.isOverdue }.count
    }
    
    var overdueGoals: Int {
        return goals.filter { $0.isOverdue && !$0.isCompleted }.count
    }
    
    // MARK: - Clear Data
    func clearData() {
        goals = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers
extension GoalService {
    
    var hasGoalData: Bool {
        return !goals.isEmpty
    }
    
    var hasActiveGoal: Bool {
        return getMainGoal() != nil && !(getMainGoal()?.isCompleted ?? true)
    }
    
    var formattedGoalWeight: String {
        guard let goal = getMainGoal() else { return "-- kg" }
        return String(format: "%.1f kg", goal.targetWeight)
    }
    
    var formattedDaysToGoal: String {
        guard let days = getDaysToGoal() else { return "-- días" }
        
        if days < 0 {
            return "Vencida"
        } else if days == 0 {
            return "Hoy"
        } else {
            return "\(days) días"
        }
    }
    
    var goalStatus: String {
        guard let goal = getMainGoal() else { return "Sin meta activa" }
        
        if goal.isCompleted {
            return "Meta completada"
        } else if goal.isOverdue {
            return "Meta vencida"
        } else {
            return "Meta activa"
        }
    }
    
    var formattedProgressPercentage: String {
        // This requires weight data, so it should be calculated externally
        return "0%"
    }
}