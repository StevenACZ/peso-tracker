//
//  DashboardView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with logout
            HStack {
                Text("PesoTracker Dashboard")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading weight data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error loading data")
                        .font(.headline)
                    
                    Text(error)
                        .foregroundColor(.red)
                    
                    Button("Retry") {
                        Task { await viewModel.loadWeightData() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Weight stats
                VStack(spacing: 16) {
                    Text("Current Weight: \(String(format: "%.1f", viewModel.currentWeight)) kg")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 20) {
                        Text("Starting: \(String(format: "%.1f", viewModel.startingWeight)) kg")
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.progressText)
                            .foregroundColor(viewModel.weightProgress < 0 ? .green : viewModel.weightProgress > 0 ? .red : .secondary)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Weight history table
                if viewModel.weights.isEmpty {
                    Text("No weight data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight History")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                // Header
                                HStack {
                                    Text("Date")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Weight")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(NSColor.controlBackgroundColor))
                                
                                // Data rows
                                ForEach(viewModel.weights) { weight in
                                    HStack {
                                        Text(weight.formattedDate)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(weight.formattedWeight)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task { await viewModel.loadWeightData() }
        }
    }
}