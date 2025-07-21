//
//  AdvancedAchievementFeatures.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Advanced Achievement Features

class AdvancedAchievementFeatures {
    
    // MARK: - Achievement Chains and Dependencies
    
    /// Get achievement chains (achievements that unlock others)
    static func getAchievementChains() -> [AchievementChain] {
        return [
            // Weight Loss Chain
            AchievementChain(
                id: "weight_loss_chain",
                name: "Weight Loss Journey",
                achievements: ["first_step", "getting_serious", "milestone_master", "transformation", "legend"],
                description: "Master the art of weight loss"
            ),
            
            // Consistency Chain
            AchievementChain(
                id: "consistency_chain",
                name: "Consistency Master",
                achievements: ["week_warrior", "monthly_master", "dedication", "habit_former"],
                description: "Build unbreakable habits"
            ),
            
            // Goal Achievement Chain
            AchievementChain(
                id: "goal_chain",
                name: "Goal Crusher",
                achievements: ["goal_getter", "multi_tasker", "goal_crusher", "marathon_runner"],
                description: "Become a goal-achieving machine"
            )
        ]
    }
    
    /// Get next achievement in chain
    static func getNextInChain(
        for achievementId: String,
        userAchievements: UserAchievements
    ) -> Achievement? {
        
        let chains = getAchievementChains()
        
        for chain in chains {
            if let currentIndex = chain.achievements.firstIndex(of: achievementId),
               currentIndex + 1 < chain.achievements.count {
                let nextId = chain.achievements[currentIndex + 1]
                return AchievementDefinitions.getAchievement(by: nextId)
            }
        }
        
        return nil
    }
    
    /// Get achievement dependencies
    static func getAchievementDependencies() -> [String: [String]] {
        return [
            "transformation": ["milestone_master"], // Need 5kg before 10kg
            "legend": ["transformation"], // Need 10kg before 20kg
            "monthly_master": ["week_warrior"], // Need week before month
            "dedication": ["monthly_master"], // Need month before 100 days
            "habit_former": ["dedication"], // Need dedication before 6 months
            "goal_crusher": ["multi_tasker"], // Need 3 goals before 5 goals
            "marathon_runner": ["goal_crusher"] // Need 5 goals before long-term goal
        ]
    }
    
    /// Check if achievement dependencies are met
    static func areDependenciesMet(
        for achievementId: String,
        userAchievements: UserAchievements
    ) -> Bool {
        
        let dependencies = getAchievementDependencies()
        
        guard let requiredAchievements = dependencies[achievementId] else {
            return true // No dependencies
        }
        
        return requiredAchievements.allSatisfy { requiredId in
            userAchievements.isUnlocked(requiredId)
        }
    }
    
    // MARK: - Seasonal and Time-Based Achievements
    
    /// Get seasonal achievements based on current date
    static func getSeasonalAchievements() -> [Achievement] {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        
        var seasonalAchievements: [Achievement] = []
        
        // New Year Achievement (January)
        if month == 1 {
            if let newYearAchievement = AchievementDefinitions.getAchievement(by: "new_year_new_me") {
                seasonalAchievements.append(newYearAchievement)
            }
        }
        
        // Summer Achievement (June-August)
        if month >= 6 && month <= 8 {
            if let summerAchievement = AchievementDefinitions.getAchievement(by: "summer_ready") {
                seasonalAchievements.append(summerAchievement)
            }
        }
        
        return seasonalAchievements
    }
    
    /// Check if seasonal achievement criteria are met
    static func checkSeasonalCriteria(
        achievementId: String,
        userStats: UserStats
    ) -> Bool {
        
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        
        switch achievementId {
        case "new_year_new_me":
            return month == 1 && userStats.totalEntries >= 1
            
        case "summer_ready":
            return (month >= 6 && month <= 8) && userStats.goalsAchieved >= 1
            
        default:
            return false
        }
    }
    
    // MARK: - Complex Achievement Criteria
    
    /// Evaluate complex achievement patterns
    static func evaluateComplexCriteria(
        achievementId: String,
        userStats: UserStats,
        weightEntries: [WeightEntry]
    ) -> Bool {
        
        switch achievementId {
        case "steady_progress":
            return hasConsecutiveWeightLoss(entries: weightEntries, count: 3)
            
        case "plateau_breaker":
            return hasBrokenPlateau(entries: weightEntries)
            
        case "weekend_warrior":
            return hasWeekendLogs(entries: weightEntries)
            
        case "early_bird":
            return hasEarlyMorningLogs(entries: weightEntries, count: 7)
            
        default:
            return false
        }
    }
    
