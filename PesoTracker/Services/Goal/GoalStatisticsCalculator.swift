import Foundation

// MARK: - Goal Statistics Calculator
class GoalStatisticsCalculator {
    
    // MARK: - Goal Filtering Methods
    
    func getMainGoal(from goals: [Goal]) -> Goal? {
        return goals.first { $0.type == .main }
    }
    
    func getActiveGoals(from goals: [Goal]) -> [Goal] {
        return goals.filter { !$0.isCompleted && !$0.isOverdue }
    }
    
    func getCompletedGoals(from goals: [Goal]) -> [Goal] {
        return goals.filter { $0.isCompleted }
    }
    
    func getOverdueGoals(from goals: [Goal]) -> [Goal] {
        return goals.filter { $0.isOverdue && !$0.isCompleted }
    }
    
    // MARK: - Progress Calculations
    
    func getProgressPercentage(from goals: [Goal], currentWeight: Double, startWeight: Double) -> Double {
        guard let goal = getMainGoal(from: goals) else { return 0.0 }
        
        return goal.progressPercentage(
            currentWeight: currentWeight,
            startWeight: startWeight
        )
    }
    
    func getDaysToGoal(from goals: [Goal]) -> Int? {
        guard let goal = getMainGoal(from: goals) else { return nil }
        return goal.daysRemaining
    }
    
    func getGoalProgress(from goals: [Goal], currentWeight: Double, startWeight: Double) -> String {
        guard let goal = getMainGoal(from: goals) else { return "No disponible" }
        
        let totalChange = abs(startWeight - goal.targetWeight)
        let currentChange = abs(startWeight - currentWeight)
        let remaining = totalChange - currentChange
        
        return String(format: "%.2f kg restantes", remaining)
    }
    
    // MARK: - Statistics Calculations
    
    func getTotalGoals(from goals: [Goal]) -> Int {
        return goals.count
    }
    
    func getCompletedGoalsCount(from goals: [Goal]) -> Int {
        return goals.filter { $0.isCompleted }.count
    }
    
    func getActiveGoalsCount(from goals: [Goal]) -> Int {
        return goals.filter { !$0.isCompleted && !$0.isOverdue }.count
    }
    
    func getOverdueGoalsCount(from goals: [Goal]) -> Int {
        return goals.filter { $0.isOverdue && !$0.isCompleted }.count
    }
    
    // MARK: - UI Helper Methods
    
    func hasGoalData(goals: [Goal]) -> Bool {
        return !goals.isEmpty
    }
    
    func hasActiveGoal(from goals: [Goal]) -> Bool {
        return getMainGoal(from: goals) != nil && !(getMainGoal(from: goals)?.isCompleted ?? true)
    }
    
    func getFormattedGoalWeight(from goals: [Goal]) -> String {
        guard let goal = getMainGoal(from: goals) else { return "-- kg" }
        return String(format: "%.2f kg", goal.targetWeight)
    }
    
    func getFormattedDaysToGoal(from goals: [Goal]) -> String {
        guard let days = getDaysToGoal(from: goals) else { return "-- días" }
        
        if days < 0 {
            return "Vencida"
        } else if days == 0 {
            return "Hoy"
        } else {
            return "\(days) días"
        }
    }
    
    func getGoalStatus(from goals: [Goal]) -> String {
        guard let goal = getMainGoal(from: goals) else { return "Sin meta activa" }
        
        if goal.isCompleted {
            return "Meta completada"
        } else if goal.isOverdue {
            return "Meta vencida"
        } else {
            return "Meta activa"
        }
    }
    
    func getFormattedProgressPercentage(from goals: [Goal], currentWeight: Double, startWeight: Double) -> String {
        let percentage = getProgressPercentage(from: goals, currentWeight: currentWeight, startWeight: startWeight)
        return String(format: "%.0f%%", percentage)
    }
}