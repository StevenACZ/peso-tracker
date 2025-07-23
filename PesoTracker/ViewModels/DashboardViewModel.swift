//
//  DashboardViewModel.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var weights: [WeightEntry] = []
    @Published var goals: [Goal] = []
    @Published var currentGoal: Goal?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Computed properties
    var currentWeight: Double {
        weights.last?.weightValue ?? 0
    }
    
    var startingWeight: Double {
        weights.first?.weightValue ?? 0
    }
    
    var weightProgress: Double {
        guard !weights.isEmpty else { return 0 }
        return currentWeight - startingWeight
    }
    
    var goalProgress: Double? {
        guard let goal = currentGoal else { return nil }
        let totalChange = startingWeight - goal.targetWeight
        let currentChange = startingWeight - currentWeight
        return totalChange > 0 ? currentChange / totalChange : 0
    }
    
    var goalProgressText: String {
        guard let goal = currentGoal else { return "No goal" }
        let remaining = currentWeight - goal.targetWeight
        return remaining > 0 ? "\(String(format: "%.1f", remaining)) kg to go" : "Goal achieved!"
    }
    
    var mainGoal: Goal? {
        currentGoal
    }
    
    var nextMilestone: Double? {
        guard let goal = currentGoal else { return nil }
        let remaining = currentWeight - goal.targetWeight
        return remaining > 0 ? goal.targetWeight : nil
    }
    
    var progressPrediction: ProgressPrediction? {
        guard weights.count >= 2, let goal = currentGoal else { return nil }
        
        // Parse the target date string to Date
        let dateFormatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        var targetDate: Date?
        for format in formats {
            dateFormatter.dateFormat = format
            if let parsedDate = dateFormatter.date(from: goal.targetDate) {
                targetDate = parsedDate
                break
            }
        }
        
        guard let validTargetDate = targetDate else { return nil }
        
        let predictor = ProgressPredictor()
        return predictor.generatePrediction(
            currentWeight: currentWeight,
            targetWeight: goal.targetWeight,
            targetDate: validTargetDate,
            weightEntries: weights
        )
    }
    
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadWeightData()
        }
    }
    
    @MainActor
    func loadWeightData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let weightsTask = apiService.getWeights()
            async let goalsTask = apiService.getGoals()
            
            let (weightsResponse, goalsResponse) = try await (weightsTask, goalsTask)
            
            self.weights = weightsResponse.data.sorted { $0.date > $1.date }
            self.goals = goalsResponse.data
            self.currentGoal = goalsResponse.data.first { $0.type == .main }
            
        } catch {
            print("❌ DashboardViewModel: Error loading data: \(error)")
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateWeight(id: Int, weight: Double, date: Date, notes: String?) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let request = AddWeightRequest(weight: weight, date: dateString, notes: notes)
        _ = try await apiService.updateWeight(id: id, request: request)
        await loadWeightData()
    }
    
    @MainActor
    func addWeight(weight: Double, date: Date, notes: String?) async throws -> WeightEntry {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let request = AddWeightRequest(weight: weight, date: dateString, notes: notes)
        let response = try await apiService.addWeight(request)
        await loadWeightData()
        return response.data
    }
    
    @MainActor
    func deleteWeight(id: Int) async throws {
        try await apiService.deleteWeight(id: id)
        await loadWeightData()
    }
    
    @MainActor
    func createGoal(targetWeight: Double, targetDate: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(targetWeight: targetWeight, targetDate: dateString, type: .main)
        _ = try await apiService.createGoal(request)
        await loadWeightData()
    }
    
    @MainActor
    func updateGoal(id: Int, targetWeight: Double, targetDate: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(targetWeight: targetWeight, targetDate: dateString, type: .main)
        _ = try await apiService.updateGoal(id: id, request: request)
        await loadWeightData()
    }
    
    @MainActor
    func deleteGoal(id: Int) async throws {
        try await apiService.deleteGoal(id: id)
        await loadWeightData()
    }
    
    @MainActor
    func logout() {
        AuthenticationManager.shared.logout()
    }
}