    // MARK: - Achievement Statistics and Insights
    
    /// Get detailed achievement statistics
    static func getDetailedStats(userAchievements: UserAchievements) -> DetailedAchievementStats {
        let allAchievements = AchievementDefinitions.allAchievements
        
        // Calculate completion by category
        var categoryStats: [AchievementCategory: CategoryStats] = [:]
        
        for category in AchievementCategory.allCases {
            let categoryAchievements = allAchievements.filter { $0.category == category }
            let unlockedInCategory = categoryAchievements.filter { userAchievements.isUnlocked($0.id) }
            
            categoryStats[category] = CategoryStats(
                total: categoryAchievements.count,
                unlocked: unlockedInCategory.count,
                totalPoints: categoryAchievements.reduce(0) { $0 + $1.points },
                earnedPoints: unlockedInCategory.reduce(0) { $0 + $1.points }
            )
        }
        
        // Calculate rarity distribution
        var rarityStats: [AchievementRarity: RarityStats] = [:]
        
        for rarity in AchievementRarity.allCases {
            let rarityAchievements = allAchievements.filter { $0.rarity == rarity }
            let unlockedOfRarity = rarityAchievements.filter { userAchievements.isUnlocked($0.id) }
            
            rarityStats[rarity] = RarityStats(
                total: rarityAchievements.count,
                unlocked: unlockedOfRarity.count,
                totalPoints: rarityAchievements.reduce(0) { $0 + $1.points },
                earnedPoints: unlockedOfRarity.reduce(0) { $0 + $1.points }
            )
        }
        
        // Calculate streaks and patterns
        let currentStreak = calculateCurrentUnlockStreak(userAchievements: userAchievements)
        let longestStreak = calculateLongestUnlockStreak(userAchievements: userAchievements)
        
        return DetailedAchievementStats(
            categoryStats: categoryStats,
            rarityStats: rarityStats,
            currentUnlockStreak: currentStreak,
            longestUnlockStreak: longestStreak,
            averagePointsPerAchievement: userAchievements.unlockedCount > 0 ? 
                Double(userAchievements.totalPoints) / Double(userAchievements.unlockedCount) : 0.0,
            completionVelocity: calculateCompletionVelocity(userAchievements: userAchievements)
        )
    }
    
    /// Get achievement insights and recommendations
    static func getAchievementInsights(
        userAchievements: UserAchievements,
        userStats: UserStats
    ) -> [AchievementInsight] {
        
        var insights: [AchievementInsight] = []
        
        // Analyze completion patterns
        if let patternInsight = analyzeCompletionPattern(userAchievements: userAchievements) {
            insights.append(patternInsight)
        }
        
        // Analyze category preferences
        if let preferenceInsight = analyzeCategoryPreferences(userAchievements: userAchievements) {
            insights.append(preferenceInsight)
        }
        
        // Suggest focus areas
        let focusInsights = suggestFocusAreas(userAchievements: userAchievements, userStats: userStats)
        insights.append(contentsOf: focusInsights)
        
        return insights
    }
    
    // MARK: - Private Helper Methods
    
    private static func hasConsecutiveWeightLoss(entries: [WeightEntry], count: Int) -> Bool {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard sortedEntries.count >= count else { return false }
        
        var consecutiveCount = 0
        
        for i in 1..<sortedEntries.count {
            if sortedEntries[i].weight < sortedEntries[i-1].weight {
                consecutiveCount += 1
                if consecutiveCount >= count - 1 {
                    return true
                }
            } else {
                consecutiveCount = 0
            }
        }
        
        return false
    }
    
    private static func hasBrokenPlateau(entries: [WeightEntry]) -> Bool {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard sortedEntries.count >= 10 else { return false }
        
        // Look for a plateau (no change for 2+ weeks) followed by weight loss
        let recentEntries = Array(sortedEntries.suffix(14))
        
        // Check for plateau in first part
        let plateauEntries = Array(recentEntries.prefix(7))
        let plateauWeights = plateauEntries.map { $0.weight }
        let plateauRange = plateauWeights.max()! - plateauWeights.min()!
        
        // Check for weight loss in second part
        let progressEntries = Array(recentEntries.suffix(7))
        let hasProgress = progressEntries.last!.weight < progressEntries.first!.weight
        
        return plateauRange <= 0.5 && hasProgress // Plateau if range <= 0.5kg, then progress
    }
    
