//
//  AchievementSystem.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation
import Combine

// MARK: - Achievement System

@MainActor
class AchievementSystem: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userAchievements: UserAchievements
    @Published var achievementStats: AchievementStats
    @Published var newlyUnlockedAchievements: [Achievement] = []
    @Published var recommendedAchievements: [AchievementRecommendation] = []
    @Published var isEvaluating = false
    
    // MARK: - Private Properties
    
    private let storageManager: AchievementStorageManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        self.storageManager = AchievementStorageManager()
        
        // Load existing achievements or create empty state
        let loadedAchievements = storageManager.loadUserAchievements() ?? UserAchievements(
            totalPoints: 0,
            unlockedCount: 0,
            achievements: [:]
        )
        
        self.userAchievements = loadedAchievements
        
        // Calculate initial stats
        self.achievementStats = AchievementCriteriaEvaluator.calculateAchievementStats(
            userAchievements: loadedAchievements
        )
        
        // Validate achievements on startup
        validateAchievements()
    }
    
    // MARK: - Main Evaluation Method
    
    /// Evaluate all achievements based on current user data
    func evaluateAchievements(
        currentWeight: Double,
        weightEntries: [WeightEntry],
        goals: [Goal]
    ) async {
        isEvaluating = true
        
        // Create user stats from current data
        let userStats = UserStats(
            currentWeight: currentWeight,
            startingWeight: weightEntries.first?.weight ?? currentWeight,
            weightEntries: weightEntries,
            goals: goals
        )
        
        // Store previous achievements for comparison
        let previousAchievements = userAchievements
        
        // Evaluate all achievements
        let newAchievements = AchievementCriteriaEvaluator.evaluateAllAchievements(
            userStats: userStats,
            previousAchievements: previousAchievements
        )
        
        // Find newly unlocked achievements
        let newlyUnlocked = AchievementCriteriaEvaluator.getNewlyUnlockedAchievements(
            current: newAchievements,
            previous: previousAchievements
        )
        
        // Update published properties
        userAchievements = newAchievements
        achievementStats = AchievementCriteriaEvaluator.calculateAchievementStats(
            userAchievements: newAchievements
        )
        newlyUnlockedAchievements = newlyUnlocked
        
        // Generate recommendations
        recommendedAchievements = AchievementCriteriaEvaluator.getRecommendations(
            userStats: userStats,
            userAchievements: newAchievements
        )
        
        // Save to storage
        storageManager.saveUserAchievements(newAchievements)
        
        // Log newly unlocked achievements
        if !newlyUnlocked.isEmpty {
            print("🏆 AchievementSystem: Unlocked \(newlyUnlocked.count) new achievements:")
            for achievement in newlyUnlocked {
                print("   - \(achievement.name) (\(achievement.points) points)")
            }
        }
        
        isEvaluating = false
    }
    
    // MARK: - Achievement Queries
    
    /// Get achievements by category
    func getAchievements(by category: AchievementCategory) -> [Achievement] {
        return AchievementDefinitions.getAchievements(by: category)
    }
    
    /// Get achievements by rarity
    func getAchievements(by rarity: AchievementRarity) -> [Achievement] {
        return AchievementDefinitions.getAchievements(by: rarity)
    }
    
    /// Get unlocked achievements
    func getUnlockedAchievements() -> [Achievement] {
        return AchievementDefinitions.getUnlockedAchievements(userAchievements: userAchievements)
    }
    
    /// Get locked achievements
    func getLockedAchievements() -> [Achievement] {
        return AchievementDefinitions.getLockedAchievements(userAchievements: userAchievements)
    }
    
    /// Get achievements grouped by category
    func getAchievementsGroupedByCategory() -> [AchievementCategory: [Achievement]] {
        return AchievementDefinitions.getAchievementsGroupedByCategory()
    }
    
    /// Get achievement progress for a specific achievement
    func getProgress(for achievementId: String) -> AchievementProgress? {
        return userAchievements.getProgress(for: achievementId)
    }
    
    /// Check if an achievement is unlocked
    func isUnlocked(_ achievementId: String) -> Bool {
        return userAchievements.isUnlocked(achievementId)
    }
    
    // MARK: - Achievement Actions
    
    /// Mark newly unlocked achievements as seen
    func markNewAchievementsAsSeen() {
        newlyUnlockedAchievements.removeAll()
    }
    
    /// Get achievement by ID
    func getAchievement(by id: String) -> Achievement? {
        return AchievementDefinitions.getAchievement(by: id)
    }
    
    /// Force re-evaluation of achievements
    func forceEvaluation(
        currentWeight: Double,
        weightEntries: [WeightEntry],
        goals: [Goal]
    ) async {
        await evaluateAchievements(
            currentWeight: currentWeight,
            weightEntries: weightEntries,
            goals: goals
        )
    }
    
    // MARK: - Statistics and Insights
    
    /// Get achievements that are close to being unlocked
    func getAlmostUnlockedAchievements() -> [Achievement] {
        return AchievementCriteriaEvaluator.getAlmostUnlockedAchievements(
            userAchievements: userAchievements
        )
    }
    
    /// Get next achievement to work towards in each category
    func getNextAchievementsPerCategory() -> [AchievementCategory: Achievement] {
        return AchievementCriteriaEvaluator.getNextAchievementsPerCategory(
            userAchievements: userAchievements
        )
    }
    
    /// Get achievements organized by progress status
    func getAchievementsByProgress() -> (unlocked: [Achievement], inProgress: [Achievement], locked: [Achievement]) {
        return AchievementDefinitions.getAchievementsByProgress(userAchievements: userAchievements)
    }
    
    // MARK: - Data Management
    
    /// Reset all achievements (for testing or user request)
    func resetAllAchievements() {
        userAchievements = UserAchievements(
            totalPoints: 0,
            unlockedCount: 0,
            achievements: [:]
        )
        
        achievementStats = AchievementCriteriaEvaluator.calculateAchievementStats(
            userAchievements: userAchievements
        )
        
        newlyUnlockedAchievements.removeAll()
        recommendedAchievements.removeAll()
        
        storageManager.clearAllAchievements()
        
        print("🔄 AchievementSystem: All achievements reset")
    }
    
    /// Export achievements data
    func exportAchievements() -> Data? {
        return storageManager.exportAchievements()
    }
    
    /// Import achievements data
    func importAchievements(from data: Data) -> Bool {
        if storageManager.importAchievements(from: data) {
            // Reload achievements after import
            if let imported = storageManager.loadUserAchievements() {
                userAchievements = imported
                achievementStats = AchievementCriteriaEvaluator.calculateAchievementStats(
                    userAchievements: imported
                )
                return true
            }
        }
        return false
    }
    
    // MARK: - Validation
    
    private func validateAchievements() {
        let errors = AchievementCriteriaEvaluator.validateAllAchievements()
        let duplicates = AchievementCriteriaEvaluator.checkForDuplicateIds()
        
        if !errors.isEmpty {
            print("⚠️ AchievementSystem: Validation errors found:")
            errors.forEach { error in
                print("   - \(error)")
            }
        }
        
        if !duplicates.isEmpty {
            print("⚠️ AchievementSystem: Duplicate achievement IDs found:")
            duplicates.forEach { duplicateId in
                print("   - \(duplicateId)")
            }
        }
        
        if errors.isEmpty && duplicates.isEmpty {
            print("✅ AchievementSystem: All achievements validated successfully")
        }
    }
}

