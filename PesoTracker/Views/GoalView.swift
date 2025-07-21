//
//  GoalView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct GoalView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var targetWeight: String = ""
    @State private var targetDate = Date()
    @State private var selectedGoalType: GoalType = .main
    @State private var generateMilestones = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var goalRecommendation: LegacyGoalRecommendation?
    
    @State private var selectedGoalToEdit: Goal?
    @State private var showingGoalPreview = false
    
    private var isEditing: Bool {
        selectedGoalToEdit != nil
    }
    
    private var timeframeInDays: Int {
        Int(targetDate.timeIntervalSinceNow / (24 * 60 * 60))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Text(isEditing ? "Update Goal" : "Create New Goal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                Divider()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .background(Color(NSColor.windowBackgroundColor))
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Goal type selection (only for new goals)
                    if !isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goal Type")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Goal Type", selection: $selectedGoalType) {
                                ForEach(GoalType.allCases, id: \.self) { type in
                                    HStack {
                                        Text(type.emoji)
                                        Text(type.displayName)
                                    }
                                    .tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedGoalType) {
                                updateGoalRecommendation()
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                    }
                    
                    // Target weight input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Weight (kg)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            TextField("Enter target weight", text: $targetWeight)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 200)
                                .onChange(of: targetWeight) {
                                    updateGoalRecommendation()
                                }
                            
                            if viewModel.currentWeight > 0 {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Current: \(String(format: "%.1f", viewModel.currentWeight)) kg")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if let weight = Double(targetWeight), weight > 0 {
                                        let difference = viewModel.currentWeight - weight
                                        Text(difference > 0 ? "Goal: -\(String(format: "%.1f", difference)) kg" : "Goal: +\(String(format: "%.1f", abs(difference))) kg")
                                            .font(.caption)
                                            .foregroundColor(difference > 0 ? .green : .blue)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Target date picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Date")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            DatePicker("Select target date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .onChange(of: targetDate) {
                                    updateGoalRecommendation()
                                }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(timeframeInDays) days")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Text("from now")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Smart milestones option (only for main goals)
                    if selectedGoalType == .main && !isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Toggle("Generate Smart Milestones", isOn: $generateMilestones)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            if generateMilestones {
                                HStack {
                                    Image(systemName: "lightbulb")
                                        .foregroundColor(.orange)
                                    
                                    Text("Automatic milestones will be created every 2-5kg to help you stay motivated and track progress")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                    }
                    
                    // Goal recommendation
                    if let recommendation = goalRecommendation, !isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: recommendation.type == .optimal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(recommendation.type == .optimal ? .green : .orange)
                                    .font(.title3)
                                
                                Text("AI Recommendation")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Text(recommendation.recommendationText)
                                .font(.subheadline)
                                .foregroundColor(recommendation.type == .optimal ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if recommendation.type != .optimal {
                                    Text("• Suggested timeframe: \(recommendation.formattedTimeframe)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("• Expected milestones: \(recommendation.milestoneCount)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("• Weekly rate: \(String(format: "%.1f", recommendation.expectedWeeklyRate)) kg/week")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(recommendation.type == .optimal ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(recommendation.type == .optimal ? Color.green : Color.orange, lineWidth: 1)
                        )
                    }
                    
                    // Your Goals section
                    if let hierarchy = viewModel.goalHierarchy {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Goals")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            GoalHierarchyView(
                                hierarchy: hierarchy,
                                currentWeight: viewModel.currentWeight,
                                onEditGoal: { goal in
                                    selectedGoalToEdit = goal
                                    targetWeight = String(goal.targetWeight)
                                    selectedGoalType = goal.type
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    if let date = dateFormatter.date(from: goal.targetDate) {
                                        targetDate = date
                                    }
                                },
                                onDeleteGoal: { goal in
                                    Task {
                                        await deleteGoal(goal)
                                    }
                                }
                            )
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            
                            Text(error)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(24)
            }
            
            // Bottom action bar
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 16) {
                    if !isEditing && selectedGoalType == .main && generateMilestones {
                        Button("Preview Milestones") {
                            showingGoalPreview = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(targetWeight.isEmpty)
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Button(isEditing ? "Update Goal" : "Create Goal") {
                        Task {
                            await saveGoal()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(targetWeight.isEmpty || isLoading)
                }
                .padding(24)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showingGoalPreview) {
            GoalPreviewView(
                targetWeight: Double(targetWeight) ?? 0,
                targetDate: targetDate,
                currentWeight: viewModel.currentWeight,
                weightEntries: viewModel.weights
            )
        }
        .onAppear {
            // Start with a clean form for creating new goals
            if selectedGoalToEdit == nil {
                targetWeight = ""
                targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // Default to 30 days from now
                
                // Set default goal type based on existing goals
                if viewModel.goalHierarchy?.mainGoal == nil {
                    selectedGoalType = .main
                } else {
                    selectedGoalType = .shortTerm
                    generateMilestones = false
                }
            }
            
            updateGoalRecommendation()
        }
    }
    
    private func saveGoal() async {
        guard let weightValue = Double(targetWeight), weightValue > 0 else {
            errorMessage = "Please enter a valid target weight"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if let goalToEdit = selectedGoalToEdit {
                // Update existing goal
                try await viewModel.updateGoal(
                    id: goalToEdit.id,
                    targetWeight: weightValue,
                    targetDate: targetDate
                )
            } else {
                // Create new goal with smart features
                if selectedGoalType == .main && generateMilestones {
                    try await viewModel.createMainGoalWithMilestones(
                        targetWeight: weightValue,
                        targetDate: targetDate
                    )
                } else {
                    try await viewModel.createGoal(
                        targetWeight: weightValue,
                        targetDate: targetDate
                    )
                }
            }
            
            // Close the sheet on success
            dismiss()
            
        } catch {
            print("❌ GoalView: Failed to save goal: \(error)")
            errorMessage = "Failed to save goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func updateGoalRecommendation() {
        guard let weightValue = Double(targetWeight), weightValue > 0 else {
            goalRecommendation = nil
            return
        }
        
        let timeframe = targetDate.timeIntervalSinceNow
        goalRecommendation = viewModel.getGoalRecommendations(
            desiredWeight: weightValue,
            timeframe: timeframe
        )
    }
    
    private func deleteGoal(_ goal: Goal) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await viewModel.deleteGoal(id: goal.id)
            
            // If we were editing this goal, clear the selection
            if selectedGoalToEdit?.id == goal.id {
                selectedGoalToEdit = nil
                targetWeight = ""
                targetDate = Date()
            }
            
        } catch {
            print("❌ GoalView: Failed to delete goal: \(error)")
            errorMessage = "Failed to delete goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
