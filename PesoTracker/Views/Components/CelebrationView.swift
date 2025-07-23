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
            // Background overlay with blur effect
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                // Subtle blur effect
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                    .ignoresSafeArea()
            }
            .onTapGesture {
                onDismiss()
            }
            .accessibilityLabel("Dismiss achievement celebration")
            
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
                
                // Action button
                Button("Continue") {
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .opacity(opacity)
                .disabled(opacity < 1.0)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
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
        
        // Animate the main elements with a more professional feel
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)) {
            scale = 1.0
        }
        
        // Fade in content slightly after scale
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            opacity = 1.0
        }
        
        // Add a subtle rotation to the icon
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
            rotation = 3
        }
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
            // Background overlay with blur effect
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                // Subtle blur effect
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                    .ignoresSafeArea()
            }
            .onTapGesture {
                onDismiss()
            }
            .accessibilityLabel("Dismiss goal celebration")
            
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
                
                // Action button
                Button("Continue") {
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .opacity(opacity)
                .disabled(opacity < 1.0)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
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
        
        // Animate the main elements with a more professional feel
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)) {
            scale = 1.0
        }
        
        // Fade in content slightly after scale
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            opacity = 1.0
        }
        
        // Add a pulse effect to the background circle
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.3)) {
            pulseScale = 1.15
        }
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

// MARK: - Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Dashboard View Extension

extension DashboardView {
    @ViewBuilder
    func celebrationOverlay(for celebration: CelebrationManager.CelebrationType) -> some View {
        switch celebration {
        case .achievement(let achievement):
            AchievementCelebrationView(
                achievement: achievement,
                onDismiss: {
                    viewModel.celebrationManager.immediateDismiss()
                }
            )
        case .goal(let goal):
            GoalCelebrationView(
                goal: goal,
                onDismiss: {
                    viewModel.celebrationManager.immediateDismiss()
                }
            )
        }
    }
}