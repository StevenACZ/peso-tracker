//
//  CelebrationView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

// MARK: - Achievement Celebration View

struct AchievementCelebrationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Confetti background
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            // Main celebration card
            VStack(spacing: 24) {
                // Achievement icon with glow effect
                ZStack {
                    Circle()
                        .fill(achievement.rarity.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale * 1.2)
                    
                    Text(achievement.displayIcon)
                        .font(.system(size: 60))
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                }
                
                // Achievement details
                VStack(spacing: 12) {
                    Text("🎉 ACHIEVEMENT UNLOCKED! 🎉")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(achievement.rarity.color)
                        .opacity(opacity)
                    
                    Text(achievement.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    // Points earned
                    HStack {
                        Text("+\(achievement.points)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("points")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .opacity(opacity)
                    
                    // Rarity badge
                    Text(achievement.rarity.displayName.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(achievement.rarity.color)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .opacity(opacity)
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Share") {
                        shareAchievement()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .opacity(opacity)
                    
                    Button("Continue") {
                        dismissWithAnimation()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .opacity(opacity)
                }
            }
            .padding(32)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .scaleEffect(scale)
            .padding(.horizontal, 40)
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    private func startCelebrationAnimation() {
        // Start confetti immediately
        showConfetti = true
        
        // Animate the main elements
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Add a subtle rotation to the icon
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            rotation = 5
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
    
    private func shareAchievement() {
        // TODO: Implement sharing functionality
        print("Sharing achievement: \(achievement.name)")
    }
}

// MARK: - Goal Celebration View

struct GoalCelebrationView: View {
    let goal: Goal
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Confetti background
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            // Main celebration card
            VStack(spacing: 24) {
                // Goal icon with pulse effect
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                    
                    Text(goal.type.emoji)
                        .font(.system(size: 60))
                        .scaleEffect(scale)
                }
                
                // Goal details
                VStack(spacing: 12) {
                    Text("🎊 GOAL ACHIEVED! 🎊")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .opacity(opacity)
                    
                    Text(goal.displayTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    Text("Congratulations on reaching your goal!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    // Goal details
                    VStack(spacing: 8) {
                        HStack {
                            Text("Target:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(goal.formattedTargetWeight)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Deadline:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(goal.formattedTargetDate)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.subheadline)
                    .opacity(opacity)
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Share") {
                        shareGoal()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .opacity(opacity)
                    
                    Button("Continue") {
                        dismissWithAnimation()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .opacity(opacity)
                }
            }
            .padding(32)
            .background(Color.primary.colorInvert())
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .scaleEffect(scale)
            .padding(.horizontal, 40)
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    private func startCelebrationAnimation() {
        // Start confetti immediately
        showConfetti = true
        
        // Animate the main elements
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Add a pulse effect to the background circle
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
    
    private func shareGoal() {
        // TODO: Implement sharing functionality
        print("Sharing goal achievement: \(goal.displayTitle)")
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece()
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : 0,
                        y: animate ? CGFloat.random(in: -300...800) : -100
                    )
                    .rotationEffect(.degrees(animate ? Double.random(in: 0...360) : 0))
                    .animation(
                        .easeOut(duration: Double.random(in: 2...4))
                        .delay(Double.random(in: 0...1)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    private let shapes = ["circle", "square", "triangle"]
    
    @State private var color = Color.red
    @State private var shape = "circle"
    
    var body: some View {
        Group {
            switch shape {
            case "circle":
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            case "square":
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            default:
                Triangle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
        }
        .onAppear {
            color = colors.randomElement() ?? .red
            shape = shapes.randomElement() ?? "circle"
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Celebration Manager

@MainActor
class CelebrationManager: ObservableObject {
    @Published var showingAchievementCelebration = false
    @Published var showingGoalCelebration = false
    @Published var currentAchievement: Achievement?
    @Published var currentGoal: Goal?
    
    private var celebrationQueue: [CelebrationType] = []
    private var isProcessingQueue = false
    
    enum CelebrationType {
        case achievement(Achievement)
        case goal(Goal)
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
        showNextCelebration()
    }
    
    private func showNextCelebration() {
        guard !celebrationQueue.isEmpty else {
            isProcessingQueue = false
            return
        }
        
        let celebration = celebrationQueue.removeFirst()
        
        switch celebration {
        case .achievement(let achievement):
            currentAchievement = achievement
            showingAchievementCelebration = true
        case .goal(let goal):
            currentGoal = goal
            showingGoalCelebration = true
        }
    }
    
    func dismissCurrentCelebration() {
        // Immediately hide the current celebration
        showingAchievementCelebration = false
        showingGoalCelebration = false
        
        // Clear current items
        currentAchievement = nil
        currentGoal = nil
        
        // Reset processing state
        isProcessingQueue = false
        
        // Process next celebration if available
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.processQueue()
        }
    }
}
