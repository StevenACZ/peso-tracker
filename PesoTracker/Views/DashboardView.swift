//
//  DashboardView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingAddWeight = false
    @State private var showingGoal = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                if viewModel.isLoading {
                    ProgressView("Loading weight data...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = viewModel.errorMessage {
                    errorSection
                } else {
                    // Progress summary
                    progressSummarySection
                    
                    // Goal section
                    goalSection
                    
                    // Weight history table
                    weightTableSection
                    
                    // Simple chart
                    chartSection
                }
            }
            .padding()
        }
        .onAppear {
            Task { await viewModel.loadWeightData() }
        }
        .sheet(isPresented: $showingAddWeight) {
            AddWeightView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingGoal) {
            GoalView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Weight Progress Tracker")
                    .font(.title)
                    .fontWeight(.bold)
                
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
                
                Button("Set Goal") {
                    showingGoal = true
                }
                .buttonStyle(.bordered)
                
                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - Error Section
    private var errorSection: some View {
        VStack(spacing: 16) {
            Text("Error loading data")
                .font(.headline)
            
            Text(viewModel.errorMessage ?? "Unknown error")
                .foregroundColor(.red)
            
            Button("Retry") {
                Task { await viewModel.loadWeightData() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // MARK: - Goal Section
    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Goal")
                    .font(.headline)
                
                Spacer()
                
                Button(viewModel.currentGoal != nil ? "Edit Goal" : "Set Goal") {
                    showingGoal = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            if let goal = viewModel.currentGoal {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Target: \(goal.formattedTargetWeight)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("By: \(goal.formattedTargetDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(viewModel.goalProgressText)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            if let progress = viewModel.goalProgress {
                                ProgressView(value: progress)
                                    .frame(width: 120)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            } else {
                Text("No goal set. Set a goal to track your progress!")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Progress Summary
    private var progressSummarySection: some View {
        VStack(spacing: 16) {
            // Current stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(String(format: "%.1f", viewModel.currentWeight)) kg")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Current Weight")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(String(format: "%.1f", viewModel.startingWeight)) kg")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Starting Weight")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(progressValueText)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Weight Table
    private var weightTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight History")
                .font(.headline)
            
            if viewModel.weights.isEmpty {
                Text("No weight entries yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            } else {
                VStack(spacing: 0) {
                    // Table header
                    HStack {
                        Text("Date")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Weight (kg)")
                            .fontWeight(.semibold)
                            .frame(width: 100, alignment: .trailing)
                        
                        Text("Change")
                            .fontWeight(.semibold)
                            .frame(width: 80, alignment: .trailing)
                        
                        Text("Notes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Actions")
                            .fontWeight(.semibold)
                            .frame(width: 60, alignment: .center)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    
                    // Table rows
                    ForEach(Array(viewModel.weights.enumerated()), id: \.element.id) { index, weight in
                        HStack {
                            Text(weight.formattedDate)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(String(format: "%.1f", weight.weightValue))
                                .frame(width: 100, alignment: .trailing)
                            
                            Text(changeText(for: index))
                                .foregroundColor(changeColor(for: index))
                                .frame(width: 80, alignment: .trailing)
                            
                            Text(weight.notes ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                            
                            // Action buttons
                            HStack(spacing: 4) {
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
                            .frame(width: 60)
                        }
                        .padding()
                        .background(index % 2 == 0 ? Color.clear : Color(NSColor.controlBackgroundColor).opacity(0.3))
                    }
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Chart")
                .font(.headline)
            
            if viewModel.weights.count < 2 {
                Text("Add more weight entries to see your progress chart")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            } else {
                SimpleLineChart(weights: viewModel.weights)
                    .frame(height: 300)
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
        let previous = viewModel.weights[index - 1].weightValue // Previous in array is older
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
        let previous = viewModel.weights[index - 1].weightValue // Previous in array is older
        let change = current - previous
        
        if change < 0 {
            return .green // Weight loss
        } else if change > 0 {
            return .red // Weight gain
        } else {
            return .secondary // No change
        }
    }
}