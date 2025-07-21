//
//  SmartGoalsIntegrationService.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation
import Combine

// MARK: - Smart Goals Integration Service

@MainActor
class SmartGoalsIntegrationService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isInitialized = false
    @Published var systemHealth: SystemHealth = .unknown
    @Published var lastUpdateTime: Date = Date()
    
    // MARK: - Core Services
    
    let achievementSystem = AchievementSystem()
    let smartGoalEngine = SmartGoalEngine()
    let progressPredictor = ProgressPredictor()
    let smartGoalIntelligence = SmartGoalIntelligence()
    let celebrationManager = CelebrationManager()
    let photoManager = PhotoManager.shared
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = AchievementStorageService.shared
    
    // MARK: - Initialization
    
    init() {
        setupSystemIntegration()
        performSystemHealthCheck()
    }
    
    // MARK: - System Integration
    
    private func setupSystemIntegration() {
        // Monitor achievement system changes
        achievementSystem.$newlyUnlockedAchievements
            .sink { [weak self] newAchievements in
                if !newAchievements.isEmpty {
                    self?.handleNewAchievements(newAchievements)
                }
            }
            .store(in: &cancellables)
        
        // Monitor celebration manager
        celebrationManager.$showingAchievementCelebration
            .combineLatest(celebrationManager.$showingGoalCelebration)
            .sink { [weak self] (showingAchievement, showingGoal) in
                if !showingAchievement && !showingGoal {
                    self?.onCelebrationCompleted()
                }
            }
            .store(in: &cancellables)
        
        isInitialized = true
        print("✅ SmartGoalsIntegrationService: System initialized successfully")
    }
    
    // MARK: - Main Integration Methods
    
    /// Comprehensive system update - call this when weight data changes
    func updateSystem(
        currentWeight: Double,
        weightEntries: [WeightEntry],
        goals: [Goal]
    ) async {
        
        print("🔄 SmartGoalsIntegrationService: Starting system update...")
        
        // 1. Update achievements and detect new unlocks
        let previousAchievements = achievementSystem.userAchievements
        
        await achievementSystem.evaluateAchievements(
            currentWeight: currentWeight,
            weightEntries: weightEntries,
            goals: goals
        )
        
        // 2. Check for newly unlocked achievements
        let newAchievements = AchievementCriteriaEvaluator.getNewlyUnlockedAchievements(
            current: achievementSystem.userAchievements,
            previous: previousAchievements
        )
        
        // 3. Check for newly achieved goals
        let newlyAchievedGoals = goals.filter { goal in
            goal.isAchieved(currentWeight: currentWeight)
        }
        
        // 4. Trigger celebrations
        if !newAchievements.isEmpty {
            celebrationManager.celebrateMultipleAchievements(newAchievements)
        }
        
        for goal in newlyAchievedGoals {
            celebrationManager.celebrateGoal(goal)
        }
        
        // 5. Generate smart goal recommendations
        let goalRecommendations = smartGoalIntelligence.generateGoalRecommendations(
            currentWeight: currentWeight,
            weightEntries: weightEntries,
            existingGoals: goals
        )
        
        // 6. Check for goal adjustments
        let adjustmentSuggestions = smartGoalIntelligence.analyzeAndSuggestAdjustments(
            goals: goals,
            currentWeight: currentWeight,
            weightEntries: weightEntries
        )
        
        // 7. Update system health
        await updateSystemHealth()
        
        lastUpdateTime = Date()
        
        print("✅ SmartGoalsIntegrationService: System update completed")
        print("   - New achievements: \(newAchievements.count)")
        print("   - Achieved goals: \(newlyAchievedGoals.count)")
        print("   - Goal recommendations: \(goalRecommendations.count)")
        print("   - Adjustment suggestions: \(adjustmentSuggestions.count)")
    }
    
    /// Initialize system with user data
    func initializeWithUserData(
        currentWeight: Double,
        weightEntries: [WeightEntry],
        goals: [Goal]
    ) async {
        
        print("🚀 SmartGoalsIntegrationService: Initializing with user data...")
        
        // Perform initial system update without celebrations
        await achievementSystem.evaluateAchievements(
            currentWeight: currentWeight,
            weightEntries: weightEntries,
            goals: goals
        )
        
        // Clear any pending celebrations (we don't want to celebrate on app launch)
        celebrationManager.dismissCurrentCelebration()
        
        await updateSystemHealth()
        
        print("✅ SmartGoalsIntegrationService: Initialization completed")
    }
    
    // MARK: - Event Handlers
    
    private func handleNewAchievements(_ achievements: [Achievement]) {
        print("🏆 SmartGoalsIntegrationService: Handling \(achievements.count) new achievements")
        
        // Log achievement unlocks for analytics
        for achievement in achievements {
            print("   - Unlocked: \(achievement.name) (\(achievement.points) points)")
        }
        
        // Update system health after achievement changes
        Task {
            await updateSystemHealth()
        }
    }
    
    private func onCelebrationCompleted() {
        print("🎉 SmartGoalsIntegrationService: Celebration completed")
        
        // Mark achievements as seen
        achievementSystem.markNewAchievementsAsSeen()
        
        // Perform any post-celebration cleanup
        Task {
            await updateSystemHealth()
        }
    }
    
    // MARK: - System Health Monitoring
    
    private func performSystemHealthCheck() {
        Task {
            await updateSystemHealth()
        }
    }
    
    private func updateSystemHealth() async {
        var healthIssues: [HealthIssue] = []
        
        // Check achievement system health
        let achievementErrors = AchievementCriteriaEvaluator.validateAllAchievements()
        if !achievementErrors.isEmpty {
            healthIssues.append(.achievementValidationErrors(achievementErrors.count))
        }
        
        // Check storage health
        let storageInfo = storageService.getStorageInfo()
        if !storageInfo.isHealthy {
            healthIssues.append(.storageIssues)
        }
        
        // Check performance
        let performanceMetrics = AchievementPerformanceOptimizer.getPerformanceMetrics()
        if performanceMetrics.averageEvaluationTime > 0.5 {
            healthIssues.append(.performanceIssues)
        }
        
        // Update system health
        if healthIssues.isEmpty {
            systemHealth = .healthy
        } else if healthIssues.contains(where: { $0.severity == .high }) {
            systemHealth = .critical
        } else {
            systemHealth = .warning(healthIssues)
        }
        
        print("🔍 SmartGoalsIntegrationService: System health: \(systemHealth)")
    }
    
    // MARK: - Utility Methods
    
    /// Get comprehensive system statistics
    func getSystemStatistics() -> SystemStatistics {
        let achievementStats = achievementSystem.achievementStats
        let storageInfo = storageService.getStorageInfo()
        let performanceMetrics = AchievementPerformanceOptimizer.getPerformanceMetrics()
        
        return SystemStatistics(
            achievementStats: achievementStats,
            storageInfo: storageInfo,
            performanceMetrics: performanceMetrics,
            systemHealth: systemHealth,
            lastUpdateTime: lastUpdateTime,
            isInitialized: isInitialized
        )
    }
    
    /// Reset entire system (for testing or user request)
    func resetSystem() async {
        print("🔄 SmartGoalsIntegrationService: Resetting system...")
        
        // Reset achievement system
        achievementSystem.resetAllAchievements()
        
        // Clear celebrations
        celebrationManager.dismissCurrentCelebration()
        
        // Clear caches
        AchievementPerformanceOptimizer.clearCache()
        
        // Update health
        await updateSystemHealth()
        
        print("✅ SmartGoalsIntegrationService: System reset completed")
    }
    
    /// Export all system data
    func exportSystemData() -> SystemExport? {
        guard let achievementData = storageService.exportAchievements() else {
            return nil
        }
        
        let photoData = photoManager.getAllProgressPhotos()
        let systemStats = getSystemStatistics()
        
        return SystemExport(
            achievementData: achievementData,
            photoCount: photoData.count,
            systemStatistics: systemStats,
            exportDate: Date()
        )
    }
    
    /// Import system data
    func importSystemData(_ exportData: SystemExport) -> Bool {
        print("📥 SmartGoalsIntegrationService: Importing system data...")
        
        let success = storageService.importAchievements(from: exportData.achievementData)
        
        if success {
            // Reload achievement system
            Task {
                await achievementSystem.forceEvaluation(
                    currentWeight: 0, // Will be updated with real data
                    weightEntries: [],
                    goals: []
                )
                
                await updateSystemHealth()
            }
            
            print("✅ SmartGoalsIntegrationService: Import completed successfully")
        } else {
            print("❌ SmartGoalsIntegrationService: Import failed")
        }
        
        return success
    }
}

