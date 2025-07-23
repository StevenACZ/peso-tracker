//
//  CelebrationManager.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 22/07/25.
//

import Foundation

@MainActor
class CelebrationManager: ObservableObject {
    @Published var currentCelebration: CelebrationType? = nil

    private var celebrationQueue: [CelebrationType] = []
    private var isProcessingQueue = false

    enum CelebrationType: Identifiable {
        case achievement(Achievement)
        case goal(Goal)

        var id: String {
            switch self {
            case .achievement(let achievement):
                return "achievement-\(achievement.id)"
            case .goal(let goal):
                return "goal-\(goal.id)"
            }
        }
    }

    func celebrateAchievement(_ achievement: Achievement) {
        celebrationQueue.append(.achievement(achievement))
        processQueue()
    }

    func celebrateGoal(_ goal: Goal) {
        celebrationQueue.append(.goal(goal))
        processQueue()
    }

    func celebrateMultipleAchievements(_ achievements: [Achievement]) {
        for achievement in achievements {
            celebrationQueue.append(.achievement(achievement))
        }
        processQueue()
    }

    private func processQueue() {
        guard !isProcessingQueue, !celebrationQueue.isEmpty else { return }

        isProcessingQueue = true
        currentCelebration = celebrationQueue.removeFirst()
    }

    func dismissCurrentCelebration() {
        currentCelebration = nil
        
        // Reset processing state after a brief delay to allow UI to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isProcessingQueue = false
            
            // Process next celebration if available after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.processQueue()
            }
        }
    }
    
    /// Force dismiss all celebrations and clear the queue (emergency reset)
    func forceReset() {
        currentCelebration = nil
        celebrationQueue.removeAll()
        isProcessingQueue = false
    }
    
    /// Immediate dismiss without delays (for troubleshooting)
    func immediateDismiss() {
        // Force update the published property
        objectWillChange.send()
        currentCelebration = nil
        isProcessingQueue = false
        
        // Process next immediately if available
        if !celebrationQueue.isEmpty {
            DispatchQueue.main.async {
                self.processQueue()
            }
        }
    }
    
    /// Check if there are pending celebrations
    var hasPendingCelebrations: Bool {
        return !celebrationQueue.isEmpty || currentCelebration != nil
    }
    
    /// Get current queue count for debugging
    var queueCount: Int {
        return celebrationQueue.count
    }
    
    /// Get processing state for debugging
    var isProcessing: Bool {
        return isProcessingQueue
    }
}
