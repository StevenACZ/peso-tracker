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
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var selectedGoalToEdit: Goal?
    
    private var isEditing: Bool {
        selectedGoalToEdit != nil
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text(isEditing ? "Update Goal" : "Create New Goal")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding()
            
            // Form
            VStack(spacing: 20) {
                // Target weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Weight (kg)")
                        .font(.headline)
                    
                    TextField("Enter target weight", text: $targetWeight)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Target date picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Date")
                        .font(.headline)
                    
                    DatePicker("Select target date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                // Existing goals list
                if !viewModel.goals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Existing Goals")
                            .font(.headline)
                        
                        ForEach(viewModel.goals) { goal in
                            let isAchieved = viewModel.currentWeight <= goal.targetWeight
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Target: \(goal.formattedTargetWeight)")
                                        .fontWeight(.medium)
                                    Text("By: \(goal.formattedTargetDate)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if isAchieved {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Achieved!")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    Button("Edit") {
                                        selectedGoalToEdit = goal
                                        targetWeight = String(goal.targetWeight)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        if let date = dateFormatter.date(from: goal.targetDate) {
                                            targetDate = date
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    
                                    Button("Delete") {
                                        Task {
                                            await deleteGoal(goal)
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background((isAchieved ? Color.green : Color.gray).opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isAchieved ? Color.green : Color.clear, lineWidth: isAchieved ? 2 : 0)
                            )
                        }
                    }
                }
                
                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Save button
                Button(isEditing ? "Update Goal" : "Create Goal") {
                    Task {
                        await saveGoal()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(targetWeight.isEmpty || isLoading)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .frame(maxWidth: 400)
            .padding()
            
            Spacer()
        }
        .frame(width: 500, height: 450)
        .onAppear {
            // Start with a clean form for creating new goals
            if selectedGoalToEdit == nil {
                targetWeight = ""
                targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // Default to 30 days from now
            }
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
                // Create new goal
                try await viewModel.createGoal(
                    targetWeight: weightValue,
                    targetDate: targetDate
                )
            }
            
            // Close the sheet on success
            dismiss()
            
        } catch {
            print("❌ GoalView: Failed to save goal: \(error)")
            errorMessage = "Failed to save goal: \(error.localizedDescription)"
        }
        
        isLoading = false
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