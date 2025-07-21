//
//  GoalHierarchyManager.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Goal Hierarchy Manager

class GoalHierarchyManager {
    
    /// Organize goals into a hierarchy structure
    static func createHierarchy(from goals: [Goal]) -> GoalHierarchy {
        return GoalHierarchy(from: goals)
    }
    
    /// Find the next milestone goal that should be active
    static func getNextMilestone(from goals: [Goal], currentWeight: Double) -> Goal? {
        let shortTermGoals = goals.filter { $0.type == .shortTerm }
            .sorted { ($0.milestoneNumber ?? 0) < ($1.milestoneNumber ?? 0) }
        
        // Find the first unachieved milestone
        return shortTermGoals.first { !$0.isAchieved(currentWeight: currentWeight) }
    }
    
    /// Get all achieved goals
    static func getAchievedGoals(from goals: [Goal], currentWeight: Double) -> [Goal] {
        return goals.filter { $0.isAchieved(currentWeight: currentWeight) }
    }
    
    /// Get all active (unachieved) goals
    static func getActiveGoals(from goals: [Goal], currentWeight: Double) -> [Goal] {
        return goals.filter { !$0.isAchieved(currentWeight: currentWeight) }
    }
    
    /// Find goals by parent ID
    static func getChildGoals(of parentId: Int, from goals: [Goal]) -> [Goal] {
        return goals.filter { $0.parentGoalId == parentId }
    }
    
    /// Check if a main goal has any associated milestones
    static func hasAssociatedMilestones(mainGoal: Goal, in goals: [Goal]) -> Bool {
        return goals.contains { $0.parentGoalId == mainGoal.id }
    }
    
    /// Get the main goal for a given milestone
    static func getMainGoal(for milestone: Goal, from goals: [Goal]) -> Goal? {
        guard let parentId = milestone.parentGoalId else { return nil }
        return goals.first { $0.id == parentId }
    }
    
    /// Sort goals by priority (main -> short-term -> maintenance)
    static func sortByPriority(_ goals: [Goal]) -> [Goal] {
        return goals.sorted { goal1, goal2 in
            if goal1.type.priority != goal2.type.priority {
                return goal1.type.priority < goal2.type.priority
            }
            
            // Within same type, sort by milestone number or date
            if goal1.type == .shortTerm && goal2.type == .shortTerm {
                return (goal1.milestoneNumber ?? 0) < (goal2.milestoneNumber ?? 0)
            }
            
            return goal1.targetDate < goal2.targetDate
        }
    }
    
    /// Calculate overall progress towards main goal
    static func calculateMainGoalProgress(
        mainGoal: Goal,
        currentWeight: Double,
        startWeight: Double
    ) -> GoalProgress {
        let progressPercentage = mainGoal.progressPercentage(
            currentWeight: currentWeight,
            startWeight: startWeight
        )
        
        let isAchieved = mainGoal.isAchieved(currentWeight: currentWeight)
        let daysRemaining = mainGoal.daysRemaining ?? 0
        
        return GoalProgress(
            goalId: mainGoal.id,
            progressPercentage: progressPercentage,
            isAchieved: isAchieved,
            daysRemaining: daysRemaining,
            isOverdue: mainGoal.isOverdue
        )
    }
    
    /// Validate goal hierarchy consistency
    static func validateHierarchy(_ goals: [Goal]) -> [GoalValidationError] {
        var errors: [GoalValidationError] = []
        
        let mainGoals = goals.filter { $0.type == .main }
        if mainGoals.count > 1 {
            errors.append(.multipleMainGoals)
        }
        
        // Check for orphaned milestones
        let milestones = goals.filter { $0.type == .shortTerm }
        for milestone in milestones {
            if let parentId = milestone.parentGoalId {
                let parentExists = goals.contains { $0.id == parentId }
                if !parentExists {
                    errors.append(.orphanedMilestone(milestoneId: milestone.id))
                }
            }
        }
        
        return errors
    }
}

// MARK: - Supporting Data Structures

struct GoalProgress {
    let goalId: Int
    let progressPercentage: Double
    let isAchieved: Bool
    let daysRemaining: Int
    let isOverdue: Bool
    
    var statusText: String {
        if isAchieved {
            return "🎉 Achieved!"
        } else if isOverdue {
            return "⏰ Overdue"
        } else if daysRemaining <= 7 {
            return "🔥 \(daysRemaining) days left"
        } else {
            return "📅 \(daysRemaining) days remaining"
        }
    }
    
    var progressColor: String {
        if isAchieved {
            return "green"
        } else if isOverdue {
            return "red"
        } else if progressPercentage >= 80 {
            return "green"
        } else if progressPercentage >= 50 {
            return "orange"
        } else {
            return "blue"
        }
    }
}

enum GoalValidationError: Error {
    case multipleMainGoals
    case orphanedMilestone(milestoneId: Int)
    case invalidMilestoneSequence
    case conflictingDates
    
    var description: String {
        switch self {
        case .multipleMainGoals:
            return "Multiple main goals detected. Only one main goal is allowed."
        case .orphanedMilestone(let id):
            return "Milestone with ID \(id) has no associated main goal."
        case .invalidMilestoneSequence:
            return "Milestone sequence is invalid or has gaps."
        case .conflictingDates:
            return "Goal dates are conflicting or illogical."
        }
    }
}

// MARK: - Goal Statistics

struct GoalStatistics {
    let totalGoals: Int
    let achievedGoals: Int
    let activeGoals: Int
    let overdue: Int
    let averageCompletionTime: TimeInterval?
    let successRate: Double
    
    var completionPercentage: Double {
        guard totalGoals > 0 else { return 0.0 }
        return (Double(achievedGoals) / Double(totalGoals)) * 100.0
    }
    
    init(from goals: [Goal], currentWeight: Double) {
        self.totalGoals = goals.count
        
        let achieved = goals.filter { $0.isAchieved(currentWeight: currentWeight) }
        self.achievedGoals = achieved.count
        
        self.activeGoals = goals.count - achieved.count
        self.overdue = goals.filter { $0.isOverdue }.count
        
        // Calculate average completion time (simplified)
        self.averageCompletionTime = nil // TODO: Implement when we have achievement dates
        
        self.successRate = totalGoals > 0 ? (Double(achievedGoals) / Double(totalGoals)) * 100.0 : 0.0
    }
}