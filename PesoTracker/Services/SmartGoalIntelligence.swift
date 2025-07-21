//
//  SmartGoalIntelligence.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Goal Recommendation Types

enum RecommendationPriority: Int, CaseIterable {
    case low = 3
    case medium = 2
    case high = 1
    
    var displayName: String {
        switch self {
        case .low: return "Low Priority"
        case .medium: return "Medium Priority"
        case .high: return "High Priority"
        }
    }
}

enum RecommendationType: String, CaseIterable {
    case progressBased = "progress_based"
    case consistencyBased = "consistency_based"
    case gapBased = "gap_based"
    case maintenanceBased = "maintenance_based"
    
    var displayName: String {
        switch self {
        case .progressBased: return "Progress-Based"
        case .consistencyBased: return "Consistency-Based"
        case .gapBased: return "Goal Gap"
        case .maintenanceBased: return "Maintenance"
        }
    }
}

struct GoalRecommendation: Identifiable {
    let id: UUID
    let type: RecommendationType
    let priority: RecommendationPriority
    let title: String
    let description: String
    let suggestedGoal: Goal?
    let reasoning: String
    let confidence: Double // 0.0 to 1.0
    let createdAt: Date
    
    init(type: RecommendationType, priority: RecommendationPriority, title: String, description: String, suggestedGoal: Goal? = nil, reasoning: String, confidence: Double = 0.8) {
        self.id = UUID()
        self.type = type
        self.priority = priority
        self.title = title
        self.description = description
        self.suggestedGoal = suggestedGoal
        self.reasoning = reasoning
        self.confidence = confidence
        self.createdAt = Date()
    }
}

// MARK: - Smart Goal Intelligence Service

class SmartGoalIntelligence {
    
    private let progressPredictor = ProgressPredictor()
    private let smartGoalEngine = SmartGoalEngine()
    
    // MARK: - Automatic Goal Adjustment
    
    /// Analyze user progress and suggest goal adjustments
    func analyzeAndSuggestAdjustments(
        goals: [Goal],
        currentWeight: Double,
        weightEntries: [WeightEntry]
    ) -> [GoalAdjustmentSuggestion] {
        
        var suggestions: [GoalAdjustmentSuggestion] = []
        
        guard let mainGoal = goals.first(where: { $0.type == .main }) else {
            return suggestions
        }
        
        // Analyze main goal progress
        if let mainGoalSuggestion = analyzeMainGoal(
            mainGoal: mainGoal,
            currentWeight: currentWeight,
            weightEntries: weightEntries
        ) {
            suggestions.append(mainGoalSuggestion)
        }
        
        // Analyze milestone goals
        let milestoneGoals = goals.filter { $0.type == .shortTerm }
        for milestone in milestoneGoals {
            if let milestoneSuggestion = analyzeMilestone(
                milestone: milestone,
                currentWeight: currentWeight,
                weightEntries: weightEntries
            ) {
                suggestions.append(milestoneSuggestion)
            }
        }
        
        // Check if maintenance goal should be created
        if shouldSuggestMaintenanceGoal(
            mainGoal: mainGoal,
            currentWeight: currentWeight,
            weightEntries: weightEntries
        ) {
            suggestions.append(createMaintenanceGoalSuggestion(mainGoal: mainGoal))
        }
        
        return suggestions
    }
    
    /// Automatically adjust goal timelines based on progress
    func autoAdjustGoalTimelines(
        goals: [Goal],
        currentWeight: Double,
        weightEntries: [WeightEntry]
    ) -> [Goal] {
        
        guard let mainGoal = goals.first(where: { $0.type == .main }) else {
            return goals
        }
        
        // Get progress prediction
        guard let targetDate = parseDate(mainGoal.targetDate) else {
            return goals
        }
        
        let prediction = progressPredictor.generatePrediction(
            currentWeight: currentWeight,
            targetWeight: mainGoal.targetWeight,
            targetDate: targetDate,
            weightEntries: weightEntries
        )
        
        // Determine if adjustment is needed
        let needsAdjustment = shouldAdjustTimeline(prediction: prediction)
        
        if needsAdjustment {
            return adjustGoalTimelines(
                goals: goals,
                prediction: prediction,
                currentWeight: currentWeight
            )
        }
        
        return goals
    }
    
    // MARK: - Goal Recommendations
    
