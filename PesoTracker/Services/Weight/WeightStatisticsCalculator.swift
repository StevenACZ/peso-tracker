import Foundation

class WeightStatisticsCalculator {
    
    // MARK: - Current Weight Analysis
    func getCurrentWeight(from weights: [Weight]) -> Weight? {
        return weights.first // Assuming weights are sorted newest first
    }
    
    func getWeightChange(from weights: [Weight]) -> Double? {
        guard weights.count >= 2 else { return nil }
        
        let latest = weights.first!.weight
        let oldest = weights.last!.weight
        
        return latest - oldest
    }
    
    // MARK: - Time-based Weight Filtering
    func getWeightsForChart(from weights: [Weight], timeRange: String) -> [Weight] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeRange {
        case "1 semana":
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case "1 mes":
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case "3 meses":
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case "6 meses":
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "1 año":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        default:
            return weights
        }
        
        return weights.filter { $0.date >= startDate }
    }
    
    // MARK: - Statistics Calculations
    func calculateTrackingDays(from weights: [Weight]) -> Int {
        guard let firstRecord = weights.last,
              let lastRecord = weights.first else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstRecord.date, to: lastRecord.date)
        return max(components.day ?? 0, 1)
    }
    
    func calculateAverageWeeklyChange(from weights: [Weight]) -> String {
        let trackingDays = calculateTrackingDays(from: weights)
        
        guard trackingDays > 7,
              let weightChange = getWeightChange(from: weights) else { 
            return "No disponible" 
        }
        
        let weeks = Double(trackingDays) / 7.0
        let weeklyChange = weightChange / weeks
        let sign = weeklyChange >= 0 ? "+" : ""
        
        return "\(sign)\(String(format: "%.2f", weeklyChange)) kg/semana"
    }
    
    // MARK: - Formatted Data for UI
    func formattedCurrentWeight(from weights: [Weight]) -> String {
        guard let weight = getCurrentWeight(from: weights) else { return "-- kg" }
        return String(format: "%.2f kg", weight.weight)
    }
    
    func formattedWeightChange(from weights: [Weight]) -> String {
        guard let change = getWeightChange(from: weights) else { return "-- kg" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change)) kg"
    }
    
    func formattedLastWeightEntry(from weights: [Weight]) -> String {
        guard let lastWeight = weights.first else { return "Sin registros" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Último registro: \(formatter.string(from: lastWeight.date))"
    }
    
    // MARK: - Data Status Checks
    func hasWeightData(weights: [Weight]) -> Bool {
        return !weights.isEmpty
    }
    
    func getTotalWeightRecords(from weights: [Weight]) -> Int {
        return weights.count
    }
}