//
//  ProgressPredictor.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 19/07/25.
//

import Foundation
import SwiftUI

// MARK: - Progress Insights
enum ProgressInsight {
    case aheadOfSchedule(days: Int)
    case onTrack
    case behindSchedule(days: Int)
    case needsMoreData
    
    var displayText: String {
        switch self {
        case .aheadOfSchedule(let days):
            return "\(days) días adelantado"
        case .onTrack:
            return "En el tiempo perfecto"
        case .behindSchedule(let days):
            return "\(days) días atrasado"
        case .needsMoreData:
            return "Necesitamos más datos"
        }
    }
    
    var color: Color {
        switch self {
        case .aheadOfSchedule:
            return .green
        case .onTrack:
            return .blue
        case .behindSchedule:
            return .orange
        case .needsMoreData:
            return .secondary
        }
    }
    
    var emoji: String {
        switch self {
        case .aheadOfSchedule:
            return "🚀"
        case .onTrack:
            return "🎯"
        case .behindSchedule:
            return "⏰"
        case .needsMoreData:
            return "📊"
        }
    }
}

// MARK: - Progress Prediction Data
struct ProgressPrediction {
    let averageWeightLossPerWeek: Double
    let predictedCompletionDate: Date?
    let insight: ProgressInsight
    let daysToGoal: Int?
    let confidenceLevel: Double // 0.0 to 1.0
    
    var formattedAverageWeightLoss: String {
        if averageWeightLossPerWeek > 0 {
            return "+\(String(format: "%.2f", averageWeightLossPerWeek)) kg/semana"
        } else {
            return "\(String(format: "%.2f", averageWeightLossPerWeek)) kg/semana"
        }
    }
    
