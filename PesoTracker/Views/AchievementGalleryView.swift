//
//  AchievementGalleryView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

struct AchievementGalleryView: View {
    @StateObject private var achievementSystem = AchievementSystem()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: AchievementCategory? = nil
    @State private var selectedAchievement: Achievement? = nil
    @State private var showingAchievementDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Text("🏆 Achievements")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                Divider()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .background(Color(NSColor.windowBackgroundColor))
            
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                    .padding(.top, 16)
                
                // Category filter
                categoryFilterSection
                
                // Achievement grid
                achievementGridSection
            }
        }
        .frame(minWidth: 700, maxWidth: 900, minHeight: 500, maxHeight: 650)
        .sheet(isPresented: $showingAchievementDetail) {
            if let achievement = selectedAchievement {
                AchievementDetailView(
                    achievement: achievement,
                    progress: achievementSystem.getProgress(for: achievement.id),
                    isUnlocked: achievementSystem.isUnlocked(achievement.id)
                )
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Overall progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(achievementSystem.summaryStats.unlockedCount)/\(achievementSystem.summaryStats.totalAchievements) Unlocked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(achievementSystem.summaryStats.totalPoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            ProgressView(value: Double(achievementSystem.summaryStats.completionPercentage) / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .frame(height: 8)
            
            Text("\(achievementSystem.summaryStats.completionPercentage)% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Category Filter Section
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryFilterButton(
                    title: "All",
                    emoji: "🏆",
                    isSelected: selectedCategory == nil,
                    count: achievementSystem.summaryStats.totalAchievements
                ) {
                    selectedCategory = nil
                }
                
                // Individual category buttons
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.displayName,
                        emoji: category.emoji,
                        isSelected: selectedCategory == category,
                        count: category.achievementCount
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Achievement Grid Section
    
    private var achievementGridSection: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredAchievements, id: \.id) { achievement in
                    AchievementCardView(
                        achievement: achievement,
                        progress: achievementSystem.getProgress(for: achievement.id),
                        isUnlocked: achievementSystem.isUnlocked(achievement.id)
                    ) {
                        selectedAchievement = achievement
                        showingAchievementDetail = true
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementSystem.getAchievements(by: category)
        } else {
            return AchievementDefinitions.allAchievements
        }
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Achievement Card View

struct AchievementCardView: View {
    let achievement: Achievement
    let progress: AchievementProgress?
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Achievement icon
                Text(achievement.displayIcon)
                    .font(.system(size: 32))
                    .opacity(isUnlocked ? 1.0 : 0.3)
                
                // Achievement name
                Text(achievement.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                // Progress or points
                if isUnlocked {
                    HStack(spacing: 4) {
                        Text("\(achievement.points)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("pts")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else if let progress = progress, progress.progress > 0 {
                    VStack(spacing: 2) {
                        ProgressView(value: progress.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: achievement.rarity.color))
                            .frame(height: 4)
                        
                        Text("\(progress.progressPercentage)%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Locked")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Rarity indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(achievement.rarity.color)
                    .frame(height: 3)
            }
            .padding(12)
            .background(isUnlocked ? Color.clear : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isUnlocked ? achievement.rarity.color : Color.gray.opacity(0.2),
                        lineWidth: isUnlocked ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Achievement Detail View

struct AchievementDetailView: View {
    let achievement: Achievement
    let progress: AchievementProgress?
    let isUnlocked: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Achievement icon and name
                VStack(spacing: 16) {
                    Text(achievement.displayIcon)
                        .font(.system(size: 80))
                        .opacity(isUnlocked ? 1.0 : 0.3)
                    
                    Text(achievement.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Status section
                VStack(spacing: 16) {
                    if isUnlocked {
                        // Unlocked status
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Unlocked!")
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                            .font(.headline)
                            
                            if let progress = progress, let unlockedAt = progress.unlockedAt {
                                Text("Earned on \(formattedDate(unlockedAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        // Progress section
                        VStack(spacing: 12) {
                            Text("Progress")
                                .font(.headline)
                            
                            if let progress = progress {
                                VStack(spacing: 8) {
                                    ProgressView(value: progress.progress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: achievement.rarity.color))
                                        .frame(height: 8)
                                    
                                    HStack {
                                        Text("\(Int(progress.currentValue))")
                                            .fontWeight(.medium)
                                        Text("/ \(Int(progress.targetValue))")
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text("\(progress.progressPercentage)%")
                                            .fontWeight(.medium)
                                            .foregroundColor(achievement.rarity.color)
                                    }
                                    .font(.subheadline)
                                }
                            } else {
                                Text("Not started")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Achievement info
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(achievement.category.emoji)
                                Text(achievement.category.displayName)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Rarity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(achievement.rarity.displayName)
                                .fontWeight(.medium)
                                .foregroundColor(achievement.rarity.color)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(achievement.points)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Achievement")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    AchievementGalleryView()
}