    /// Generate personalized goal recommendations
    func generateGoalRecommendations(
        currentWeight: Double,
        weightEntries: [WeightEntry],
        existingGoals: [Goal]
    ) -> [GoalRecommendation] {
        
        var recommendations: [GoalRecommendation] = []
        
        // Analyze user patterns
        let userPattern = analyzeUserPattern(weightEntries: weightEntries)
        
        // Recommend based on progress rate
        if let progressRecommendation = recommendBasedOnProgress(
            userPattern: userPattern,
            currentWeight: currentWeight,
            existingGoals: existingGoals
        ) {
            recommendations.append(progressRecommendation)
        }
        
        // Recommend based on consistency
        if let consistencyRecommendation = recommendBasedOnConsistency(
            userPattern: userPattern,
            existingGoals: existingGoals
        ) {
            recommendations.append(consistencyRecommendation)
        }
        
        // Recommend based on goal gaps
        let gapRecommendations = recommendBasedOnGoalGaps(
            currentWeight: currentWeight,
            existingGoals: existingGoals
        )
        recommendations.append(contentsOf: gapRecommendations)
        
        return recommendations.sorted { (rec1: GoalRecommendation, rec2: GoalRecommendation) -> Bool in
            return rec1.priority.rawValue < rec2.priority.rawValue
        }
    }
    
    /// Detect and resolve goal conflicts
    func detectGoalConflicts(goals: [Goal]) -> [GoalConflict] {
        var conflicts: [GoalConflict] = []
        
        // Check for overlapping timelines
        conflicts.append(contentsOf: detectTimelineConflicts(goals: goals))
        
        // Check for unrealistic goal combinations
        conflicts.append(contentsOf: detectUnrealisticCombinations(goals: goals))
        
        // Check for duplicate goals
        conflicts.append(contentsOf: detectDuplicateGoals(goals: goals))
        
        return conflicts
    }
    
    // MARK: - Private Analysis Methods
    
    private func analyzeMainGoal(
        mainGoal: Goal,
        currentWeight: Double,
        weightEntries: [WeightEntry]
    ) -> GoalAdjustmentSuggestion? {
        
        guard let targetDate = parseDate(mainGoal.targetDate) else { return nil }
        
        let prediction = progressPredictor.generatePrediction(
            currentWeight: currentWeight,
            targetWeight: mainGoal.targetWeight,
            targetDate: targetDate,
            weightEntries: weightEntries
        )
        
        switch prediction.insight {
        case .aheadOfSchedule(let days) where days > 21:
            return GoalAdjustmentSuggestion(
                goalId: mainGoal.id,
                type: .accelerateTimeline,
                priority: .medium,
                title: "You're ahead of schedule!",
                description: "You're \(days) days ahead. Consider setting a more ambitious target date.",
                suggestedAction: .adjustTargetDate(Calendar.current.date(byAdding: .day, value: -days/2, to: targetDate) ?? targetDate)
            )
            
        case .behindSchedule(let days) where days > 14:
            return GoalAdjustmentSuggestion(
                goalId: mainGoal.id,
                type: .extendTimeline,
                priority: .high,
                title: "Timeline adjustment needed",
                description: "You're \(days) days behind. Consider extending your deadline for a more realistic goal.",
                suggestedAction: .adjustTargetDate(Calendar.current.date(byAdding: .day, value: days/2, to: targetDate) ?? targetDate)
            )
            
        default:
            return nil
        }
    }
    
    private func analyzeMilestone(
        milestone: Goal,
        currentWeight: Double,
        weightEntries: [WeightEntry]
    ) -> GoalAdjustmentSuggestion? {
        
        // Check if milestone is overdue
        if milestone.isOverdue && !milestone.isAchieved(currentWeight: currentWeight) {
            return GoalAdjustmentSuggestion(
                goalId: milestone.id,
                type: .adjustMilestone,
                priority: .medium,
                title: "Milestone overdue",
                description: "This milestone is overdue. Consider adjusting it or focusing on the next one.",
                suggestedAction: .skipMilestone
            )
        }
        
        return nil
    }
    
    private func shouldSuggestMaintenanceGoal(
        mainGoal: Goal,
        currentWeight: Double,
        weightEntries: [WeightEntry]
    ) -> Bool {
        
        return smartGoalEngine.shouldCreateMaintenanceGoal(
            currentWeight: currentWeight,
            mainGoal: mainGoal,
            weightEntries: weightEntries
        )
    }
    
    private func createMaintenanceGoalSuggestion(mainGoal: Goal) -> GoalAdjustmentSuggestion {
        return GoalAdjustmentSuggestion(
            goalId: 0, // New goal
            type: .createMaintenanceGoal,
            priority: .high,
            title: "Time for maintenance!",
            description: "You've achieved your main goal. Create a maintenance goal to keep your progress.",
            suggestedAction: .createMaintenanceGoal(mainGoal.targetWeight)
        )
    }
    
