import Foundation

class GoalService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = GoalService()
    
    // MARK: - Modular Components
    private let dataProvider = GoalDataProvider()
    private let statisticsCalculator = GoalStatisticsCalculator()
    
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
            goals = try await dataProvider.loadGoals()
            
        } catch {
            print("❌ [GOAL SERVICE] Error loading goals: \(error)")
            self.error = "Error al cargar metas: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Create Goal
    @MainActor
    func createGoal(targetWeight: Double, targetDate: Date, type: String = "main") async -> Bool {
        do {
            _ = try await dataProvider.createGoal(
                targetWeight: targetWeight,
                targetDate: targetDate,
                type: type
            )
            
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
            _ = try await dataProvider.updateGoal(
                id: id,
                targetWeight: targetWeight,
                targetDate: targetDate,
                type: type
            )
            
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
            try await dataProvider.deleteGoal(id: id)
            
            // Reload goals after deletion
            await loadGoals()
            
            return true
            
        } catch {
            print("❌ [GOAL SERVICE] Error deleting goal: \(error)")
            self.error = "Error al eliminar meta: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper Methods (Delegated to Statistics Calculator)
    func getMainGoal() -> Goal? {
        return statisticsCalculator.getMainGoal(from: goals)
    }
    
    func getActiveGoals() -> [Goal] {
        return statisticsCalculator.getActiveGoals(from: goals)
    }
    
    func getCompletedGoals() -> [Goal] {
        return statisticsCalculator.getCompletedGoals(from: goals)
    }
    
    func getOverdueGoals() -> [Goal] {
        return statisticsCalculator.getOverdueGoals(from: goals)
    }
    
    // MARK: - Progress Calculation (Delegated to Statistics Calculator)
    func getProgressPercentage(currentWeight: Double, startWeight: Double) -> Double {
        return statisticsCalculator.getProgressPercentage(
            from: goals,
            currentWeight: currentWeight,
            startWeight: startWeight
        )
    }
    
    func getDaysToGoal() -> Int? {
        return statisticsCalculator.getDaysToGoal(from: goals)
    }
    
    func getGoalProgress(currentWeight: Double, startWeight: Double) -> String {
        return statisticsCalculator.getGoalProgress(
            from: goals,
            currentWeight: currentWeight,
            startWeight: startWeight
        )
    }
    
    // MARK: - Statistics (Delegated to Statistics Calculator)
    var totalGoals: Int {
        return statisticsCalculator.getTotalGoals(from: goals)
    }
    
    var completedGoals: Int {
        return statisticsCalculator.getCompletedGoalsCount(from: goals)
    }
    
    var activeGoals: Int {
        return statisticsCalculator.getActiveGoalsCount(from: goals)
    }
    
    var overdueGoals: Int {
        return statisticsCalculator.getOverdueGoalsCount(from: goals)
    }
    
    // MARK: - Clear Data
    func clearData() {
        goals = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers (Delegated to Statistics Calculator)
extension GoalService {
    
    var hasGoalData: Bool {
        return statisticsCalculator.hasGoalData(goals: goals)
    }
    
    var hasActiveGoal: Bool {
        return statisticsCalculator.hasActiveGoal(from: goals)
    }
    
    var formattedGoalWeight: String {
        return statisticsCalculator.getFormattedGoalWeight(from: goals)
    }
    
    var formattedDaysToGoal: String {
        return statisticsCalculator.getFormattedDaysToGoal(from: goals)
    }
    
    var goalStatus: String {
        return statisticsCalculator.getGoalStatus(from: goals)
    }
    
    func formattedProgressPercentage(currentWeight: Double, startWeight: Double) -> String {
        return statisticsCalculator.getFormattedProgressPercentage(
            from: goals,
            currentWeight: currentWeight,
            startWeight: startWeight
        )
    }
}