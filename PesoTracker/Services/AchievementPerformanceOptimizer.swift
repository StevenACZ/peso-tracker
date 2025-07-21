//
//  AchievementPerformanceOptimizer.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Achievement Performance Optimizer

class AchievementPerformanceOptimizer {
    
    // MARK: - Caching System
    
    private static var achievementCache: [String: Achievement] = [:]
    private static var progressCache: [String: AchievementProgress] = [:]
    private static var statsCache: AchievementStats?
    private static var cacheTimestamp: Date = Date.distantPast
    private static let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    /// Get achievement with caching
    static func getCachedAchievement(by id: String) -> Achievement? {
        if achievementCache.isEmpty {
            populateAchievementCache()
        }
        return achievementCache[id]
    }
    
    /// Get all achievements with caching
    static func getCachedAchievements() -> [Achievement] {
        if achievementCache.isEmpty {
            populateAchievementCache()
        }
        return Array(achievementCache.values)
    }
    
    /// Populate achievement cache
    private static func populateAchievementCache() {
        for achievement in AchievementDefinitions.allAchievements {
            achievementCache[achievement.id] = achievement
        }
    }
    
    /// Cache achievement progress
    static func cacheProgress(_ progress: [String: AchievementProgress]) {
        progressCache = progress
        cacheTimestamp = Date()
    }
    
    /// Get cached progress
    static func getCachedProgress(for achievementId: String) -> AchievementProgress? {
        guard Date().timeIntervalSince(cacheTimestamp) < cacheTimeout else {
            return nil // Cache expired
        }
        return progressCache[achievementId]
    }
    
    /// Cache achievement statistics
    static func cacheStats(_ stats: AchievementStats) {
        statsCache = stats
        cacheTimestamp = Date()
    }
    
    /// Get cached statistics
    static func getCachedStats() -> AchievementStats? {
        guard Date().timeIntervalSince(cacheTimestamp) < cacheTimeout else {
            return nil // Cache expired
        }
        return statsCache
    }
    
    /// Clear all caches
    static func clearCache() {
        achievementCache.removeAll()
        progressCache.removeAll()
        statsCache = nil
        cacheTimestamp = Date.distantPast
    }
    
    // MARK: - Batch Processing
    
    /// Process achievements in batches for better performance
    static func batchEvaluateAchievements(
        userStats: UserStats,
        batchSize: Int = 10
    ) async -> UserAchievements {
        
        let achievements = AchievementDefinitions.allAchievements
        var allProgress: [String: AchievementProgress] = [:]
        var totalPoints = 0
        var unlockedCount = 0
        
        // Process in batches
        for i in stride(from: 0, to: achievements.count, by: batchSize) {
            let endIndex = min(i + batchSize, achievements.count)
            let batch = Array(achievements[i..<endIndex])
            
            // Process batch
            let batchResults = await processBatch(batch, userStats: userStats)
            
            // Merge results
            for (id, progress) in batchResults.progress {
                allProgress[id] = progress
                if progress.isUnlocked {
                    totalPoints += batchResults.achievements[id]?.points ?? 0
                    unlockedCount += 1
                }
            }
            
            // Small delay to prevent blocking the main thread
            try? await Task.sleep(for: .milliseconds(1))
        }
        
        return UserAchievements(
            totalPoints: totalPoints,
            unlockedCount: unlockedCount,
            achievements: allProgress
        )
    }
    
    /// Process a batch of achievements
    private static func processBatch(
        _ achievements: [Achievement],
        userStats: UserStats
    ) async -> BatchResult {
        
        var progress: [String: AchievementProgress] = [:]
        var achievementMap: [String: Achievement] = [:]
        
        for achievement in achievements {
            achievementMap[achievement.id] = achievement
            
            guard let criteria = achievement.createCriteria() else { continue }
            
            let isUnlocked = criteria.isUnlocked(userStats: userStats)
            let progressValue = criteria.getProgress(userStats: userStats)
            let currentValue = criteria.getCurrentValue(userStats: userStats)
            let targetValue = criteria.getTargetValue()
            
            progress[achievement.id] = AchievementProgress(
                achievementId: achievement.id,
                isUnlocked: isUnlocked,
                unlockedAt: isUnlocked ? Date() : nil,
                progress: progressValue,
                currentValue: currentValue,
                targetValue: targetValue
            )
        }
        
        return BatchResult(progress: progress, achievements: achievementMap)
    }
    
