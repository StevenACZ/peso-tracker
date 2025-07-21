//
//  DashboardViewModel.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var weights: [WeightEntry] = []
    @Published var goals: [Goal] = []
    @Published var goalHierarchy: GoalHierarchy?
    @Published var currentWeight: Double = 0.0
    @Published var startingWeight: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var progressPrediction: ProgressPrediction?
    
    // Achievement and celebration system
    @Published var achievementSystem = AchievementSystem()
    @Published var celebrationManager = CelebrationManager()
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    private let smartGoalEngine = SmartGoalEngine()
    private let progressPredictor = ProgressPredictor()
    
    var weightProgress: Double {
        return currentWeight - startingWeight
    }
    
    var progressText: String {
        let progress = weightProgress
        if progress > 0 {
            return "Gained: +\(String(format: "%.1f", progress)) kg"
        } else if progress < 0 {
            return "Lost: \(String(format: "%.1f", abs(progress))) kg"
        } else {
            return "No change"
        }
    }
    
    var currentGoal: Goal? {
        return goalHierarchy?.currentMilestone ?? goalHierarchy?.mainGoal
    }
    
    var mainGoal: Goal? {
        return goalHierarchy?.mainGoal
    }
    
    var nextMilestone: Goal? {
        return GoalHierarchyManager.getNextMilestone(from: goals, currentWeight: currentWeight)
    }
    
    var achievedGoals: [Goal] {
        return GoalHierarchyManager.getAchievedGoals(from: goals, currentWeight: currentWeight)
    }
    
    var activeGoals: [Goal] {
        return GoalHierarchyManager.getActiveGoals(from: goals, currentWeight: currentWeight)
    }
    
    var goalProgress: Double? {
        guard let goal = currentGoal else { return nil }
        if startingWeight == 0 { return nil }
        
        let totalNeeded = abs(goal.targetWeight - startingWeight)
        let achieved = abs(currentWeight - startingWeight)
        
        return min(achieved / totalNeeded, 1.0)
    }
    
    var goalProgressText: String {
        guard let goal = currentGoal else { return "No goal set" }
        
        let remaining = goal.targetWeight - currentWeight
        
        // Check if goal is achieved (current weight is equal or less than target for weight loss)
        if currentWeight <= goal.targetWeight {
            return "¡Meta conseguida! 🎉"
        } else {
            return "\(String(format: "%.1f", remaining)) kg to go"
        }
    }
    
    func loadWeightData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load weights
            let weightResponse = try await apiService.getWeights()
            
            print("📊 DashboardViewModel: Received \(weightResponse.data.count) weight entries")
            
            // Sort weights by date (oldest first for display)
            weights = weightResponse.data.sorted { first, second in
                return first.date < second.date
            }
            
            // Calculate current and starting weights (now that oldest is first)
            if let oldest = weights.first {
                startingWeight = oldest.weight
                print("📊 DashboardViewModel: Starting weight set to \(startingWeight) kg")
            }
            if let mostRecent = weights.last {
                currentWeight = mostRecent.weight
                print("📊 DashboardViewModel: Current weight set to \(currentWeight) kg")
            }
            
            // If we only have one entry, use it for both current and starting
            if weights.count == 1 {
                startingWeight = currentWeight
                print("📊 DashboardViewModel: Only one entry, using same weight for both current and starting")
            }
            
            // Load goals
            do {
                let goalResponse = try await apiService.getGoals()
                goals = goalResponse.data
                
                // Create goal hierarchy
                goalHierarchy = GoalHierarchyManager.createHierarchy(from: goals)
                
                // Generate progress prediction if we have a main goal
                if let mainGoal = goalHierarchy?.mainGoal,
                   let targetDate = parseDate(mainGoal.targetDate) {
                    progressPrediction = progressPredictor.generatePrediction(
                        currentWeight: currentWeight,
                        targetWeight: mainGoal.targetWeight,
                        targetDate: targetDate,
                        weightEntries: weights
                    )
                }
                
                // Evaluate achievements and trigger celebrations
                await evaluateAchievementsAndCelebrate()
                
            } catch {
                print("⚠️ DashboardViewModel: Failed to load goals: \(error)")
                // Don't fail the whole operation if goals fail
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        AuthenticationManager.shared.logout()
    }
    
    func addWeight(weight: Double, date: Date, notes: String?) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let request = AddWeightRequest(
            weight: weight,
            date: dateString,
            notes: notes?.isEmpty == false ? notes : nil
        )
        
        print("📝 DashboardViewModel: Adding weight \(weight) kg on \(dateString)")
        
        let _ = try await apiService.addWeight(request)
        
        print("✅ DashboardViewModel: Weight added successfully, refreshing data")
        
        // Refresh the weight data after adding
        await loadWeightData()
    }
    
    func updateWeight(id: Int, weight: Double, date: Date, notes: String?) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let request = AddWeightRequest(
            weight: weight,
            date: dateString,
            notes: notes?.isEmpty == false ? notes : nil
        )
        
        print("📝 DashboardViewModel: Updating weight \(id) to \(weight) kg on \(dateString)")
        
        let _ = try await apiService.updateWeight(id: id, request: request)
        
        print("✅ DashboardViewModel: Weight updated successfully, refreshing data")
        
        // Refresh the weight data after updating
        await loadWeightData()
    }
    
    func deleteWeight(id: Int) async throws {
        print("🗑️ DashboardViewModel: Deleting weight \(id)")
        
        try await apiService.deleteWeight(id: id)
        
        print("✅ DashboardViewModel: Weight deleted successfully, refreshing data")
        
        // Refresh the weight data after deleting
        await loadWeightData()
    }
    
    func createGoal(targetWeight: Double, targetDate: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(
            targetWeight: targetWeight,
            targetDate: dateString
        )
        
        print("🎯 DashboardViewModel: Creating goal for \(targetWeight) kg by \(dateString)")
        
        let _ = try await apiService.createGoal(request)
        
        print("✅ DashboardViewModel: Goal created successfully, refreshing data")
        
        // Refresh the data after creating goal
        await loadWeightData()
    }
    
    func updateGoal(id: Int, targetWeight: Double, targetDate: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(
            targetWeight: targetWeight,
            targetDate: dateString
        )
        
        print("🎯 DashboardViewModel: Updating goal \(id) to \(targetWeight) kg by \(dateString)")
        
        let _ = try await apiService.updateGoal(id: id, request: request)
        
        print("✅ DashboardViewModel: Goal updated successfully, refreshing data")
        
        // Refresh the data after updating goal
        await loadWeightData()
    }
    
    func deleteGoal(id: Int) async throws {
        print("🗑️ DashboardViewModel: Deleting goal \(id)")
        
        try await apiService.deleteGoal(id: id)
        
        print("✅ DashboardViewModel: Goal deleted successfully, refreshing data")
        
        // Refresh the data after deleting goal
        await loadWeightData()
    }
    
    // MARK: - Smart Goals Management
    
    /// Create a main goal and generate smart milestones
    func createMainGoalWithMilestones(targetWeight: Double, targetDate: Date) async throws {
        // First create the main goal
        let mainGoalResponse = try await createMainGoal(targetWeight: targetWeight, targetDate: targetDate)
        
        // Generate smart milestones
        let mainGoal = mainGoalResponse.data
        let smartMilestones = smartGoalEngine.generateShortTermGoals(
            from: mainGoal,
            currentWeight: currentWeight,
            weightEntries: weights
        )
        
        // Create the milestone goals
        let _ = try await apiService.createMultipleGoals(smartMilestones)
        
        print("✅ DashboardViewModel: Created main goal with \(smartMilestones.count) milestones")
        
        // Refresh data
        await loadWeightData()
    }
    
    /// Regenerate milestones based on current progress
    func regenerateMilestones() async throws {
        guard let mainGoal = goalHierarchy?.mainGoal else {
            throw NSError(domain: "DashboardViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No main goal found"])
        }
        
        // Delete existing milestones
        try await apiService.deleteChildGoals(parentId: mainGoal.id)
        
        // Generate new milestones based on current progress
        let adjustedGoals = smartGoalEngine.adjustGoalTimeline(
            goals: goals,
            currentWeight: currentWeight,
            weightEntries: weights
        )
        
        let newMilestones = adjustedGoals.filter { $0.type == .shortTerm }
        let _ = try await apiService.createMultipleGoals(newMilestones)
        
        print("✅ DashboardViewModel: Regenerated \(newMilestones.count) milestones")
        
        // Refresh data
        await loadWeightData()
    }
    
    /// Create maintenance goal when main goal is achieved
    func createMaintenanceGoal() async throws {
        guard let mainGoal = goalHierarchy?.mainGoal else {
            throw NSError(domain: "DashboardViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No main goal found"])
        }
        
        let shouldCreate = smartGoalEngine.shouldCreateMaintenanceGoal(
            currentWeight: currentWeight,
            mainGoal: mainGoal,
            weightEntries: weights
        )
        
        guard shouldCreate else {
            throw NSError(domain: "DashboardViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not ready for maintenance goal yet"])
        }
        
        let maintenanceGoal = smartGoalEngine.createMaintenanceGoal(from: mainGoal)
        let _ = try await apiService.createSmartGoal(maintenanceGoal)
        
        print("✅ DashboardViewModel: Created maintenance goal")
        
        // Refresh data
        await loadWeightData()
    }
    
    /// Get goal recommendations for user input
    func getGoalRecommendations(desiredWeight: Double, timeframe: TimeInterval) -> LegacyGoalRecommendation {
        return smartGoalEngine.getGoalRecommendations(
            currentWeight: currentWeight,
            desiredWeight: desiredWeight,
            timeframe: timeframe
        )
    }
    
    /// Get goal statistics
    func getGoalStatistics() -> GoalStatistics {
        return GoalStatistics(from: goals, currentWeight: currentWeight)
    }
    
    /// Check if milestones need adjustment based on progress
    func shouldAdjustMilestones() -> Bool {
        guard let prediction = progressPrediction else { return false }
        
        switch prediction.insight {
        case .aheadOfSchedule(let days) where days > 14:
            return true
        case .behindSchedule(let days) where days > 14:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    private func createMainGoal(targetWeight: Double, targetDate: Date) async throws -> CreateGoalResponse {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(
            targetWeight: targetWeight,
            targetDate: dateString,
            type: .main,
            isAutoGenerated: false
        )
        
        return try await apiService.createGoal(request)
    }
    
    // MARK: - Achievement Management
    
    /// Evaluate achievements and trigger celebrations for new unlocks
    private func evaluateAchievementsAndCelebrate() async {
        // Store previous achievements for comparison
        let previousAchievements = achievementSystem.userAchievements
        
        // Evaluate current achievements
        await achievementSystem.evaluateAchievements(
            currentWeight: currentWeight,
            weightEntries: weights,
            goals: goals
        )
        
        // Check for newly unlocked achievements
        let newAchievements = AchievementCriteriaEvaluator.getNewlyUnlockedAchievements(
            current: achievementSystem.userAchievements,
            previous: previousAchievements
        )
        
        // Trigger celebrations for new achievements
        if !newAchievements.isEmpty {
            celebrationManager.celebrateMultipleAchievements(newAchievements)
        }
        
        // Check for newly achieved goals
        let newlyAchievedGoals = goals.filter { goal in
            goal.isAchieved(currentWeight: currentWeight) &&
            !previouslyAchievedGoals.contains(goal.id)
        }
        
        // Trigger goal celebrations
        for goal in newlyAchievedGoals {
            celebrationManager.celebrateGoal(goal)
        }
        
        // Update previously achieved goals
        previouslyAchievedGoals = Set(goals.filter { $0.isAchieved(currentWeight: currentWeight) }.map { $0.id })
    }
    
    /// Force re-evaluation of achievements (for manual refresh)
    func refreshAchievements() async {
        await evaluateAchievementsAndCelebrate()
    }
    
    // MARK: - Achievement Navigation
    
    /// Get achievement by ID for navigation
    func getAchievement(by id: String) -> Achievement? {
        return achievementSystem.getAchievement(by: id)
    }
    
    /// Get achievements for a specific category
    func getAchievements(by category: AchievementCategory) -> [Achievement] {
        return achievementSystem.getAchievements(by: category)
    }
    
    /// Check if an achievement is unlocked
    func isAchievementUnlocked(_ id: String) -> Bool {
        return achievementSystem.isUnlocked(id)
    }
    
    /// Get achievement progress
    func getAchievementProgress(for id: String) -> AchievementProgress? {
        return achievementSystem.getProgress(for: id)
    }
    
    // MARK: - Private Properties
    
    private var previouslyAchievedGoals: Set<Int> = []
}