// MARK: - Achievement Storage Manager

class AchievementStorageManager {
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "user_achievements"
    private let backupKey = "achievements_backup"
    
    // MARK: - Save/Load Methods
    
    func saveUserAchievements(_ achievements: UserAchievements) {
        do {
            let data = try JSONEncoder().encode(achievements)
            userDefaults.set(data, forKey: achievementsKey)
            
            // Create backup
            userDefaults.set(data, forKey: backupKey)
            
            print("💾 AchievementStorageManager: Achievements saved successfully")
        } catch {
            print("❌ AchievementStorageManager: Failed to save achievements: \(error)")
        }
    }
    
    func loadUserAchievements() -> UserAchievements? {
        guard let data = userDefaults.data(forKey: achievementsKey) else {
            print("📂 AchievementStorageManager: No saved achievements found")
            return nil
        }
        
        do {
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            print("📂 AchievementStorageManager: Achievements loaded successfully")
            return achievements
        } catch {
            print("❌ AchievementStorageManager: Failed to load achievements: \(error)")
            
            // Try to load from backup
            return loadFromBackup()
        }
    }
    
    private func loadFromBackup() -> UserAchievements? {
        guard let data = userDefaults.data(forKey: backupKey) else {
            print("📂 AchievementStorageManager: No backup found")
            return nil
        }
        
        do {
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            print("📂 AchievementStorageManager: Achievements restored from backup")
            
            // Save restored data as main data
            saveUserAchievements(achievements)
            
            return achievements
        } catch {
            print("❌ AchievementStorageManager: Failed to load from backup: \(error)")
            return nil
        }
    }
    
