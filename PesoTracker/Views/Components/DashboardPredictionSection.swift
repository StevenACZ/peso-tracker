//
//  DashboardPredictionSection.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

struct DashboardPredictionSection: View {
    let currentWeight: Double
    let weightEntries: [WeightEntry]
    let mainGoal: Goal?
    let nextMilestone: Goal?
    let progressPrediction: ProgressPrediction?
    let showProgressPhotos: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header with progress button
            HStack {
                Text("📊 Smart Insights & Predictions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View Progress") {
                    showProgressPhotos()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            if mainGoal != nil {
                // Main goal progress
                mainGoalProgressCard
                
                // Next milestone
                if let milestone = nextMilestone {
                    nextMilestoneCard(milestone)
                }
                
                // Predictions
                if let prediction = progressPrediction {
                    predictionCard(prediction)
                } else {
                    noPredictionCard
                }
            } else {
                // No goal set
                noGoalCard
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
    
    // MARK: - Main Goal Progress Card
    
    private var mainGoalProgressCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🏆 Main Goal Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if let goal = mainGoal {
                    Text(goal.formattedTargetWeight)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            
            if let goal = mainGoal {
                let progress = goal.progressPercentage(
                    currentWeight: currentWeight,
                    startWeight: weightEntries.first?.weight ?? currentWeight
                )
                
                VStack(spacing: 4) {
                    ProgressView(value: progress / 100.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 8)
                    
                    HStack {
                        Text("\(String(format: "%.1f", progress))% Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let days = goal.daysRemaining {
                            Text("\(days) days left")
                                .font(.caption)
                                .foregroundColor(days < 0 ? .red : .secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Next Milestone Card
    
    private func nextMilestoneCard(_ milestone: Goal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🎯 Next Milestone")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(milestone.formattedTargetWeight)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            let progress = milestone.progressPercentage(
                currentWeight: currentWeight,
                startWeight: weightEntries.first?.weight ?? currentWeight
            )
            
            VStack(spacing: 4) {
                ProgressView(value: progress / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .frame(height: 6)
                
                HStack {
                    Text("\(String(format: "%.1f", currentWeight - milestone.targetWeight)) kg to go")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("By \(milestone.formattedTargetDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Prediction Card
    
    private func predictionCard(_ prediction: ProgressPrediction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔮 AI Predictions")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                // Average loss rate
                HStack {
                    Text("📈 Average Rate:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(prediction.formattedAverageWeightLoss)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Predicted completion
                if let predictedDate = prediction.formattedPredictedDate {
                    HStack {
                        Text("🎯 Predicted Goal:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(predictedDate)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                // Progress insight
                HStack {
                    Text("💡 Insight:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(prediction.insight.emoji)
                        Text(prediction.insight.displayText)
                            .fontWeight(.medium)
                    }
                    .font(.caption)
                    .foregroundColor(prediction.insight.color)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - No Prediction Card
    
    private var noPredictionCard: some View {
        VStack(spacing: 8) {
            Text("📊")
                .font(.title2)
            
            Text("Need more data for predictions")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("Log your weight for a few more days to see AI-powered insights and predictions.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - No Goal Card
    
    private var noGoalCard: some View {
        VStack(spacing: 12) {
            Text("🎯")
                .font(.system(size: 40))
            
            Text("Set your first goal!")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Create a goal to unlock smart insights, predictions, and achievement tracking.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}
