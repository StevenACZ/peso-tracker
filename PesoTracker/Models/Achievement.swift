//
//  Achievement.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation
import SwiftUI

// MARK: - Achievement Category

enum AchievementCategory: String, CaseIterable, Codable {
    case weightLoss = "weight_loss"
    case milestones = "milestones"
    case consistency = "consistency"
    case goals = "goals"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .weightLoss:
            return "Weight Loss"
        case .milestones:
            return "Milestones"
        case .consistency:
            return "Consistency"
        case .goals:
            return "Goals"
        case .special:
            return "Special"
        }
    }
    
    var emoji: String {
        switch self {
        case .weightLoss:
            return "⚖️"
        case .milestones:
            return "🎯"
        case .consistency:
            return "📅"
        case .goals:
            return "🏆"
        case .special:
            return "⭐"
        }
    }
}

// MARK: - Achievement Rarity

enum AchievementRarity: String, CaseIterable, Codable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var displayName: String {
        switch self {
        case .common:
            return "Common"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        }
    }
    
    var color: Color {
        switch self {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .orange
        }
    }
    
    var points: Int {
        switch self {
        case .common:
            return 10
        case .rare:
            return 25
        case .epic:
            return 50
        case .legendary:
            return 100
        }
    }
}

// MARK: - Achievement Criteria

protocol AchievementCriteria {
    func isUnlocked(userStats: UserStats) -> Bool
    func getProgress(userStats: UserStats) -> Double // 0.0 to 1.0
    func getCurrentValue(userStats: UserStats) -> Double
    func getTargetValue() -> Double
}

// MARK: - Specific Achievement Criteria

struct WeightLossCriteria: AchievementCriteria {
    let targetWeightLoss: Double
    
    func isUnlocked(userStats: UserStats) -> Bool {
        return userStats.totalWeightLoss >= targetWeightLoss
    }
    
    func getProgress(userStats: UserStats) -> Double {
        return min(userStats.totalWeightLoss / targetWeightLoss, 1.0)
    }
    
    func getCurrentValue(userStats: UserStats) -> Double {
        return userStats.totalWeightLoss
    }
    
    func getTargetValue() -> Double {
        return targetWeightLoss
    }
}

struct ConsistencyCriteria: AchievementCriteria {
    let targetDays: Int
    
    func isUnlocked(userStats: UserStats) -> Bool {
        return userStats.currentStreak >= targetDays
    }
    
    func getProgress(userStats: UserStats) -> Double {
        return min(Double(userStats.currentStreak) / Double(targetDays), 1.0)
    }
    
    func getCurrentValue(userStats: UserStats) -> Double {
        return Double(userStats.currentStreak)
    }
    
    func getTargetValue() -> Double {
        return Double(targetDays)
    }
}

struct GoalAchievementCriteria: AchievementCriteria {
    let targetGoalsAchieved: Int
    
    func isUnlocked(userStats: UserStats) -> Bool {
        return userStats.goalsAchieved >= targetGoalsAchieved
    }
    
    func getProgress(userStats: UserStats) -> Double {
        return min(Double(userStats.goalsAchieved) / Double(targetGoalsAchieved), 1.0)
    }
    
    func getCurrentValue(userStats: UserStats) -> Double {
        return Double(userStats.goalsAchieved)
    }
    
    func getTargetValue() -> Double {
        return Double(targetGoalsAchieved)
    }
}

struct MilestoneCriteria: AchievementCriteria {
    let targetWeight: Double
    let isBelow: Bool // true for "below X kg", false for "above X kg"
    
    func isUnlocked(userStats: UserStats) -> Bool {
        if isBelow {
            return userStats.currentWeight <= targetWeight
        } else {
            return userStats.currentWeight >= targetWeight
        }
    }
    
    func getProgress(userStats: UserStats) -> Double {
        if isBelow {
            let progress = (userStats.startingWeight - userStats.currentWeight) / (userStats.startingWeight - targetWeight)
            return min(max(progress, 0.0), 1.0)
        } else {
            let progress = (userStats.currentWeight - userStats.startingWeight) / (targetWeight - userStats.startingWeight)
            return min(max(progress, 0.0), 1.0)
        }
    }
    
    func getCurrentValue(userStats: UserStats) -> Double {
        return userStats.currentWeight
    }
    
    func getTargetValue() -> Double {
        return targetWeight
    }
}

struct SpecialCriteria: AchievementCriteria {
    let type: SpecialAchievementType
    
    func isUnlocked(userStats: UserStats) -> Bool {
        switch type {
        case .biggestDrop:
            return userStats.biggestSingleDrop >= 2.0
        case .perfectTiming:
            return userStats.goalsAchievedOnTime > 0
        case .overachiever:
            return userStats.goalsExceededBy2kg > 0
        case .comeback:
            return userStats.goalsAchievedAfterMissing > 0
        }
    }
    
