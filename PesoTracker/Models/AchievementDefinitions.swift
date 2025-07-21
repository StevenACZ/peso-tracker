//
//  AchievementDefinitions.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Achievement Definitions

struct AchievementDefinitions {
    
    static let allAchievements: [Achievement] = [
        // Weight Loss Achievements
        Achievement(
            id: "first_step",
            name: "First Step",
            description: "Lose your first 0.5kg",
            category: .weightLoss,
            rarity: .common,
            icon: "🎯",
            points: 10
        ),
        
        Achievement(
            id: "getting_serious",
            name: "Getting Serious",
            description: "Lose 1kg total",
            category: .weightLoss,
            rarity: .common,
            icon: "🔥",
            points: 10
        ),
        
        Achievement(
            id: "milestone_master",
            name: "Milestone Master",
            description: "Lose 5kg total",
            category: .weightLoss,
            rarity: .rare,
            icon: "💪",
            points: 25
        ),
        
        Achievement(
            id: "transformation",
            name: "Transformation",
            description: "Lose 10kg total",
            category: .weightLoss,
            rarity: .epic,
            icon: "🏆",
            points: 50
        ),
        
        Achievement(
            id: "legend",
            name: "Legend",
            description: "Lose 20kg+ total",
            category: .weightLoss,
            rarity: .legendary,
            icon: "👑",
            points: 100
        ),
        
        // Milestone Achievements
        Achievement(
            id: "breaking_80",
            name: "Breaking Barriers",
            description: "Drop below 80kg",
            category: .milestones,
            rarity: .rare,
            icon: "🎊",
            points: 25
        ),
        
        Achievement(
            id: "breaking_75",
            name: "Precision Strike",
            description: "Drop below 75kg",
            category: .milestones,
            rarity: .epic,
            icon: "🎯",
            points: 50
        ),
        
        Achievement(
            id: "breaking_70",
            name: "Momentum",
            description: "Drop below 70kg",
            category: .milestones,
            rarity: .epic,
            icon: "🚀",
            points: 50
        ),
        
        // Consistency Achievements
        Achievement(
            id: "week_warrior",
            name: "Week Warrior",
            description: "Log weight for 7 consecutive days",
            category: .consistency,
            rarity: .common,
            icon: "📅",
            points: 10
        ),
        
        Achievement(
            id: "monthly_master",
            name: "Monthly Master",
            description: "Log weight for 30 consecutive days",
            category: .consistency,
            rarity: .rare,
            icon: "🗓️",
            points: 25
        ),
        
        Achievement(
            id: "dedication",
            name: "Dedication",
            description: "Log weight for 100 days total",
            category: .consistency,
            rarity: .epic,
            icon: "⭐",
            points: 50
        ),
        
        Achievement(
            id: "habit_former",
            name: "Habit Former",
            description: "Maintain logging streak for 6 months",
            category: .consistency,
            rarity: .legendary,
            icon: "🔄",
            points: 100
        ),
        
        // Goal Achievements
        Achievement(
            id: "goal_getter",
            name: "Goal Getter",
            description: "Achieve your first goal",
            category: .goals,
            rarity: .common,
            icon: "🎯",
            points: 10
        ),
        
        Achievement(
            id: "multi_tasker",
            name: "Multi-Tasker",
            description: "Have 3 active goals simultaneously",
            category: .goals,
            rarity: .rare,
            icon: "🎪",
            points: 25
        ),
        
        Achievement(
            id: "perfectionist",
            name: "Perfectionist",
            description: "Achieve a goal on the exact target date",
            category: .goals,
            rarity: .epic,
            icon: "🎨",
            points: 50
        ),
        
        Achievement(
            id: "speed_demon",
            name: "Speed Demon",
            description: "Achieve a goal ahead of schedule",
            category: .goals,
            rarity: .rare,
            icon: "🏃",
            points: 25
        ),
        
        // Special Achievements
        Achievement(
            id: "big_drop",
            name: "Big Drop",
            description: "Lose 2kg+ in a single week",
            category: .special,
            rarity: .rare,
            icon: "📉",
            points: 25
        ),
        
        Achievement(
            id: "roller_coaster",
            name: "Roller Coaster",
            description: "Experience your biggest single-day weight change",
            category: .special,
            rarity: .common,
            icon: "🎢",
            points: 10
        ),
        
        Achievement(
            id: "comeback_kid",
            name: "Comeback Kid",
            description: "Achieve a goal after missing the initial target date",
            category: .special,
            rarity: .epic,
            icon: "🎭",
            points: 50
        ),
        
        Achievement(
            id: "overachiever",
            name: "Overachiever",
            description: "Exceed a goal by 2kg or more",
            category: .special,
            rarity: .rare,
            icon: "🌟",
            points: 25
        ),
        
        // Additional Weight Loss Achievements
        Achievement(
            id: "steady_progress",
            name: "Steady Progress",
            description: "Lose weight for 3 consecutive weigh-ins",
            category: .weightLoss,
            rarity: .common,
            icon: "📈",
            points: 10
        ),
        
        Achievement(
            id: "halfway_hero",
            name: "Halfway Hero",
            description: "Reach 50% of your main goal",
            category: .milestones,
            rarity: .rare,
            icon: "🎖️",
            points: 25
        ),
        
        // Additional Consistency Achievements
        Achievement(
            id: "weekend_warrior",
            name: "Weekend Warrior",
            description: "Log weight on both weekend days",
            category: .consistency,
            rarity: .common,
            icon: "🏖️",
            points: 10
        ),
        
        Achievement(
            id: "early_bird",
            name: "Early Bird",
            description: "Log weight before 8 AM for 7 days",
            category: .consistency,
            rarity: .rare,
            icon: "🌅",
            points: 25
        ),
        
        // Additional Goal Achievements
        Achievement(
            id: "goal_crusher",
            name: "Goal Crusher",
            description: "Achieve 5 goals total",
            category: .goals,
            rarity: .epic,
            icon: "💥",
            points: 50
        ),
        
        Achievement(
            id: "marathon_runner",
            name: "Marathon Runner",
            description: "Complete a goal that takes 6+ months",
            category: .goals,
            rarity: .legendary,
            icon: "🏃‍♂️",
            points: 100
        ),
        
        // Additional Special Achievements
        Achievement(
            id: "new_year_new_me",
            name: "New Year, New Me",
            description: "Start your journey in January",
            category: .special,
            rarity: .common,
            icon: "🎊",
            points: 10
        ),
        
        Achievement(
            id: "summer_ready",
            name: "Summer Ready",
            description: "Achieve a goal during summer months",
            category: .special,
            rarity: .rare,
            icon: "☀️",
            points: 25
        ),
        
        Achievement(
            id: "plateau_breaker",
            name: "Plateau Breaker",
            description: "Lose weight after 2 weeks of no progress",
            category: .special,
            rarity: .epic,
            icon: "⛰️",
            points: 50
        )
    ]
    
