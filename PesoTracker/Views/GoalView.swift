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
    @State private var targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // Será reemplazado por la fecha original si estamos editando
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isEditing: Bool {
        viewModel.currentGoal != nil
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
                    // Current goal display (if editing)
                    if isEditing, let currentGoal = viewModel.currentGoal {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Goal")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Target: \(currentGoal.formattedTargetWeight)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text("By: \(currentGoal.formattedTargetDate)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(viewModel.goalProgressText)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    if let progress = viewModel.goalProgress {
                                        // Aseguramos que el valor esté entre 0 y 1
                                        let clampedProgress = max(0.0, min(progress, 1.0))
                                        ProgressView(value: clampedProgress, total: 1.0)
                                            .frame(width: 100)
                                            .tint(.blue)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 1)
                        )
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
                                .id(targetDate) // Forzar la actualización del DatePicker cuando cambia la fecha
                            
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
                    
                    // Delete goal option (if editing)
                    if isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Danger Zone")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Button("Delete Goal") {
                                Task {
                                    await deleteCurrentGoal()
                                }
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                            .disabled(isLoading)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
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
        .frame(minWidth: 500, minHeight: 400)
        .task {
            // Usar task en lugar de onAppear para asegurarnos de que se ejecute correctamente
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        if let currentGoal = viewModel.currentGoal {
            // Editing existing goal
            targetWeight = String(format: "%.1f", currentGoal.targetWeight)
            
            print("🎯 GoalView: Original target date string: \(currentGoal.targetDate)")
            
            // Probar diferentes formatos de fecha que podría devolver la API
            let dateFormatter = DateFormatter()
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                "yyyy-MM-dd'T'HH:mm:ss'Z'",
                "yyyy-MM-dd"
            ]
            
            var parsedDate: Date?
            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: currentGoal.targetDate) {
                    parsedDate = date
                    print("🎯 GoalView: Successfully parsed date with format: \(format)")
                    break
                }
            }
            
            if let parsedDate = parsedDate {
                targetDate = parsedDate
                print("🎯 GoalView: Set target date to: \(targetDate)")
            } else {
                print("❌ GoalView: Failed to parse target date: \(currentGoal.targetDate)")
                // Mantener la fecha predeterminada
            }
        } else {
            // Creating new goal
            targetWeight = ""
            targetDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // Default to 30 days from now
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
            dismiss()
        } catch {
            print("❌ GoalView: Failed to delete goal: \(error)")
            errorMessage = "Failed to delete goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
