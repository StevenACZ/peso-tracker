//
//  GoalPreviewView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

struct GoalPreviewView: View {
    let targetWeight: Double
    let targetDate: Date
    let currentWeight: Double
    let weightEntries: [WeightEntry]
    
    @Environment(\.dismiss) private var dismiss
    @State private var smartGoals: [SmartGoal] = []
    @State private var recommendation: LegacyGoalRecommendation?
    
    private let smartGoalEngine = SmartGoalEngine()
    
    var body: some View {
        let headerView = HStack {
            Text("Goal Preview")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
        }
        .padding()
        
        return VStack(spacing: 20) {
            // Header
            headerView
            
            ScrollView {
                VStack(spacing: 20) {
                    // Main goal preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🏆 Main Goal")
                            .font(.headline)
                        
                        GoalPreviewCard(
                            title: "Target: \(String(format: "%.1f", targetWeight)) kg",
                            subtitle: "By: \(formattedDate(targetDate))",
                            isMainGoal: true
                        )
                    }
                    
                    // Recommendation
                    if let rec = recommendation {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: rec.type == .optimal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(rec.type == .optimal ? .green : .orange)
                                
                                Text("Recommendation")
                                    .font(.headline)
                            }
                            
                            Text(rec.recommendationText)
                                .font(.subheadline)
                                .foregroundColor(rec.type == .optimal ? .green : .orange)
                            
                            if rec.type != .optimal {
                                Text("Suggested timeframe: \(rec.formattedTimeframe)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Smart milestones preview
                    if !smartGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🎯 Smart Milestones")
                                .font(.headline)
                            
                            Text("These milestones will be automatically created to help you stay motivated:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(Array(smartGoals.enumerated()), id: \.offset) { index, goal in
                                GoalPreviewCard(
                                    title: "Milestone #\(index + 1): \(String(format: "%.1f", goal.targetWeight)) kg",
                                    subtitle: "By: \(goal.formattedTargetDate)",
                                    isMainGoal: false
                                )
                            }
                        }
                    }
                    
                    // Progress insights
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📊 Progress Insights")
                            .font(.headline)
                        
                        if weightEntries.count >= 3 {
                            let prediction = generatePrediction()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Based on your recent progress:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("• Average loss rate: \(prediction.formattedAverageWeightLoss)")
                                    .font(.caption)
                                
                                if let predictedDate = prediction.formattedPredictedDate {
                                    Text("• Predicted completion: \(predictedDate)")
                                        .font(.caption)
                                }
                                
                                Text("• \(prediction.insight.emoji) \(prediction.insight.displayText)")
                                    .font(.caption)
                                    .foregroundColor(prediction.insight.color)
                            }
                        } else {
                            Text("Add more weight entries to see personalized predictions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            generateSmartGoals()
            generateRecommendation()
        }
    }
    
    private func generateSmartGoals() {
        // Create a temporary main goal for preview using a mock JSON approach
        let goalData: [String: Any] = [
            "id": 0,
            "user_id": 0,
            "target_weight": "\(targetWeight)",
            "target_date": formattedDateForAPI(targetDate),
            "type": "main",
            "is_auto_generated": false,
            "parent_goal_id": NSNull(),
            "milestone_number": NSNull(),
            "created_at": NSNull(),
            "updated_at": NSNull()
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: goalData),
              let tempMainGoal = try? JSONDecoder().decode(Goal.self, from: jsonData) else {
            smartGoals = []
            return
        }
        
        smartGoals = smartGoalEngine.generateShortTermGoals(
            from: tempMainGoal,
            currentWeight: currentWeight,
            weightEntries: weightEntries
        )
    }
    
    private func generateRecommendation() {
        let timeframe = targetDate.timeIntervalSinceNow
        recommendation = smartGoalEngine.getGoalRecommendations(
            currentWeight: currentWeight,
            desiredWeight: targetWeight,
            timeframe: timeframe
        )
    }
    
    private func generatePrediction() -> ProgressPrediction {
        let predictor = ProgressPredictor()
        return predictor.generatePrediction(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            targetDate: targetDate,
            weightEntries: weightEntries
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct GoalPreviewCard: View {
    let title: String
    let subtitle: String
    let isMainGoal: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(isMainGoal ? .bold : .medium)
                    .font(isMainGoal ? .headline : .subheadline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isMainGoal {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(isMainGoal ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isMainGoal ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
