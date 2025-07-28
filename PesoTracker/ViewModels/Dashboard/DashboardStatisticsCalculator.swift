import Foundation

class DashboardStatisticsCalculator {
    
    // MARK: - Weight Statistics
    
    func getCurrentWeight(from allWeights: [Weight]) -> Weight? {
        return allWeights.first
    }
    
    func getWeightChange(from allWeights: [Weight]) -> Double? {
        guard allWeights.count >= 2,
              let currentWeight = allWeights.first?.weight,
              let firstWeight = allWeights.last?.weight else {
            return nil
        }
        
        return currentWeight - firstWeight
    }
    
    func getWeightsForChart(from allWeights: [Weight], timeRange: String) -> [Weight] {
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
    
    // MARK: - Goal Statistics
    
    func getMainGoal(from goals: [Goal]) -> Goal? {
        return goals.first { !$0.isCompleted }
    }
    
    func getProgressPercentage(allWeights: [Weight], goals: [Goal]) -> Double {
        guard let goal = getMainGoal(from: goals),
              let currentWeight = getCurrentWeight(from: allWeights)?.weight,
              let startWeight = allWeights.last?.weight else {
            return 0.0
        }
        
        let totalChange = abs(startWeight - goal.targetWeight)
        let currentChange = abs(startWeight - currentWeight)
        
        guard totalChange > 0 else { return 100.0 }
        
        return min((currentChange / totalChange) * 100, 100)
    }
    
    func getDaysToGoal(from goals: [Goal]) -> Int? {
        guard let goal = getMainGoal(from: goals),
              !goal.isCompleted else {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: goal.targetDate)
        return components.day
    }
    
    // MARK: - General Statistics
    
    func getTotalWeightRecords(from allWeights: [Weight]) -> Int {
        return allWeights.count
    }
    
    func calculateTrackingDays(from allWeights: [Weight]) -> Int {
        guard let firstRecord = allWeights.last,
              let lastRecord = allWeights.first else { 
            return 0 
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstRecord.date, to: lastRecord.date)
        return max(components.day ?? 0, 1)
    }
    
    func calculateAverageWeeklyChange(from allWeights: [Weight]) -> Double? {
        let trackingDays = calculateTrackingDays(from: allWeights)
        
        guard trackingDays > 7,
              let weightChange = getWeightChange(from: allWeights) else { 
            return nil 
        }
        
        let weeks = Double(trackingDays) / 7.0
        return weightChange / weeks
    }
    
    // MARK: - Goal Count Statistics
    
    func getTotalGoals(from goals: [Goal]) -> Int {
        return goals.count
    }
    
    func getCompletedGoals(from goals: [Goal]) -> Int {
        return goals.filter { $0.isCompleted }.count
    }
    
    func getActiveGoals(from goals: [Goal]) -> Int {
        return goals.filter { !$0.isCompleted && !$0.isOverdue }.count
    }
    
    // MARK: - Photo Statistics
    
    func getTotalPhotos(from photos: [Photo]) -> Int {
        return photos.count
    }
    
    func getRecentPhotos(from photos: [Photo], limit: Int = 5) -> [Photo] {
        return Array(photos.prefix(limit))
    }
    
    // MARK: - Recent Data
    
    func getRecentWeights(from allWeights: [Weight], limit: Int = 5) -> [Weight] {
        // Sort all weights by date (oldest to newest) for table display
        let sortedWeights = allWeights.sorted { $0.date < $1.date }
        return Array(sortedWeights.prefix(limit))
    }
}