    // MARK: - Helper Methods
    
    static func getAchievement(by id: String) -> Achievement? {
        return allAchievements.first { $0.id == id }
    }
    
    static func getAchievements(by category: AchievementCategory) -> [Achievement] {
        return allAchievements.filter { $0.category == category }
    }
    
    static func getAchievements(by rarity: AchievementRarity) -> [Achievement] {
        return allAchievements.filter { $0.rarity == rarity }
    }
    
    static func getUnlockedAchievements(userAchievements: UserAchievements) -> [Achievement] {
        return allAchievements.filter { achievement in
            userAchievements.isUnlocked(achievement.id)
        }
    }
    
    static func getLockedAchievements(userAchievements: UserAchievements) -> [Achievement] {
        return allAchievements.filter { achievement in
            !userAchievements.isUnlocked(achievement.id)
        }
    }
    
    static func getAchievementsGroupedByCategory() -> [AchievementCategory: [Achievement]] {
        return Dictionary(grouping: allAchievements) { $0.category }
    }
    
    static func getTotalPossiblePoints() -> Int {
        return allAchievements.reduce(0) { $0 + $1.points }
    }
    
    static func getAchievementsByProgress(userAchievements: UserAchievements) -> (unlocked: [Achievement], inProgress: [Achievement], locked: [Achievement]) {
        var unlocked: [Achievement] = []
        var inProgress: [Achievement] = []
        var locked: [Achievement] = []
        
        for achievement in allAchievements {
            if let progress = userAchievements.getProgress(for: achievement.id) {
                if progress.isUnlocked {
                    unlocked.append(achievement)
                } else if progress.progress > 0 {
                    inProgress.append(achievement)
                } else {
                    locked.append(achievement)
                }
            } else {
                locked.append(achievement)
            }
        }
        
        return (unlocked, inProgress, locked)
    }
}

// MARK: - Achievement Categories Extension

extension AchievementCategory {
    var achievements: [Achievement] {
        return AchievementDefinitions.getAchievements(by: self)
    }
    
    var totalPoints: Int {
        return achievements.reduce(0) { $0 + $1.points }
    }
    
    var achievementCount: Int {
        return achievements.count
    }
}

// MARK: - Achievement Rarity Extension

extension AchievementRarity {
    var achievements: [Achievement] {
        return AchievementDefinitions.getAchievements(by: self)
    }
    
    var totalPoints: Int {
        return achievements.reduce(0) { $0 + $1.points }
    }
    
    var achievementCount: Int {
        return achievements.count
    }
}