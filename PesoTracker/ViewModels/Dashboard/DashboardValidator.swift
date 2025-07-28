import Foundation

class DashboardValidator {
    
    // MARK: - Data Existence Validation
    
    func hasWeightData(allWeights: [Weight]) -> Bool {
        return !allWeights.isEmpty
    }
    
    func hasGoalData(goals: [Goal]) -> Bool {
        return !goals.isEmpty
    }
    
    func hasPhotoData(photos: [Photo]) -> Bool {
        return !photos.isEmpty
    }
    
    func hasData(allWeights: [Weight], goals: [Goal]) -> Bool {
        return hasWeightData(allWeights: allWeights) || hasGoalData(goals: goals)
    }
    
    // MARK: - Goal Status Validation
    
    func hasActiveGoal(goals: [Goal]) -> Bool {
        return getMainGoal(from: goals) != nil && !(getMainGoal(from: goals)?.isCompleted ?? true)
    }
    
    // MARK: - Chart and Display Validation
    
    func canShowChart(allWeights: [Weight], timeRange: String) -> Bool {
        let weightsForChart = getWeightsForChart(from: allWeights, timeRange: timeRange)
        return weightsForChart.count >= 2
    }
    
    func canShowProgress(allWeights: [Weight], goals: [Goal]) -> Bool {
        return hasData(allWeights: allWeights, goals: goals) && hasActiveGoal(goals: goals)
    }
    
    func canShowPhotos(photos: [Photo]) -> Bool {
        return hasPhotoData(photos: photos)
    }
    
    // MARK: - Pagination Validation
    
    func canGoBack(currentPage: Int) -> Bool {
        return currentPage > 1
    }
    
    func canGoNext(currentPage: Int, totalPages: Int) -> Bool {
        return currentPage < totalPages
    }
    
    // MARK: - Helper Methods
    
    private func getMainGoal(from goals: [Goal]) -> Goal? {
        return goals.first { !$0.isCompleted }
    }
    
    private func getWeightsForChart(from allWeights: [Weight], timeRange: String) -> [Weight] {
        let calendar = Calendar.current
        let now = Date()
        
        let cutoffDate: Date
        switch timeRange {
        case "1 semana":
            cutoffDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case "1 mes":
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case "3 meses":
            cutoffDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case "6 meses":
            cutoffDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "1 año":
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        default:
            return allWeights
        }
        
        return allWeights.filter { $0.date >= cutoffDate }
    }
}