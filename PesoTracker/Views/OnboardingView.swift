//
//  OnboardingView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showingMainApp = false
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            #if os(iOS)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            #endif
            
            // Bottom section
            VStack(spacing: 20) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Get Started") {
                            showingMainApp = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showingMainApp) {
            DashboardView() // Main app view
        }
        #else
        .sheet(isPresented: $showingMainApp) {
            DashboardView() // Main app view
        }
        #endif
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Text(page.icon)
                .font(.system(size: 80))
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                if !page.features.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(page.features, id: \.self) { feature in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text(feature)
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 60)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Onboarding Data

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let features: [String]
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "⚖️",
            title: "Welcome to PesoTracker",
            description: "Your intelligent companion for weight management and goal achievement.",
            features: []
        ),
        
        OnboardingPage(
            icon: "🎯",
            title: "Smart Goals & Milestones",
            description: "Set your main goal and let our AI create intelligent milestones to keep you motivated.",
            features: [
                "Automatic milestone generation",
                "Progress-based timeline adjustments",
                "Realistic goal recommendations"
            ]
        ),
        
        OnboardingPage(
            icon: "🏆",
            title: "Achievement System",
            description: "Unlock achievements as you progress and stay motivated with our comprehensive reward system.",
            features: [
                "30+ achievements across 5 categories",
                "Real-time progress tracking",
                "Celebration animations"
            ]
        ),
        
        OnboardingPage(
            icon: "📊",
            title: "AI-Powered Insights",
            description: "Get intelligent predictions and personalized recommendations based on your progress patterns.",
            features: [
                "Progress predictions",
                "Smart recommendations",
                "Trend analysis"
            ]
        ),
        
        OnboardingPage(
            icon: "📸",
            title: "Progress Photos",
            description: "Capture your transformation journey with progress photos and before/after comparisons.",
            features: [
                "Visual progress tracking",
                "Before/after comparisons",
                "Secure local storage"
            ]
        ),
        
        OnboardingPage(
            icon: "🚀",
            title: "Ready to Start?",
            description: "Everything is set up and ready to go. Let's begin your weight management journey!",
            features: []
        )
    ]
}

// MARK: - Preview

#Preview {
    OnboardingView()
}