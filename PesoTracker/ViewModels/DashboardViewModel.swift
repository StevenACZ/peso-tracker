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
    @Published var currentWeight: Double = 0.0
    @Published var startingWeight: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weightService = WeightService()
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
    
    func loadWeightData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await weightService.fetchWeights()
            weights = response.weights
            currentWeight = response.currentWeight ?? 0.0
            startingWeight = response.startingWeight ?? 0.0
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        AuthenticationManager.shared.logout()
    }
}