    var formattedPredictedDate: String? {
        guard let date = predictedCompletionDate else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd 'de' MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Progress Predictor Service
class ProgressPredictor {
    
    // MARK: - Main Prediction Method
    func generatePrediction(
        currentWeight: Double,
        targetWeight: Double,
        targetDate: Date,
        weightEntries: [WeightEntry]
    ) -> ProgressPrediction {
        
        // Calculate average weight loss rate
        let averageLoss = calculateAverageWeightLoss(from: weightEntries, timeframe: 30.toTimeInterval)
        
        // Predict completion date
        let predictedDate = predictGoalCompletionDate(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            averageLossRate: averageLoss
        )
        
        // Generate insight
        let insight = getProgressInsight(
            prediction: predictedDate,
            targetDate: targetDate,
            dataPoints: weightEntries.count
        )
        
        // Calculate days to goal
        let daysToGoal = predictedDate != nil ? Int(predictedDate!.timeIntervalSinceNow.toDays) : nil
        
        // Calculate confidence level
        let confidence = calculateConfidenceLevel(
            dataPoints: weightEntries.count,
            timeSpan: getTimeSpanInDays(weightEntries)
        )
        
        return ProgressPrediction(
            averageWeightLossPerWeek: averageLoss,
            predictedCompletionDate: predictedDate,
            insight: insight,
            daysToGoal: daysToGoal,
            confidenceLevel: confidence
        )
    }
    
    // MARK: - Average Weight Loss Calculation
    func calculateAverageWeightLoss(
        from weights: [WeightEntry],
        timeframe: TimeInterval = 30.toTimeInterval
    ) -> Double {
        
        // Need at least 2 entries
        guard weights.count >= 2 else { return 0.0 }
        
        // Sort by date (oldest first)
        let sortedWeights = weights.sorted { first, second in
            return first.date < second.date
        }
        
        // Filter to recent entries within timeframe
        let cutoffDate = Date().addingTimeInterval(-timeframe)
        let recentWeights = sortedWeights.filter { entry in
            if let entryDate = parseDate(entry.date) {
                return entryDate >= cutoffDate
            }
            return false
        }
        
        // Need at least 2 recent entries
        guard recentWeights.count >= 2 else {
            // Fallback to all available data
            return calculateOverallAverageWeightLoss(sortedWeights)
        }
        
        // Calculate weight change over time period
        let firstEntry = recentWeights.first!
        let lastEntry = recentWeights.last!
        
        guard let firstDate = parseDate(firstEntry.date),
              let lastDate = parseDate(lastEntry.date) else {
            return 0.0
        }
        
        let weightChange = lastEntry.weight - firstEntry.weight
        let timeSpanInDays = lastDate.timeIntervalSince(firstDate) / (24 * 60 * 60)
        
        // Convert to weekly rate
        guard timeSpanInDays > 0 else { return 0.0 }
        
        let dailyRate = weightChange / timeSpanInDays
        let weeklyRate = dailyRate * 7.0
        
        return weeklyRate
    }
    
    // MARK: - Goal Completion Date Prediction
    func predictGoalCompletionDate(
        currentWeight: Double,
        targetWeight: Double,
        averageLossRate: Double
    ) -> Date? {
        
        // Check if we need to lose or gain weight
        let weightToLose = currentWeight - targetWeight
        
        // If already at goal or past it
        if abs(weightToLose) <= 0.1 {
            return Date() // Already achieved
        }
        
        // If no progress or going in wrong direction
        if averageLossRate <= 0 && weightToLose > 0 {
            return nil // Can't predict with current trend
        }
        
        if averageLossRate >= 0 && weightToLose < 0 {
            return nil // Can't predict with current trend
        }
        
        // Calculate weeks needed
        let weeksNeeded = abs(weightToLose) / abs(averageLossRate)
        
        // Convert to days and add to current date
        let daysNeeded = weeksNeeded * 7.0
        let predictedDate = Date().addingTimeInterval(daysNeeded * 24 * 60 * 60)
        
        return predictedDate
    }
    
    // MARK: - Progress Insight Generation
    func getProgressInsight(
        prediction: Date?,
        targetDate: Date,
        dataPoints: Int
    ) -> ProgressInsight {
        
        // Not enough data
        if dataPoints < 3 {
            return .needsMoreData
        }
        
        // No prediction possible
        guard let predictedDate = prediction else {
            return .needsMoreData
        }
        
        // Calculate difference in days
        let daysDifference = Int(targetDate.timeIntervalSince(predictedDate) / (24 * 60 * 60))
        
        // Determine insight
        if abs(daysDifference) <= 3 {
            return .onTrack
        } else if daysDifference > 3 {
            return .aheadOfSchedule(days: daysDifference)
        } else {
            return .behindSchedule(days: abs(daysDifference))
        }
    }
    
    // MARK: - Helper Methods
    private func calculateOverallAverageWeightLoss(_ weights: [WeightEntry]) -> Double {
        guard weights.count >= 2 else { return 0.0 }
        
        let firstEntry = weights.first!
        let lastEntry = weights.last!
        
        guard let firstDate = parseDate(firstEntry.date),
              let lastDate = parseDate(lastEntry.date) else {
            return 0.0
        }
        
        let weightChange = lastEntry.weight - firstEntry.weight
        let timeSpanInDays = lastDate.timeIntervalSince(firstDate) / (24 * 60 * 60)
        
        guard timeSpanInDays > 0 else { return 0.0 }
        
        let dailyRate = weightChange / timeSpanInDays
        return dailyRate * 7.0 // Convert to weekly
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    private func getTimeSpanInDays(_ weights: [WeightEntry]) -> Double {
        guard weights.count >= 2 else { return 0.0 }
        
        let sortedWeights = weights.sorted { $0.date < $1.date }
        
        guard let firstDate = parseDate(sortedWeights.first!.date),
              let lastDate = parseDate(sortedWeights.last!.date) else {
            return 0.0
        }
        
        return lastDate.timeIntervalSince(firstDate) / (24 * 60 * 60)
    }
    
    private func calculateConfidenceLevel(dataPoints: Int, timeSpan: Double) -> Double {
        // Base confidence on number of data points and time span
        let dataPointScore = min(Double(dataPoints) / 10.0, 1.0) // Max at 10 points
        let timeSpanScore = min(timeSpan / 30.0, 1.0) // Max at 30 days
        
        return (dataPointScore + timeSpanScore) / 2.0
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    var toDays: Double {
        return self / (24 * 60 * 60)
    }
}

extension Double {
    var toTimeInterval: TimeInterval {
        return self * 24 * 60 * 60
    }
}