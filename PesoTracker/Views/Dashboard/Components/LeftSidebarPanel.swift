import SwiftUI

struct LeftSidebarPanel: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onEditGoal: () -> Void
    let onAddGoal: () -> Void
    let onAdvancedSettings: () -> Void
    let onCalculateBMI: () -> Void
    let onLogout: () -> Void
    
    @State private var showSettingsDropdown = false
    
    var body: some View {
        VStack(spacing: 0) {
            // App logo
            appHeader
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    PersonalSummaryCard(
                        viewModel: viewModel
                    )
                    
                    MainGoalCard(
                        viewModel: viewModel,
                        onEditGoal: onEditGoal,
                        onAddGoal: onAddGoal
                    )
                    .padding(.bottom, 8)
                    
                    WeightPredictionCard(
                        viewModel: viewModel
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            // User profile at bottom
            UserProfileSection(
                viewModel: viewModel,
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
                            onCalculateBMI: {
                                onCalculateBMI()
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
                            y: geometry.size.height - 125
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
        viewModel: DashboardViewModel(),
        onEditGoal: {},
        onAddGoal: {},
        onAdvancedSettings: {},
        onCalculateBMI: {},
        onLogout: {}
    )
    .frame(width: 350, height: 600)
}