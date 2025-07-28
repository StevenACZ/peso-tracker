import Foundation

class DashboardDataFormatter {
    
    // MARK: - Weight Formatting
    
    func formattedCurrentWeight(currentUser: User?, allWeights: [Weight]) -> String {
        guard let currentWeight = getCurrentWeight(from: allWeights) else {
            return "Sin datos"
        }
        
        return String(format: "%.2f kg", currentWeight.weight)
    }
    
    func formattedWeightChange(from allWeights: [Weight]) -> String {
        guard let weightChange = getWeightChange(from: allWeights) else {
            return "Sin cambios"
        }
        
        let sign = weightChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", weightChange)) kg"
    }
    
    func formattedGoalWeight(from goals: [Goal]) -> String {
        guard let mainGoal = getMainGoal(from: goals) else {
            return "Sin meta"
        }
        
        return String(format: "%.2f kg", mainGoal.targetWeight)
    }
    
    func formattedProgressPercentage(progressPercentage: Double) -> String {
        return String(format: "%.1f%%", progressPercentage)
    }
    
    func formattedDaysToGoal(daysToGoal: Int?) -> String {
        guard let days = daysToGoal else {
            return "No disponible"
        }
        
        if days < 0 {
            return "Meta vencida"
        } else if days == 0 {
            return "¡Hoy!"
        } else {
            return "\(days) días"
        }
    }
    
    // MARK: - User Formatting
    
    func formattedUserName(from user: User?) -> String {
        return user?.username ?? "Usuario"
    }
    
    func formattedUserEmail(from user: User?) -> String {
        return user?.email ?? ""
    }
    
    // MARK: - Goal Status Formatting
    
    func formattedGoalStatus(from goals: [Goal]) -> String {
        guard let goal = getMainGoal(from: goals) else { 
            return "Sin meta activa" 
        }
        
        if goal.isCompleted {
            return "Meta completada"
        } else if goal.isOverdue {
            return "Meta vencida"
        } else {
            return "Meta activa"
        }
    }
    
    func formattedGoalProgress(allWeights: [Weight], goals: [Goal]) -> String {
        guard let goal = getMainGoal(from: goals),
              let currentWeight = getCurrentWeight(from: allWeights)?.weight,
              let startWeight = allWeights.last?.weight,
              !goal.isCompleted && !goal.isOverdue else {
            return "No disponible"
        }
        
        let totalChange = abs(startWeight - goal.targetWeight)
        let currentChange = abs(startWeight - currentWeight)
        let remaining = totalChange - currentChange
        
        return String(format: "%.2f kg restantes", remaining)
    }
    
    // MARK: - Activity Formatting
    
    func formattedLastWeightEntry(from allWeights: [Weight]) -> String {
        guard let lastWeight = allWeights.first else { 
            return "Sin registros" 
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Último registro: \(formatter.string(from: lastWeight.date))"
    }
    
    func formattedAverageWeeklyChange(trackingDays: Int, weightChange: Double?) -> String {
        guard trackingDays > 7,
              let weightChange = weightChange else { 
            return "No disponible" 
        }
        
        let weeks = Double(trackingDays) / 7.0
        let weeklyChange = weightChange / weeks
        let sign = weeklyChange >= 0 ? "+" : ""
        
        return "\(sign)\(String(format: "%.2f", weeklyChange)) kg/semana"
    }
    
    // MARK: - Pagination Formatting
    
    func formattedPaginationInfo(currentPage: Int, totalPages: Int, totalRecords: Int) -> String {
        return "Página \(currentPage) de \(totalPages) (\(totalRecords) registros)"
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentWeight(from allWeights: [Weight]) -> Weight? {
        return allWeights.first
    }
    
    private func getWeightChange(from allWeights: [Weight]) -> Double? {
        guard allWeights.count >= 2,
              let currentWeight = allWeights.first?.weight,
              let firstWeight = allWeights.last?.weight else {
            return nil
        }
        
        return currentWeight - firstWeight
    }
    
    private func getMainGoal(from goals: [Goal]) -> Goal? {
        return goals.first { !$0.isCompleted }
    }
}