    func getProgress(userStats: UserStats) -> Double {
        switch type {
        case .biggestDrop:
            return min(userStats.biggestSingleDrop / 2.0, 1.0)
        case .perfectTiming:
            return userStats.goalsAchievedOnTime > 0 ? 1.0 : 0.0
        case .overachiever:
            return userStats.goalsExceededBy2kg > 0 ? 1.0 : 0.0
        case .comeback:
            return userStats.goalsAchievedAfterMissing > 0 ? 1.0 : 0.0
        }
    }
    
    func getCurrentValue(userStats: UserStats) -> Double {
        switch type {
        case .biggestDrop:
            return userStats.biggestSingleDrop
        case .perfectTiming:
            return Double(userStats.goalsAchievedOnTime)
        case .overachiever:
            return Double(userStats.goalsExceededBy2kg)
        case .comeback:
            return Double(userStats.goalsAchievedAfterMissing)
        }
    }
    
    func getTargetValue() -> Double {
        switch type {
        case .biggestDrop:
            return 2.0
        case .perfectTiming, .overachiever, .comeback:
            return 1.0
        }
    }
}

enum SpecialAchievementType {
    case biggestDrop
    case perfectTiming
    case overachiever
    case comeback
}

// MARK: - Achievement Definition

struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let icon: String // SF Symbol or emoji
    let points: Int
    
    // Computed properties
    var displayIcon: String {
        return icon.isEmpty ? category.emoji : icon
    }
    
    var rarityColor: Color {
        return rarity.color
    }
    
    // Static method to create criteria (since we can't store protocols in Codable)
    func createCriteria() -> AchievementCriteria? {
        switch category {
        case .weightLoss:
            return createWeightLossCriteria()
        case .consistency:
            return createConsistencyCriteria()
        case .goals:
            return createGoalCriteria()
        case .milestones:
            return createMilestoneCriteria()
        case .special:
            return createSpecialCriteria()
        }
    }
    
    private func createWeightLossCriteria() -> WeightLossCriteria? {
        switch id {
        case "first_step":
            return WeightLossCriteria(targetWeightLoss: 0.5)
        case "getting_serious":
            return WeightLossCriteria(targetWeightLoss: 1.0)
        case "milestone_master":
            return WeightLossCriteria(targetWeightLoss: 5.0)
        case "transformation":
            return WeightLossCriteria(targetWeightLoss: 10.0)
        case "legend":
            return WeightLossCriteria(targetWeightLoss: 20.0)
        case "steady_progress":
            return WeightLossCriteria(targetWeightLoss: 0.1) // Minimal loss to trigger consecutive check
        default:
            return nil
        }
    }
    
    private func createConsistencyCriteria() -> ConsistencyCriteria? {
        switch id {
        case "week_warrior":
            return ConsistencyCriteria(targetDays: 7)
        case "monthly_master":
            return ConsistencyCriteria(targetDays: 30)
        case "dedication":
            return ConsistencyCriteria(targetDays: 100)
        case "habit_former":
            return ConsistencyCriteria(targetDays: 180)
        case "weekend_warrior":
            return ConsistencyCriteria(targetDays: 2) // Weekend days
        case "early_bird":
            return ConsistencyCriteria(targetDays: 7) // 7 early morning logs
        default:
            return nil
        }
    }
    
    private func createGoalCriteria() -> GoalAchievementCriteria? {
        switch id {
        case "goal_getter":
            return GoalAchievementCriteria(targetGoalsAchieved: 1)
        case "multi_tasker":
            return GoalAchievementCriteria(targetGoalsAchieved: 3)
        case "goal_crusher":
            return GoalAchievementCriteria(targetGoalsAchieved: 5)
        default:
            return nil
        }
    }
    
    private func createMilestoneCriteria() -> MilestoneCriteria? {
        switch id {
        case "breaking_80":
            return MilestoneCriteria(targetWeight: 80.0, isBelow: true)
        case "breaking_75":
            return MilestoneCriteria(targetWeight: 75.0, isBelow: true)
        case "breaking_70":
            return MilestoneCriteria(targetWeight: 70.0, isBelow: true)
        case "halfway_hero":
            return MilestoneCriteria(targetWeight: 0.0, isBelow: true) // Special handling needed
        default:
            return nil
        }
    }
    
    private func createSpecialCriteria() -> SpecialCriteria? {
        switch id {
        case "big_drop":
            return SpecialCriteria(type: .biggestDrop)
        case "perfectionist":
            return SpecialCriteria(type: .perfectTiming)
        case "overachiever":
            return SpecialCriteria(type: .overachiever)
        case "comeback_kid":
            return SpecialCriteria(type: .comeback)
        default:
            return nil
        }
    }
}

