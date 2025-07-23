//
//  GoalHierarchyView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

struct GoalHierarchyView: View {
    let hierarchy: GoalHierarchy
    let currentWeight: Double
    let onEditGoal: (Goal) -> Void
    let onDeleteGoal: (Goal) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Goals")
                .font(.headline)
            
            // Main Goal
            if let mainGoal = hierarchy.mainGoal {
                GoalCardView(
                    goal: mainGoal,
                    currentWeight: currentWeight,
                    onEdit: { onEditGoal(mainGoal) },
                    onDelete: { onDeleteGoal(mainGoal) }
                )
            }
            
            // Short-term Goals (Milestones)
            if !hierarchy.shortTermGoals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Milestones")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(hierarchy.shortTermGoals) { goal in
                        GoalCardView(
                            goal: goal,
                            currentWeight: currentWeight,
                            isCompact: true,
                            onEdit: { onEditGoal(goal) },
                            onDelete: { onDeleteGoal(goal) }
                        )
                    }
                }
            }
            
            // Maintenance Goals
            if !hierarchy.maintenanceGoals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Maintenance")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(hierarchy.maintenanceGoals) { goal in
                        GoalCardView(
                            goal: goal,
                            currentWeight: currentWeight,
                            onEdit: { onEditGoal(goal) },
                            onDelete: { onDeleteGoal(goal) }
                        )
                    }
                }
            }
        }
    }
}

struct GoalCardView: View {
    let goal: Goal
    let currentWeight: Double
    let isCompact: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    init(
        goal: Goal,
        currentWeight: Double,
        isCompact: Bool = false,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.goal = goal
        self.currentWeight = currentWeight
        self.isCompact = isCompact
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    private var isAchieved: Bool {
        goal.isAchieved(currentWeight: currentWeight)
    }
    
    private var progressPercentage: Double {
        // Simplified progress calculation
        guard currentWeight > goal.targetWeight else { return 100.0 }
        return max(0.0, min(100.0, (1.0 - (currentWeight - goal.targetWeight) / currentWeight) * 100.0))
    }
    
    var body: some View {
        HStack {
            // Goal type icon
            Text(goal.type.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                // Goal title
                Text(goal.displayTitle)
                    .fontWeight(.medium)
                    .font(isCompact ? .subheadline : .headline)
                
                // Target date
                HStack {
                    Text("By: \(goal.formattedTargetDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let days = goal.daysRemaining {
                        Text("(\(days) days)")
                            .font(.caption)
                            .foregroundColor(days < 0 ? .red : .secondary)
                    }
                }
                
                // Progress bar (only for non-compact view)
                if !isCompact && !isAchieved {
                    ProgressView(value: progressPercentage / 100.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 4)
                }
            }
            
            Spacer()
            
            // Goal status
            if isAchieved {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    if !isCompact {
                        Text("Achieved!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
            } else if goal.isOverdue {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    if !isCompact {
                        Text("Overdue")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                Button("Edit") {
                    onEdit()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                if !goal.isAutoGenerated {
                    Button("Delete") {
                        onDelete()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(backgroundColorForGoal)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColorForGoal, lineWidth: 2)
        )
    }
    
    private var backgroundColorForGoal: Color {
        if isAchieved {
            return Color.green.opacity(0.1)
        } else if goal.isOverdue {
            return Color.red.opacity(0.1)
        } else {
            return Color(NSColor.controlBackgroundColor)
        }
    }
    
    private var borderColorForGoal: Color {
        if isAchieved {
            return Color.green
        } else if goal.isOverdue {
            return Color.red
        } else {
            return Color(NSColor.separatorColor)
        }
    }
}