// MARK: - Supporting Data Structures

enum SystemHealth: Equatable {
    case unknown
    case healthy
    case warning([HealthIssue])
    case critical
    
    var displayText: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .healthy:
            return "Healthy"
        case .warning(let issues):
            return "Warning (\(issues.count) issues)"
        case .critical:
            return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .unknown:
            return "gray"
        case .healthy:
            return "green"
        case .warning:
            return "orange"
        case .critical:
            return "red"
        }
    }
}

enum HealthIssue: Equatable {
    case achievementValidationErrors(Int)
    case storageIssues
    case performanceIssues
    case memoryIssues
    
    var severity: Severity {
        switch self {
        case .achievementValidationErrors:
            return .medium
        case .storageIssues:
            return .high
        case .performanceIssues:
            return .medium
        case .memoryIssues:
            return .high
        }
    }
    
    var description: String {
        switch self {
        case .achievementValidationErrors(let count):
            return "\(count) achievement validation errors"
        case .storageIssues:
            return "Storage system issues detected"
        case .performanceIssues:
            return "Performance degradation detected"
        case .memoryIssues:
            return "Memory usage issues detected"
        }
    }
    
    enum Severity {
        case low, medium, high
    }
}

struct SystemStatistics {
    let achievementStats: AchievementStats
    let storageInfo: StorageInfo
    let performanceMetrics: PerformanceMetrics
    let systemHealth: SystemHealth
    let lastUpdateTime: Date
    let isInitialized: Bool
    
    var formattedLastUpdate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: lastUpdateTime)
    }
}

struct SystemExport {
    let achievementData: Data
    let photoCount: Int
    let systemStatistics: SystemStatistics
    let exportDate: Date
    
    var formattedExportDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: exportDate)
    }
    
    var exportSize: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(achievementData.count))
    }
}