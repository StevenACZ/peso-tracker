import SwiftUI

struct LeftSidebarPanel: View {
    let hasData: Bool
    let onEditGoal: () -> Void
    let onAddGoal: () -> Void
    let onAdvancedSettings: () -> Void
    let onLogout: () -> Void
    
    @State private var showSettingsDropdown = false
    
    var body: some View {
        VStack(spacing: 0) {
            // App logo
            appHeader
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    PersonalSummaryCard(
                        hasData: hasData,
                        initialWeight: hasData ? "82 kg" : "",
                        currentWeight: hasData ? "75 kg" : "",
                        totalChange: hasData ? "-7 kg" : ""
                    )
                    
                    MainGoalCard(
                        hasData: hasData,
                        currentWeight: hasData ? "75 kg" : "",
                        targetWeight: hasData ? "68 kg" : "",
                        progress: 0.7,
                        onEditGoal: onEditGoal,
                        onAddGoal: onAddGoal
                    )
                    
                    WeightPredictionCard(
                        hasData: hasData,
                        weeklyAverage: "-0.5 kg",
                        estimatedDate: "2024-12-15",
                        daysAhead: 31
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            // User profile at bottom
            UserProfileSection(
                userName: "Usuario",
                userEmail: "email@example.com",
                userInitials: "U",
                showSettingsDropdown: $showSettingsDropdown,
                onAdvancedSettings: {
                    onAdvancedSettings()
                    showSettingsDropdown = false
                },
                onLogout: {
                    onLogout()
                    showSettingsDropdown = false
                }
            )
        }
        .overlay(
            // Settings dropdown overlay
            Group {
                if showSettingsDropdown {
                    GeometryReader { geometry in
                        SettingsDropdown(
                            onAdvancedSettings: {
                                onAdvancedSettings()
                                showSettingsDropdown = false
                            },
                            onLogout: {
                                onLogout()
                                showSettingsDropdown = false
                            },
                            onDismiss: {
                                showSettingsDropdown = false
                            }
                        )
                        .position(
                            x: geometry.size.width - 100,
                            y: geometry.size.height - 105
                        )
                    }
                }
            }
        )
        .onTapGesture {
            if showSettingsDropdown {
                showSettingsDropdown = false
            }
        }
    }
    
    private var appHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.walk.circle.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.green)
            
            Text("PesoTracker")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    LeftSidebarPanel(
        hasData: true,
        onEditGoal: {},
        onAddGoal: {},
        onAdvancedSettings: {},
        onLogout: {}
    )
    .frame(width: 350, height: 600)
}