    // MARK: - Utility Methods
    
    func clearAllAchievements() {
        userDefaults.removeObject(forKey: achievementsKey)
        userDefaults.removeObject(forKey: backupKey)
        print("🗑️ AchievementStorageManager: All achievements cleared")
    }
    
    func exportAchievements() -> Data? {
        return userDefaults.data(forKey: achievementsKey)
    }
    
    func importAchievements(from data: Data) -> Bool {
        do {
            // Validate data by trying to decode it
            let _ = try JSONDecoder().decode(UserAchievements.self, from: data)
            
            // If successful, save it
            userDefaults.set(data, forKey: achievementsKey)
            print("📥 AchievementStorageManager: Achievements imported successfully")
            return true
        } catch {
            print("❌ AchievementStorageManager: Failed to import achievements: \(error)")
            return false
        }
    }
    
    func getStorageSize() -> Int {
        guard let data = userDefaults.data(forKey: achievementsKey) else { return 0 }
        return data.count
    }
    
    func getLastModified() -> Date? {
        return userDefaults.object(forKey: "\(achievementsKey)_modified") as? Date
    }
}

// MARK: - Achievement System Extensions

extension AchievementSystem {
    
    /// Get summary statistics for display
    var summaryStats: AchievementSummary {
        return AchievementSummary(
            totalPoints: userAchievements.totalPoints,
            unlockedCount: userAchievements.unlockedCount,
            totalAchievements: AchievementDefinitions.allAchievements.count,
            completionPercentage: achievementStats.completionPercentageInt,
            recentUnlocks: newlyUnlockedAchievements.count,
            almostUnlocked: getAlmostUnlockedAchievements().count
        )
    }
    
    /// Get achievements for dashboard display
    var dashboardAchievements: [Achievement] {
        let recent = newlyUnlockedAchievements.prefix(3)
        if recent.count >= 3 {
            return Array(recent)
        }
        
        // Fill with recently unlocked achievements
        let unlocked = getUnlockedAchievements()
            .sorted { first, second in
                let firstProgress = getProgress(for: first.id)
                let secondProgress = getProgress(for: second.id)
                
                guard let firstDate = firstProgress?.unlockedAt,
                      let secondDate = secondProgress?.unlockedAt else {
                    return false
                }
                
                return firstDate > secondDate
            }
            .prefix(3 - recent.count)
        
        return Array(recent) + Array(unlocked)
    }
}

struct AchievementSummary {
    let totalPoints: Int
    let unlockedCount: Int
    let totalAchievements: Int
    let completionPercentage: Int
    let recentUnlocks: Int
    let almostUnlocked: Int
    
    var pointsText: String {
        return "\(totalPoints) points"
    }
    
    var progressText: String {
        return "\(unlockedCount)/\(totalAchievements) achievements"
    }
    
    var completionText: String {
        return "\(completionPercentage)% complete"
    }
}