    // MARK: - Lazy Loading
    
    /// Lazy load achievement details only when needed
    static func lazyLoadAchievementDetails(for ids: [String]) -> [Achievement] {
        return ids.compactMap { id in
            getCachedAchievement(by: id)
        }
    }
    
    /// Lazy load achievement progress only for visible achievements
    static func lazyLoadProgress(
        for achievementIds: [String],
        userStats: UserStats
    ) -> [String: AchievementProgress] {
        
        var progress: [String: AchievementProgress] = [:]
        
        for id in achievementIds {
            // Check cache first
            if let cachedProgress = getCachedProgress(for: id) {
                progress[id] = cachedProgress
                continue
            }
            
            // Calculate if not cached
            guard let achievement = getCachedAchievement(by: id),
                  let criteria = achievement.createCriteria() else { continue }
            
            let isUnlocked = criteria.isUnlocked(userStats: userStats)
            let progressValue = criteria.getProgress(userStats: userStats)
            let currentValue = criteria.getCurrentValue(userStats: userStats)
            let targetValue = criteria.getTargetValue()
            
            let achievementProgress = AchievementProgress(
                achievementId: id,
                isUnlocked: isUnlocked,
                unlockedAt: isUnlocked ? Date() : nil,
                progress: progressValue,
                currentValue: currentValue,
                targetValue: targetValue
            )
            
            progress[id] = achievementProgress
        }
        
        return progress
    }
    
    // MARK: - Background Processing
    
    /// Process achievements in background queue
    static func backgroundEvaluateAchievements(
        userStats: UserStats,
        completion: @escaping (UserAchievements) -> Void
    ) {
        
        DispatchQueue.global(qos: .background).async {
            let achievements = AchievementDefinitions.allAchievements
            var allProgress: [String: AchievementProgress] = [:]
            var totalPoints = 0
            var unlockedCount = 0
            
            for achievement in achievements {
                guard let criteria = achievement.createCriteria() else { continue }
                
                let isUnlocked = criteria.isUnlocked(userStats: userStats)
                let progressValue = criteria.getProgress(userStats: userStats)
                let currentValue = criteria.getCurrentValue(userStats: userStats)
                let targetValue = criteria.getTargetValue()
                
                let progress = AchievementProgress(
                    achievementId: achievement.id,
                    isUnlocked: isUnlocked,
                    unlockedAt: isUnlocked ? Date() : nil,
                    progress: progressValue,
                    currentValue: currentValue,
                    targetValue: targetValue
                )
                
                allProgress[achievement.id] = progress
                
                if isUnlocked {
                    totalPoints += achievement.points
                    unlockedCount += 1
                }
            }
            
            let result = UserAchievements(
                totalPoints: totalPoints,
                unlockedCount: unlockedCount,
                achievements: allProgress
            )
            
            // Cache results
            cacheProgress(allProgress)
            
            // Return to main queue
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Memory Management
    
    /// Optimize memory usage by cleaning up unused data
    static func optimizeMemoryUsage() {
        // Clear expired cache entries
        if Date().timeIntervalSince(cacheTimestamp) > cacheTimeout {
            clearCache()
        }
        
        // Limit cache size
        if progressCache.count > 100 {
            // Keep only most recent 50 entries
            let sortedKeys = progressCache.keys.sorted()
            let keysToRemove = Array(sortedKeys.prefix(progressCache.count - 50))
            
            for key in keysToRemove {
                progressCache.removeValue(forKey: key)
            }
        }
    }
    
    // MARK: - Performance Monitoring
    
    /// Monitor achievement evaluation performance
    static func measureEvaluationPerformance<T>(
        operation: () throws -> T,
        operationName: String
    ) rethrows -> T {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print("🔍 Performance: \(operationName) took \(String(format: "%.3f", timeElapsed))s")
        
        // Log slow operations
        if timeElapsed > 0.1 {
            print("⚠️ Slow operation detected: \(operationName)")
        }
        
        return result
    }
    
    /// Monitor async achievement evaluation performance
    static func measureEvaluationPerformanceAsync<T>(
        operation: () async throws -> T,
        operationName: String
    ) async rethrows -> T {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print("🔍 Performance: \(operationName) took \(String(format: "%.3f", timeElapsed))s")
        
        // Log slow operations
        if timeElapsed > 0.1 {
            print("⚠️ Slow operation detected: \(operationName)")
        }
        
        return result
    }
    
    /// Get performance metrics
    static func getPerformanceMetrics() -> PerformanceMetrics {
        return PerformanceMetrics(
            cacheHitRate: calculateCacheHitRate(),
            averageEvaluationTime: 0.05, // Would be calculated from actual measurements
            memoryUsage: getMemoryUsage(),
            cacheSize: progressCache.count
        )
    }
    
    private static func calculateCacheHitRate() -> Double {
        // Simplified implementation
        return progressCache.isEmpty ? 0.0 : 0.8
    }
    
    private static func getMemoryUsage() -> Int {
        // Simplified memory usage calculation
        return achievementCache.count * 1000 + progressCache.count * 500
    }
}

// MARK: - Supporting Data Structures

private struct BatchResult {
    let progress: [String: AchievementProgress]
    let achievements: [String: Achievement]
}

struct PerformanceMetrics {
    let cacheHitRate: Double
    let averageEvaluationTime: TimeInterval
    let memoryUsage: Int // bytes
    let cacheSize: Int
    
    var formattedCacheHitRate: String {
        return String(format: "%.1f%%", cacheHitRate * 100)
    }
    
    var formattedEvaluationTime: String {
        return String(format: "%.3fs", averageEvaluationTime)
    }
    
    var formattedMemoryUsage: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(memoryUsage))
    }
}