    private func shouldAdjustTimeline(prediction: ProgressPrediction) -> Bool {
        switch prediction.insight {
        case .aheadOfSchedule(let days) where days > 21:
            return true
        case .behindSchedule(let days) where days > 14:
            return true
        default:
            return false
        }
    }
    
    private func adjustGoalTimelines(
        goals: [Goal],
        prediction: ProgressPrediction,
        currentWeight: Double
    ) -> [Goal] {
        
        // This would return adjusted goals with new timelines
        // For now, return original goals (implementation would require goal modification)
        return goals
    }
    
    // MARK: - User Pattern Analysis
    
    private func analyzeUserPattern(weightEntries: [WeightEntry]) -> UserPattern {
        let sortedEntries = weightEntries.sorted { (entry1: WeightEntry, entry2: WeightEntry) -> Bool in
            return entry1.date < entry2.date
        }
        
        // Calculate consistency
        let consistency = calculateConsistency(entries: sortedEntries)
        
        // Calculate average loss rate
        let averageLossRate = calculateAverageLossRate(entries: sortedEntries)
        
        // Detect patterns
        let trendPattern = detectTrendPattern(entries: sortedEntries)
        
        return UserPattern(
            consistency: consistency,
            averageLossRate: averageLossRate,
            trendPattern: trendPattern,
            totalEntries: sortedEntries.count,
            timeSpan: getTimeSpan(entries: sortedEntries)
        )
    }
    
    private func calculateConsistency(entries: [WeightEntry]) -> Double {
        // Simplified consistency calculation
        let totalDays = getTimeSpan(entries: entries) / (24 * 60 * 60)
        return totalDays > 0 ? Double(entries.count) / totalDays : 0.0
    }
    
    private func calculateAverageLossRate(entries: [WeightEntry]) -> Double {
        return progressPredictor.calculateAverageWeightLoss(from: entries)
    }
    
    private func detectTrendPattern(entries: [WeightEntry]) -> TrendPattern {
        guard entries.count >= 3 else { return .insufficient }
        
        let recentEntries = Array(entries.suffix(7)) // Last 7 entries
        let weights = recentEntries.map { $0.weight }
        
        let isDecreasing = weights.enumerated().allSatisfy { index, weight in
            index == 0 || weight <= weights[index - 1]
        }
        
        let isIncreasing = weights.enumerated().allSatisfy { index, weight in
            index == 0 || weight >= weights[index - 1]
        }
        
        if isDecreasing {
            return .consistentDecrease
        } else if isIncreasing {
            return .consistentIncrease
        } else {
            return .fluctuating
        }
    }
    
    private func getTimeSpan(entries: [WeightEntry]) -> TimeInterval {
        guard let first = entries.first, let last = entries.last else { return 0 }
        
        let firstDate = parseDate(first.date) ?? Date()
        let lastDate = parseDate(last.date) ?? Date()
        
        return lastDate.timeIntervalSince(firstDate)
    }
    
    // MARK: - Recommendation Methods
    
    private func recommendBasedOnProgress(
        userPattern: UserPattern,
        currentWeight: Double,
        existingGoals: [Goal]
    ) -> GoalRecommendation? {
        
        if userPattern.averageLossRate > 1.0 {
            let targetWeight = currentWeight - 5.0
            
            return GoalRecommendation(
                type: RecommendationType.progressBased,
                priority: RecommendationPriority.high,
                title: "Accelerated Progress Goal",
                description: "Based on your excellent progress rate of \(String(format: "%.1f", userPattern.averageLossRate))kg/week, you could achieve more ambitious goals. Suggested target: \(String(format: "%.1f", targetWeight))kg in 60 days.",
                suggestedGoal: nil as Goal?, // Will be created when user accepts recommendation
                reasoning: "Your current loss rate is above average, suggesting you can handle more challenging targets.",
                confidence: 0.9
            )
        }
        
        return nil
    }
    
    private func recommendBasedOnConsistency(
        userPattern: UserPattern,
        existingGoals: [Goal]
    ) -> GoalRecommendation? {
        
        if userPattern.consistency < 0.5 {
            // Use existing goal target or a reasonable default
            let targetWeight = existingGoals.first?.targetWeight ?? 70.0
            
            return GoalRecommendation(
                type: RecommendationType.consistencyBased,
                priority: RecommendationPriority.medium,
                title: "Consistency-Focused Goal",
                description: "Your tracking consistency is \(String(format: "%.0f", userPattern.consistency * 100))%. A longer-term goal might help build better habits. Suggested target: \(String(format: "%.1f", targetWeight))kg in 90 days.",
                suggestedGoal: nil as Goal?, // Will be created when user accepts recommendation
                reasoning: "Lower consistency suggests you might benefit from more achievable, longer-term goals.",
                confidence: 0.7
            )
        }
        
        return nil
    }
    