// MARK: - Achievement Progress

struct AchievementProgress: Codable {
    let achievementId: String
    let isUnlocked: Bool
    let unlockedAt: Date?
    let progress: Double        // 0.0 to 1.0
    let currentValue: Double    // Current progress value
    let targetValue: Double     // Target value to unlock
    
    var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var isCompleted: Bool {
        return progress >= 1.0
    }
}

// MARK: - User Achievements

struct UserAchievements: Codable {
    let totalPoints: Int
    let unlockedCount: Int
    let achievements: [String: AchievementProgress]
    
    var completionPercentage: Double {
        let totalAchievements = AchievementDefinitions.allAchievements.count
        return totalAchievements > 0 ? Double(unlockedCount) / Double(totalAchievements) : 0.0
    }
    
    var completionPercentageInt: Int {
        return Int(completionPercentage * 100)
    }
    
    func getProgress(for achievementId: String) -> AchievementProgress? {
        return achievements[achievementId]
    }
    
    func isUnlocked(_ achievementId: String) -> Bool {
        return achievements[achievementId]?.isUnlocked ?? false
    }
}

// MARK: - User Statistics

struct UserStats {
    let currentWeight: Double
    let startingWeight: Double
    let totalWeightLoss: Double
    let currentStreak: Int
    let longestStreak: Int
    let totalEntries: Int
    let goalsAchieved: Int
    let goalsAchievedOnTime: Int
    let goalsExceededBy2kg: Int
    let goalsAchievedAfterMissing: Int
    let biggestSingleDrop: Double
    let averageWeeklyLoss: Double
    
    init(
        currentWeight: Double,
        startingWeight: Double,
        weightEntries: [WeightEntry],
        goals: [Goal]
    ) {
        self.currentWeight = currentWeight
        self.startingWeight = startingWeight
        self.totalWeightLoss = max(0, startingWeight - currentWeight)
        
        // Calculate streaks and entries
        self.totalEntries = weightEntries.count
        
        // Simplified streak calculation (would need more complex logic in real implementation)
        self.currentStreak = UserStats.calculateCurrentStreak(from: weightEntries)
        self.longestStreak = UserStats.calculateLongestStreak(from: weightEntries)
        
        // Calculate goal statistics
        let achievedGoals = goals.filter { $0.isAchieved(currentWeight: currentWeight) }
        self.goalsAchieved = achievedGoals.count
        
        // Simplified calculations (would need more complex logic in real implementation)
        self.goalsAchievedOnTime = 0 // TODO: Implement based on achievement dates
        self.goalsExceededBy2kg = 0 // TODO: Implement based on goal vs actual weight
        self.goalsAchievedAfterMissing = 0 // TODO: Implement based on missed deadlines
        
        // Calculate biggest single drop
        self.biggestSingleDrop = UserStats.calculateBiggestDrop(from: weightEntries)
        
        // Calculate average weekly loss
        self.averageWeeklyLoss = UserStats.calculateAverageWeeklyLoss(from: weightEntries)
    }
    
    private static func calculateCurrentStreak(from entries: [WeightEntry]) -> Int {
        // Simplified implementation - count consecutive days with entries
        // In real implementation, this would be more sophisticated
        return min(entries.count, 30) // Cap at 30 for demo
    }
    
    private static func calculateLongestStreak(from entries: [WeightEntry]) -> Int {
        // Simplified implementation
        return min(entries.count, 50) // Cap at 50 for demo
    }
    
    private static func calculateBiggestDrop(from entries: [WeightEntry]) -> Double {
        guard entries.count >= 2 else { return 0.0 }
        
        let sortedEntries = entries.sorted { $0.date < $1.date }
        var biggestDrop = 0.0
        
        for i in 1..<sortedEntries.count {
            let drop = sortedEntries[i-1].weight - sortedEntries[i].weight
            if drop > biggestDrop {
                biggestDrop = drop
            }
        }
        
        return biggestDrop
    }
    
    private static func calculateAverageWeeklyLoss(from entries: [WeightEntry]) -> Double {
        guard entries.count >= 2 else { return 0.0 }
        
        let sortedEntries = entries.sorted { $0.date < $1.date }
        let firstWeight = sortedEntries.first!.weight
        let lastWeight = sortedEntries.last!.weight
        let weightLoss = firstWeight - lastWeight
        
        // Simplified calculation - assume entries span multiple weeks
        let estimatedWeeks = max(1, entries.count / 7)
        return weightLoss / Double(estimatedWeeks)
    }
}