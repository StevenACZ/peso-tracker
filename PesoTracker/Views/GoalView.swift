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
    
    private var isEditing: Bool {
        viewModel.currentGoal != nil
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text(isEditing ? "Update Goal" : "Set New Goal")
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
                
                // Current goal info (if editing)
                if let currentGoal = viewModel.currentGoal {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Goal")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Target: \(currentGoal.formattedTargetWeight)")
                                Text("By: \(currentGoal.formattedTargetDate)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Delete Goal") {
                                Task {
                                    await deleteCurrentGoal()
                                }
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
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
            if let currentGoal = viewModel.currentGoal {
                targetWeight = String(currentGoal.targetWeight)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: currentGoal.targetDate) {
                    targetDate = date
                }
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
            if let currentGoal = viewModel.currentGoal {
                // Update existing goal
                try await viewModel.updateGoal(
                    id: currentGoal.id,
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
    
    private func deleteCurrentGoal() async {
        guard let currentGoal = viewModel.currentGoal else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await viewModel.deleteGoal(id: currentGoal.id)
            
            // Close the sheet on success
            dismiss()
            
        } catch {
            print("❌ GoalView: Failed to delete goal: \(error)")
            errorMessage = "Failed to delete goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}