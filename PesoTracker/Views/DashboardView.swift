//
//  DashboardView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    @State private var showingAddWeight = false
    @State private var showingGoal = false
    @State private var showingProgressPhotos = false
    @State private var editingWeight: WeightEntry?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                // Header
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                if viewModel.isLoading {
                    ProgressView("Loading weight data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.errorMessage != nil {
                    errorSection
                } else {
                    // Main content with horizontal layout
                    HStack(spacing: 0) {
                        // Left side - Summary content
                        ScrollView {
                            VStack(spacing: 20) {
                                // Progress summary cards
                                progressSummarySection
                                
                                // Weight Goal section
                                weightGoalSection
                                
                                // Smart insights and predictions
                                DashboardPredictionSection(
                                    currentWeight: viewModel.currentWeight,
                                    weightEntries: viewModel.weights,
                                    mainGoal: viewModel.mainGoal,
                                    nextMilestone: nil,
                                    progressPrediction: viewModel.progressPrediction,
                                    showProgressPhotos: {
                                        showingProgressPhotos = true
                                    }
                                )
                            }
                            .padding(24)
                        }
                        .frame(minWidth: 450, maxWidth: 600)
                        
                        Divider()
                        
                        // Right side - Chart and Weight History
                        ScrollView {
                            VStack(spacing: 64) {
                                // Progress Chart Section
                                VStack(spacing: 16) {
                                    Text("Progress Chart")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if viewModel.weights.count < 2 {
                                        VStack(spacing: 12) {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .font(.system(size: 48))
                                                .foregroundColor(.secondary)
                                            
                                            Text("Add more weight entries")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            Text("You need at least 2 weight entries to see your progress chart")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(height: 300)
                                    } else {
                                        SimpleLineChart(weights: viewModel.weights, goal: viewModel.currentGoal)
                                            .frame(height: 300)
                                    }
                                }
                                
                                // Weight History Section
                                weightTableSection
                            }
                            .padding(24)
                        }
                        .frame(minWidth: 500)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                    }
                }
                Spacer(minLength: 24)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .padding(.vertical, 24)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                Task { await viewModel.loadWeightData() }
            }
            .sheet(isPresented: $showingAddWeight) {
                AddWeightView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingGoal) {
                GoalView(viewModel: viewModel)
            }
            .sheet(item: $editingWeight) { weight in
                EditWeightView(viewModel: viewModel, weightEntry: weight)
            }
            .sheet(isPresented: $showingProgressPhotos) {
                ProgressPhotoSliderView(weightEntries: viewModel.weights)
            }
            .errorHandling()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if !viewModel.username.isEmpty {
                    Text("Hello, \(viewModel.username)!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                } else {
                    Text("Weight Progress Tracker")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Text("Track your weight journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Add Weight") {
                    showingAddWeight = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                
                Button(viewModel.currentGoal != nil ? "Edit Goal" : "Set Goal") {
                    showingGoal = true
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
    
    // MARK: - Error Section
    private var errorSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error loading data")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(viewModel.errorMessage ?? "Unknown error")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task { await viewModel.loadWeightData() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Progress Summary
    private var progressSummarySection: some View {
        HStack(spacing: 20) {
            // Current Weight Card
            VStack(spacing: 8) {
                Text("\(String(format: "%.1f", viewModel.currentWeight)) kg")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Current Weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            
            // Starting Weight Card
            VStack(spacing: 8) {
                Text("\(String(format: "%.1f", viewModel.startingWeight)) kg")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Starting Weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Progress Card
            VStack(spacing: 8) {
                Text(progressValueText)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(progressColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Weight Goal Section
    private var weightGoalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Goal")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(viewModel.currentGoal != nil ? "Edit Goal" : "Set Goal") {
                    showingGoal = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            if let goal = viewModel.currentGoal {
                let isGoalAchieved = viewModel.currentWeight <= goal.targetWeight
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Target: \(goal.formattedTargetWeight)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("By: \(goal.formattedTargetDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 8) {
                            if isGoalAchieved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                            }
                            
                            Text(viewModel.goalProgressText)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(isGoalAchieved ? .green : .blue)
                        }
                        
                        if let progress = viewModel.goalProgress {
                            // Aseguramos que el valor esté entre 0 y 1
                            let clampedProgress = max(0.0, min(progress, 1.0))
                            ProgressView(value: clampedProgress, total: 1.0)
                                .frame(width: 120)
                                .tint(isGoalAchieved ? .green : .blue)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isGoalAchieved ? Color.green : Color.blue, lineWidth: 2)
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    
                    Text("No goal set")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Set a goal to track your progress!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Weight Table
    private var weightTableSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weight History")
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewModel.weights.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No weight entries yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add your first weight entry to start tracking your progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            } else {
                VStack(spacing: 0) {
                    // Table header
                    HStack {
                        Text("Date")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Weight (kg)")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(width: 100, alignment: .trailing)
                        
                        Text("Change")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .trailing)
                        
                        Text("Notes")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Actions")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(width: 120, alignment: .center)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    
                    // Table rows
                    ForEach(Array(viewModel.weights.enumerated()), id: \.element.id) { index, weight in
                        HStack {
                            Text(weight.formattedDate)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(String(format: "%.1f", weight.weightValue))
                                .foregroundColor(.primary)
                                .frame(width: 100, alignment: .trailing)
                            
                            Text(changeText(for: index))
                                .foregroundColor(changeColor(for: index))
                                .frame(width: 80, alignment: .trailing)
                            
                            Text(weight.notes ?? "")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Action buttons
                            HStack(spacing: 8) {
                                Button("Edit") {
                                    editingWeight = weight
                                }
                                .foregroundColor(.blue)
                                .font(.caption)
                                .buttonStyle(.plain)
                                
                                Button("Delete") {
                                    Task {
                                        do {
                                            try await viewModel.deleteWeight(id: weight.id)
                                        } catch {
                                            print("❌ Failed to delete weight: \(error)")
                                        }
                                    }
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                                .buttonStyle(.plain)
                            }
                            .frame(width: 120)
                        }
                        .padding()
                        .background(index % 2 == 0 ? Color.clear : Color(NSColor.controlBackgroundColor).opacity(0.3))
                    }
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    private var progressValueText: String {
        let progress = viewModel.weightProgress
        if progress > 0 {
            return "+\(String(format: "%.1f", progress)) kg"
        } else if progress < 0 {
            return "\(String(format: "%.1f", progress)) kg"
        } else {
            return "0.0 kg"
        }
    }
    
    private var progressColor: Color {
        let progress = viewModel.weightProgress
        if progress < 0 {
            return .green // Weight loss is good
        } else if progress > 0 {
            return .red // Weight gain
        } else {
            return .secondary // No change
        }
    }
    
    private func changeText(for index: Int) -> String {
        if index == 0 { return "-" } // First entry (oldest) has no previous
        let current = viewModel.weights[index].weightValue
        let previous = viewModel.weights[index - 1].weightValue // Previous in array is older (since we sorted ascending)
        let change = current - previous
        
        if change > 0 {
            return "+\(String(format: "%.1f", change))"
        } else if change < 0 {
            return "\(String(format: "%.1f", change))"
        } else {
            return "0.0"
        }
    }
    
    private func changeColor(for index: Int) -> Color {
        if index == 0 { return .secondary } // First entry has no previous
        let current = viewModel.weights[index].weightValue
        let previous = viewModel.weights[index - 1].weightValue // Previous in array is older (since we sorted ascending)
        let change = current - previous
        
        if change < 0 {
            return .green // Weight loss (verde para pérdida de peso)
        } else if change > 0 {
            return .red // Weight gain (rojo para aumento de peso)
        } else {
            return .secondary // No change
        }
    }
}