    private static func hasWeekendLogs(entries: [WeightEntry]) -> Bool {
        let calendar = Calendar.current
        
        for entry in entries {
            guard let date = parseDate(entry.date) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            
            if weekday == 1 || weekday == 7 { // Sunday or Saturday
                return true
            }
        }
        
        return false
    }
    
    private static func hasEarlyMorningLogs(entries: [WeightEntry], count: Int) -> Bool {
        // Simplified implementation - would need time data in entries
        return entries.count >= count
    }
    
    private static func calculateCurrentUnlockStreak(userAchievements: UserAchievements) -> Int {
        // Simplified implementation
        return min(userAchievements.unlockedCount, 5)
    }
    
    private static func calculateLongestUnlockStreak(userAchievements: UserAchievements) -> Int {
        // Simplified implementation
        return min(userAchievements.unlockedCount, 10)
    }
    
    private static func calculateCompletionVelocity(userAchievements: UserAchievements) -> Double {
        // Achievements per day (simplified)
        return userAchievements.unlockedCount > 0 ? 0.1 : 0.0
    }
    
    private static func analyzeCompletionPattern(userAchievements: UserAchievements) -> AchievementInsight? {
        if userAchievements.unlockedCount >= 10 {
            return AchievementInsight(
                type: .pattern,
                title: "Achievement Streak!",
                description: "You're on fire! You've unlocked \(userAchievements.unlockedCount) achievements.",
                actionable: false
            )
        }
        
        return nil
    }
    
    private static func analyzeCategoryPreferences(userAchievements: UserAchievements) -> AchievementInsight? {
        // Find most completed category
        var categoryCompletion: [AchievementCategory: Double] = [:]
        
        for category in AchievementCategory.allCases {
            let categoryAchievements = AchievementDefinitions.getAchievements(by: category)
            let unlockedCount = categoryAchievements.filter { userAchievements.isUnlocked($0.id) }.count
            let completion = Double(unlockedCount) / Double(categoryAchievements.count)
            categoryCompletion[category] = completion
        }
        
        if let bestCategory = categoryCompletion.max(by: { $0.value < $1.value }) {
            if bestCategory.value > 0.5 {
                return AchievementInsight(
                    type: .preference,
                    title: "Category Expert",
                    description: "You excel at \(bestCategory.key.displayName) achievements!",
                    actionable: false
                )
            }
        }
        
        return nil
    }
    
    private static func suggestFocusAreas(
        userAchievements: UserAchievements,
        userStats: UserStats
    ) -> [AchievementInsight] {
        
        var insights: [AchievementInsight] = []
        
        // Suggest consistency if low
        if userStats.currentStreak < 7 {
            insights.append(AchievementInsight(
                type: .suggestion,
                title: "Focus on Consistency",
                description: "Log your weight daily to unlock consistency achievements.",
                actionable: true
            ))
        }
        
        // Suggest goal setting if no goals
        if userStats.goalsAchieved == 0 {
            insights.append(AchievementInsight(
                type: .suggestion,
                title: "Set Your First Goal",
                description: "Create a goal to unlock goal-related achievements.",
                actionable: true
            ))
        }
        
        return insights
    }
    
    private static func parseDate(_ dateString: String) -> Date? {
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
}

// MARK: - Supporting Data Structures

struct AchievementChain {
    let id: String
    let name: String
    let achievements: [String] // Achievement IDs in order
    let description: String
    
    var progress: Double {
        // Would calculate based on user's unlocked achievements
        return 0.0
    }
}

struct CategoryStats {
    let total: Int
    let unlocked: Int
    let totalPoints: Int
    let earnedPoints: Int
    
    var completionPercentage: Double {
        return total > 0 ? Double(unlocked) / Double(total) : 0.0
    }
    
    var pointsPercentage: Double {
        return totalPoints > 0 ? Double(earnedPoints) / Double(totalPoints) : 0.0
    }
}

struct RarityStats {
    let total: Int
    let unlocked: Int
    let totalPoints: Int
    let earnedPoints: Int
    
    var completionPercentage: Double {
        return total > 0 ? Double(unlocked) / Double(total) : 0.0
    }
}

struct DetailedAchievementStats {
    let categoryStats: [AchievementCategory: CategoryStats]
    let rarityStats: [AchievementRarity: RarityStats]
    let currentUnlockStreak: Int
    let longestUnlockStreak: Int
    let averagePointsPerAchievement: Double
    let completionVelocity: Double // Achievements per day
}

struct AchievementInsight {
    let type: InsightType
    let title: String
    let description: String
    let actionable: Bool
    
    enum InsightType {
        case pattern
        case preference
        case suggestion
        case warning
    }
}