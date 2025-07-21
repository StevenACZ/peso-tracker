//
//  AchievementCriteriaEvaluator.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Achievement Criteria Evaluator

class AchievementCriteriaEvaluator {
    
    /// Evaluate all achievements for a user and return their progress
    static func evaluateAllAchievements(
        userStats: UserStats,
        previousAchievements: UserAchievements?
    ) -> UserAchievements {
        
        var achievementProgress: [String: AchievementProgress] = [:]
        var totalPoints = 0
        var unlockedCount = 0
        
        for achievement in AchievementDefinitions.allAchievements {
            guard let criteria = achievement.createCriteria() else { continue }
            
            let isUnlocked = criteria.isUnlocked(userStats: userStats)
            let progress = criteria.getProgress(userStats: userStats)
            let currentValue = criteria.getCurrentValue(userStats: userStats)
            let targetValue = criteria.getTargetValue()
            
            // Check if this is a newly unlocked achievement
            let wasUnlocked = previousAchievements?.isUnlocked(achievement.id) ?? false
            let unlockedAt: Date? = isUnlocked ? (wasUnlocked ? previousAchievements?.getProgress(for: achievement.id)?.unlockedAt : Date()) : nil
            
            let progressData = AchievementProgress(
                achievementId: achievement.id,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
                progress: progress,
                currentValue: currentValue,
                targetValue: targetValue
            )
            
            achievementProgress[achievement.id] = progressData
            
            if isUnlocked {
                totalPoints += achievement.points
                unlockedCount += 1
            }
        }
        
        return UserAchievements(
            totalPoints: totalPoints,
            unlockedCount: unlockedCount,
            achievements: achievementProgress
        )
    }
    
    /// Get newly unlocked achievements since last evaluation
    static func getNewlyUnlockedAchievements(
        current: UserAchievements,
        previous: UserAchievements?
    ) -> [Achievement] {
        
        guard let previous = previous else {
            // If no previous achievements, all unlocked achievements are new
            return AchievementDefinitions.getUnlockedAchievements(userAchievements: current)
        }
        
        var newlyUnlocked: [Achievement] = []
        
        for achievement in AchievementDefinitions.allAchievements {
            let wasUnlocked = previous.isUnlocked(achievement.id)
            let isNowUnlocked = current.isUnlocked(achievement.id)
            
            if !wasUnlocked && isNowUnlocked {
                newlyUnlocked.append(achievement)
            }
        }
        
        return newlyUnlocked
    }
    
    /// Get achievements that are close to being unlocked (>75% progress)
    static func getAlmostUnlockedAchievements(userAchievements: UserAchievements) -> [Achievement] {
        return AchievementDefinitions.allAchievements.filter { achievement in
            guard let progress = userAchievements.getProgress(for: achievement.id) else { return false }
            return !progress.isUnlocked && progress.progress >= 0.75
        }
    }
    
    /// Get the next achievement to work towards in each category
    static func getNextAchievementsPerCategory(userAchievements: UserAchievements) -> [AchievementCategory: Achievement] {
        var nextAchievements: [AchievementCategory: Achievement] = [:]
        
        for category in AchievementCategory.allCases {
            let categoryAchievements = AchievementDefinitions.getAchievements(by: category)
            
            // Find the first unlocked achievement in this category
            let nextAchievement = categoryAchievements.first { achievement in
                !userAchievements.isUnlocked(achievement.id)
            }
            
            if let next = nextAchievement {
                nextAchievements[category] = next
            }
        }
        
        return nextAchievements
    }
    
    /// Calculate achievement statistics
    static func calculateAchievementStats(userAchievements: UserAchievements) -> AchievementStats {
        let totalAchievements = AchievementDefinitions.allAchievements.count
        let unlockedCount = userAchievements.unlockedCount
        let totalPossiblePoints = AchievementDefinitions.getTotalPossiblePoints()
        let earnedPoints = userAchievements.totalPoints
        
        // Calculate category completion
        var categoryCompletion: [AchievementCategory: CategoryCompletion] = [:]
        
        for category in AchievementCategory.allCases {
            let categoryAchievements = AchievementDefinitions.getAchievements(by: category)
            let unlockedInCategory = categoryAchievements.filter { userAchievements.isUnlocked($0.id) }.count
            let totalInCategory = categoryAchievements.count
            let pointsInCategory = categoryAchievements.filter { userAchievements.isUnlocked($0.id) }.reduce(0) { $0 + $1.points }
            let totalPossibleInCategory = categoryAchievements.reduce(0) { $0 + $1.points }
            
            categoryCompletion[category] = CategoryCompletion(
                unlocked: unlockedInCategory,
                total: totalInCategory,
                points: pointsInCategory,
                totalPossible: totalPossibleInCategory
            )
        }
        
        // Calculate rarity distribution
        var rarityDistribution: [AchievementRarity: Int] = [:]
        for rarity in AchievementRarity.allCases {
            let unlockedOfRarity = AchievementDefinitions.getAchievements(by: rarity)
                .filter { userAchievements.isUnlocked($0.id) }.count
            rarityDistribution[rarity] = unlockedOfRarity
        }
        
        return AchievementStats(
            totalAchievements: totalAchievements,
            unlockedAchievements: unlockedCount,
            completionPercentage: Double(unlockedCount) / Double(totalAchievements),
            totalPoints: earnedPoints,
            totalPossiblePoints: totalPossiblePoints,
            pointsPercentage: Double(earnedPoints) / Double(totalPossiblePoints),
            categoryCompletion: categoryCompletion,
            rarityDistribution: rarityDistribution
        )
    }
}

