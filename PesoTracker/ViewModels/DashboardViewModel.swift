//
//  DashboardViewModel.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var weights: [WeightEntry] = []
    @Published var goals: [Goal] = []
    @Published var currentWeight: Double = 0.0
    @Published var startingWeight: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    var weightProgress: Double {
        return currentWeight - startingWeight
    }
    
    var progressText: String {
        let progress = weightProgress
        if progress > 0 {
            return "Gained: +\(String(format: "%.1f", progress)) kg"
        } else if progress < 0 {
            return "Lost: \(String(format: "%.1f", abs(progress))) kg"
        } else {
            return "No change"
        }
    }
    
    var currentGoal: Goal? {
        return goals.first
    }
    
    var goalProgress: Double? {
        guard let goal = currentGoal else { return nil }
        if startingWeight == 0 { return nil }
        
        let totalNeeded = abs(goal.targetWeight - startingWeight)
        let achieved = abs(currentWeight - startingWeight)
        
        return min(achieved / totalNeeded, 1.0)
    }
    
    var goalProgressText: String {
        guard let goal = currentGoal else { return "No goal set" }
        
        let remaining = goal.targetWeight - currentWeight
        if abs(remaining) < 0.1 {
            return "Goal achieved! 🎉"
        } else if remaining > 0 {
            return "\(String(format: "%.1f", remaining)) kg to go"
        } else {
            return "Goal exceeded by \(String(format: "%.1f", abs(remaining))) kg!"
        }
    }
    
    func loadWeightData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load weights
            let weightResponse = try await apiService.getWeights()
            
            print("📊 DashboardViewModel: Received \(weightResponse.data.count) weight entries")
            
            // Sort weights by date (oldest first for display)
            weights = weightResponse.data.sorted { first, second in
                return first.date < second.date
            }
            
            // Calculate current and starting weights (now that oldest is first)
            if let oldest = weights.first {
                startingWeight = oldest.weight
                print("📊 DashboardViewModel: Starting weight set to \(startingWeight) kg")
            }
            if let mostRecent = weights.last {
                currentWeight = mostRecent.weight
                print("📊 DashboardViewModel: Current weight set to \(currentWeight) kg")
            }
            
            // If we only have one entry, use it for both current and starting
            if weights.count == 1 {
                startingWeight = currentWeight
                print("📊 DashboardViewModel: Only one entry, using same weight for both current and starting")
            }
            
            // Load goals
            do {
                let goalResponse = try await apiService.getGoals()
                goals = goalResponse.data
            } catch {
                print("⚠️ DashboardViewModel: Failed to load goals: \(error)")
                // Don't fail the whole operation if goals fail
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        AuthenticationManager.shared.logout()
    }
    
    func addWeight(weight: Double, date: Date, notes: String?) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let request = AddWeightRequest(
            weight: weight,
            date: dateString,
            notes: notes?.isEmpty == false ? notes : nil
        )
        
        print("📝 DashboardViewModel: Adding weight \(weight) kg on \(dateString)")
        
        let _ = try await apiService.addWeight(request)
        
        print("✅ DashboardViewModel: Weight added successfully, refreshing data")
        
        // Refresh the weight data after adding
        await loadWeightData()
    }
    
    func updateWeight(id: Int, weight: Double, date: Date, notes: String?) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let request = AddWeightRequest(
            weight: weight,
            date: dateString,
            notes: notes?.isEmpty == false ? notes : nil
        )
        
        print("📝 DashboardViewModel: Updating weight \(id) to \(weight) kg on \(dateString)")
        
        let _ = try await apiService.updateWeight(id: id, request: request)
        
        print("✅ DashboardViewModel: Weight updated successfully, refreshing data")
        
        // Refresh the weight data after updating
        await loadWeightData()
    }
    
    func deleteWeight(id: Int) async throws {
        print("🗑️ DashboardViewModel: Deleting weight \(id)")
        
        try await apiService.deleteWeight(id: id)
        
        print("✅ DashboardViewModel: Weight deleted successfully, refreshing data")
        
        // Refresh the weight data after deleting
        await loadWeightData()
    }
    
    func createGoal(targetWeight: Double, targetDate: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(
            targetWeight: targetWeight,
            targetDate: dateString
        )
        
        print("🎯 DashboardViewModel: Creating goal for \(targetWeight) kg by \(dateString)")
        
        let _ = try await apiService.createGoal(request)
        
        print("✅ DashboardViewModel: Goal created successfully, refreshing data")
        
        // Refresh the data after creating goal
        await loadWeightData()
    }
    
    func updateGoal(id: Int, targetWeight: Double, targetDate: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: targetDate)
        
        let request = CreateGoalRequest(
            targetWeight: targetWeight,
            targetDate: dateString
        )
        
        print("🎯 DashboardViewModel: Updating goal \(id) to \(targetWeight) kg by \(dateString)")
        
        let _ = try await apiService.updateGoal(id: id, request: request)
        
        print("✅ DashboardViewModel: Goal updated successfully, refreshing data")
        
        // Refresh the data after updating goal
        await loadWeightData()
    }
    
    func deleteGoal(id: Int) async throws {
        print("🗑️ DashboardViewModel: Deleting goal \(id)")
        
        try await apiService.deleteGoal(id: id)
        
        print("✅ DashboardViewModel: Goal deleted successfully, refreshing data")
        
        // Refresh the data after deleting goal
        await loadWeightData()
    }
}