    private func recommendBasedOnGoalGaps(
        currentWeight: Double,
        existingGoals: [Goal]
    ) -> [GoalRecommendation] {
        
        var recommendations: [GoalRecommendation] = []
        
        // Check if user has no main goal
        if !existingGoals.contains(where: { $0.type == .main }) {
            let targetWeight = currentWeight - 5.0
            
            recommendations.append(GoalRecommendation(
                type: RecommendationType.gapBased,
                priority: RecommendationPriority.high,
                title: "Create Main Goal",
                description: "You don't have a main long-term goal set. Setting one will help guide your progress. Suggested target: \(String(format: "%.1f", targetWeight))kg in 90 days.",
                suggestedGoal: nil as Goal?, // Will be created when user accepts recommendation
                reasoning: "Having a main goal provides direction and motivation for your weight loss journey.",
                confidence: 0.95
            ))
        }
        
        // Check for missing short-term milestones
        let hasShortTermGoals = existingGoals.contains(where: { $0.type == .shortTerm })
        if !hasShortTermGoals && existingGoals.contains(where: { $0.type == .main }) {
            let targetWeight = currentWeight - 2.0
            
            recommendations.append(GoalRecommendation(
                type: RecommendationType.gapBased,
                priority: RecommendationPriority.medium,
                title: "Add Milestone Goal",
                description: "Break down your main goal into smaller, achievable milestones. Suggested target: \(String(format: "%.1f", targetWeight))kg in 30 days.",
                suggestedGoal: nil as Goal?, // Will be created when user accepts recommendation
                reasoning: "Short-term milestones help maintain motivation and track progress more effectively.",
                confidence: 0.8
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Conflict Detection
    
    private func detectTimelineConflicts(goals: [Goal]) -> [GoalConflict] {
        var conflicts: [GoalConflict] = []
        
        for i in 0..<goals.count {
            for j in (i+1)..<goals.count {
                let goal1 = goals[i]
                let goal2 = goals[j]
                
                if hasTimelineConflict(goal1: goal1, goal2: goal2) {
                    conflicts.append(GoalConflict(
                        type: .timelineOverlap,
                        affectedGoals: [goal1.id, goal2.id],
                        description: "Goals have overlapping timelines that may be unrealistic",
                        severity: .medium
                    ))
                }
            }
        }
        
        return conflicts
    }
    
    private func detectUnrealisticCombinations(goals: [Goal]) -> [GoalConflict] {
        // Implementation for detecting unrealistic goal combinations
        return []
    }
    
    private func detectDuplicateGoals(goals: [Goal]) -> [GoalConflict] {
        var conflicts: [GoalConflict] = []
        var seenTargets: [Double: Int] = [:]
        
        for goal in goals {
            if let existingGoalId = seenTargets[goal.targetWeight] {
                conflicts.append(GoalConflict(
                    type: .duplicateTarget,
                    affectedGoals: [existingGoalId, goal.id],
                    description: "Multiple goals with the same target weight",
                    severity: .low
                ))
            } else {
                seenTargets[goal.targetWeight] = goal.id
            }
        }
        
        return conflicts
    }
    
    private func hasTimelineConflict(goal1: Goal, goal2: Goal) -> Bool {
        // Simplified conflict detection
        return goal1.targetWeight == goal2.targetWeight && goal1.targetDate == goal2.targetDate
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
}

// MARK: - Supporting Data Structures

struct UserPattern {
    let consistency: Double // 0.0 to 1.0
    let averageLossRate: Double // kg per week
    let trendPattern: TrendPattern
    let totalEntries: Int
    let timeSpan: TimeInterval // in seconds
}

enum TrendPattern {
    case consistentDecrease
    case consistentIncrease
    case fluctuating
    case insufficient
}

struct GoalAdjustmentSuggestion {
    let goalId: Int
    let type: AdjustmentType
    let priority: Priority
    let title: String
    let description: String
    let suggestedAction: SuggestedAction
    
    enum AdjustmentType {
        case accelerateTimeline
        case extendTimeline
        case adjustMilestone
        case createMaintenanceGoal
    }
    
    enum Priority: Int {
        case high = 1
        case medium = 2
        case low = 3
    }
    
    enum SuggestedAction {
        case adjustTargetDate(Date)
        case adjustTargetWeight(Double)
        case skipMilestone
        case createMaintenanceGoal(Double)
    }
}

struct GoalConflict {
    let type: ConflictType
    let affectedGoals: [Int]
    let description: String
    let severity: Severity
    
    enum ConflictType {
        case timelineOverlap
        case unrealisticCombination
        case duplicateTarget
    }
    
    enum Severity {
        case high
        case medium
        case low
    }
}