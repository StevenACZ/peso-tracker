//
//  DashboardAchievementSection.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

struct DashboardAchievementSection: View {
    @StateObject private var achievementSystem = AchievementSystem()
    @State private var showingAchievementGallery = false
    
    let currentWeight: Double
    let weightEntries: [WeightEntry]
    let goals: [Goal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text("🏆 Recent Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingAchievementGallery = true
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            if achievementSystem.summaryStats.unlockedCount > 0 {
                // Achievement cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(achievementSystem.dashboardAchievements, id: \.id) { achievement in
                            DashboardAchievementCard(
                                achievement: achievement,
                                isUnlocked: achievementSystem.isUnlocked(achievement.id)
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                // Achievement stats
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(achievementSystem.summaryStats.totalPoints)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Total Points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(achievementSystem.summaryStats.completionPercentage)%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            } else {
                // No achievements yet
                VStack(spacing: 8) {
                    Text("🎯")
                        .font(.system(size: 40))
                    
                    Text("Start your journey to unlock achievements!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Log your weight regularly and set goals to earn your first achievements.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
        .onAppear {
            Task {
                await achievementSystem.evaluateAchievements(
                    currentWeight: currentWeight,
                    weightEntries: weightEntries,
                    goals: goals
                )
            }
        }
        .sheet(isPresented: $showingAchievementGallery) {
            AchievementGalleryView()
        }
    }
}

struct DashboardAchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(achievement.displayIcon)
                .font(.title2)
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            Text(achievement.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .lineLimit(2)
            
            if isUnlocked {
                Text("+\(achievement.points)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(isUnlocked ? achievement.rarity.color.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isUnlocked ? achievement.rarity.color : Color.gray.opacity(0.2),
                    lineWidth: isUnlocked ? 2 : 1
                )
        )
    }
}