// MARK: - Supporting Data Structures

struct CategoryCompletion {
    let unlocked: Int
    let total: Int
    let points: Int
    let totalPossible: Int
    
    var completionPercentage: Double {
        return total > 0 ? Double(unlocked) / Double(total) : 0.0
    }
    
    var pointsPercentage: Double {
        return totalPossible > 0 ? Double(points) / Double(totalPossible) : 0.0
    }
}

struct AchievementStats {
    let totalAchievements: Int
    let unlockedAchievements: Int
    let completionPercentage: Double
    let totalPoints: Int
    let totalPossiblePoints: Int
    let pointsPercentage: Double
    let categoryCompletion: [AchievementCategory: CategoryCompletion]
    let rarityDistribution: [AchievementRarity: Int]
    
    var completionPercentageInt: Int {
        return Int(completionPercentage * 100)
    }
    
    var pointsPercentageInt: Int {
        return Int(pointsPercentage * 100)
    }
}

// MARK: - Achievement Validation

extension AchievementCriteriaEvaluator {
    
    /// Validate that all achievements have valid criteria
    static func validateAllAchievements() -> [String] {
        var errors: [String] = []
        
        for achievement in AchievementDefinitions.allAchievements {
            if achievement.createCriteria() == nil {
                errors.append("Achievement '\(achievement.id)' has no valid criteria")
            }
            
            if achievement.name.isEmpty {
                errors.append("Achievement '\(achievement.id)' has empty name")
            }
            
            if achievement.description.isEmpty {
                errors.append("Achievement '\(achievement.id)' has empty description")
            }
            
            if achievement.points <= 0 {
                errors.append("Achievement '\(achievement.id)' has invalid points: \(achievement.points)")
            }
        }
        
        return errors
    }
    
    /// Check for duplicate achievement IDs
    static func checkForDuplicateIds() -> [String] {
        let ids = AchievementDefinitions.allAchievements.map { $0.id }
        let uniqueIds = Set(ids)
        
        if ids.count != uniqueIds.count {
            let duplicates = ids.filter { id in
                ids.filter { $0 == id }.count > 1
            }
            return Array(Set(duplicates))
        }
        
        return []
    }
}

// MARK: - Achievement Recommendations

extension AchievementCriteriaEvaluator {
    
    /// Get personalized achievement recommendations
    static func getRecommendations(
        userStats: UserStats,
        userAchievements: UserAchievements
    ) -> [AchievementRecommendation] {
        
        var recommendations: [AchievementRecommendation] = []
        
        // Recommend achievements that are close to completion
        let almostUnlocked = getAlmostUnlockedAchievements(userAchievements: userAchievements)
        for achievement in almostUnlocked {
            if let progress = userAchievements.getProgress(for: achievement.id) {
                recommendations.append(AchievementRecommendation(
                    achievement: achievement,
                    type: .almostComplete,
                    priority: .high,
                    progress: progress,
                    reason: "You're \(Int((1.0 - progress.progress) * 100))% away from unlocking this!"
                ))
            }
        }
        
        // Recommend next achievements in each category
        let nextPerCategory = getNextAchievementsPerCategory(userAchievements: userAchievements)
        for (category, achievement) in nextPerCategory {
            if let progress = userAchievements.getProgress(for: achievement.id) {
                recommendations.append(AchievementRecommendation(
                    achievement: achievement,
                    type: .nextInCategory,
                    priority: .medium,
                    progress: progress,
                    reason: "Next \(category.displayName.lowercased()) achievement to unlock"
                ))
            }
        }
        
        // Recommend based on user's current activity
        if userStats.currentStreak > 0 {
            let consistencyAchievements = AchievementDefinitions.getAchievements(by: .consistency)
                .filter { !userAchievements.isUnlocked($0.id) }
                .first
            
            if let achievement = consistencyAchievements,
               let progress = userAchievements.getProgress(for: achievement.id) {
                recommendations.append(AchievementRecommendation(
                    achievement: achievement,
                    type: .basedOnActivity,
                    priority: .high,
                    progress: progress,
                    reason: "Keep up your \(userStats.currentStreak)-day streak!"
                ))
            }
        }
        
        // Sort by priority and progress
        return recommendations.sorted { first, second in
            if first.priority != second.priority {
                return first.priority.rawValue < second.priority.rawValue
            }
            return first.progress.progress > second.progress.progress
        }
    }
}

struct AchievementRecommendation {
    let achievement: Achievement
    let type: RecommendationType
    let priority: Priority
    let progress: AchievementProgress
    let reason: String
    
    enum RecommendationType {
        case almostComplete
        case nextInCategory
        case basedOnActivity
        case seasonal
    }
    
    enum Priority: Int {
        case high = 1
        case medium = 2
        case low = 3
    }
}