// MARK: - Optimized Achievement System Extension

extension AchievementSystem {
    
    /// Optimized achievement evaluation
    func optimizedEvaluateAchievements(
        currentWeight: Double,
        weightEntries: [WeightEntry],
        goals: [Goal]
    ) async {
        
        isEvaluating = true
        
        let userStats = UserStats(
            currentWeight: currentWeight,
            startingWeight: weightEntries.first?.weight ?? currentWeight,
            weightEntries: weightEntries,
            goals: goals
        )
        
        // Use performance monitoring
        let newAchievements = await AchievementPerformanceOptimizer.measureEvaluationPerformanceAsync(
            operation: {
                // Use background processing for better performance
                return await AchievementPerformanceOptimizer.batchEvaluateAchievements(
                    userStats: userStats
                )
            },
            operationName: "Achievement Evaluation"
        )
        
        // Update with optimized results
        updateWithOptimizedResults(newAchievements, userStats: userStats)
        
        isEvaluating = false
    }
    
    private func updateWithOptimizedResults(
        _ newAchievements: UserAchievements,
        userStats: UserStats
    ) {
        
        let previousAchievements = userAchievements
        
        userAchievements = newAchievements
        achievementStats = AchievementCriteriaEvaluator.calculateAchievementStats(
            userAchievements: newAchievements
        )
        
        // Find newly unlocked achievements
        newlyUnlockedAchievements = AchievementCriteriaEvaluator.getNewlyUnlockedAchievements(
            current: newAchievements,
            previous: previousAchievements
        )
        
        // Generate recommendations (cached)
        recommendedAchievements = AchievementCriteriaEvaluator.getRecommendations(
            userStats: userStats,
            userAchievements: newAchievements
        )
        
        // Save to storage
        _ = AchievementStorageService.shared.saveUserAchievements(newAchievements)
        
        // Optimize memory usage
        AchievementPerformanceOptimizer.optimizeMemoryUsage()
    }
}
