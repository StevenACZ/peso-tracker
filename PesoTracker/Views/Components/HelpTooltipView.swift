//
//  HelpTooltipView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI

// MARK: - Help Tooltip View

struct HelpTooltipView: View {
    let text: String
    let position: TooltipPosition
    @State private var showTooltip = false
    
    var body: some View {
        Button(action: {
            showTooltip.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showTooltip, arrowEdge: position.arrowEdge) {
            Text(text)
                .font(.caption)
                .padding(8)
                .frame(maxWidth: 200)
        }
    }
}

enum TooltipPosition {
    case top, bottom, leading, trailing
    
    var arrowEdge: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}

// MARK: - Feature Highlight View

struct FeatureHighlightView: View {
    let title: String
    let description: String
    let isNew: Bool
    @State private var showHighlight = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if isNew {
                        Text("NEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Learn More") {
                showHighlight = true
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showHighlight) {
            FeatureDetailView(title: title, description: description)
        }
    }
}

struct FeatureDetailView: View {
    let title: String
    let description: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(description)
                    .font(.body)
                
                // Add more detailed content here based on the feature
                
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
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
}

// MARK: - Quick Tips View

struct QuickTipsView: View {
    @State private var currentTip = 0
    @State private var showAllTips = false
    
    private let tips = QuickTip.allTips
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💡 Quick Tip")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showAllTips = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if !tips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(tips[currentTip].title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(tips[currentTip].description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Button("Previous") {
                        currentTip = (currentTip - 1 + tips.count) % tips.count
                    }
                    .font(.caption)
                    .disabled(tips.count <= 1)
                    
                    Spacer()
                    
                    Text("\(currentTip + 1) of \(tips.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Next") {
                        currentTip = (currentTip + 1) % tips.count
                    }
                    .font(.caption)
                    .disabled(tips.count <= 1)
                }
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showAllTips) {
            AllTipsView(tips: tips)
        }
    }
}

struct AllTipsView: View {
    let tips: [QuickTip]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(tips, id: \.title) { tip in
                VStack(alignment: .leading, spacing: 8) {
                    Text(tip.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(tip.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Tips & Tricks")
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
}

// MARK: - Quick Tip Data

struct QuickTip {
    let title: String
    let description: String
    let category: TipCategory
    
    enum TipCategory {
        case goals, achievements, photos, general
    }
    
    static let allTips: [QuickTip] = [
        QuickTip(
            title: "Set Realistic Goals",
            description: "Aim for 0.5-1kg weight loss per week for sustainable results. Our AI will help you set realistic milestones.",
            category: .goals
        ),
        
        QuickTip(
            title: "Log Weight Consistently",
            description: "Daily weigh-ins help unlock consistency achievements and provide better progress predictions.",
            category: .general
        ),
        
        QuickTip(
            title: "Use Progress Photos",
            description: "Photos capture changes that the scale might miss. Take them in the same lighting and pose for best comparison.",
            category: .photos
        ),
        
        QuickTip(
            title: "Achievement Chains",
            description: "Some achievements unlock others! Complete basic achievements to unlock more challenging ones.",
            category: .achievements
        ),
        
        QuickTip(
            title: "Smart Milestones",
            description: "Let the app generate automatic milestones for your main goal. They adjust based on your progress!",
            category: .goals
        ),
        
        QuickTip(
            title: "Maintenance Goals",
            description: "Once you reach your target weight, create a maintenance goal to keep your progress stable.",
            category: .goals
        ),
        
        QuickTip(
            title: "Weekend Logging",
            description: "Don't skip weekend weigh-ins! Consistency achievements require regular logging, including weekends.",
            category: .achievements
        ),
        
        QuickTip(
            title: "Progress Predictions",
            description: "The more data you provide, the more accurate our AI predictions become. Log regularly for best results!",
            category: .general
        )
    ]
}

// MARK: - View Modifiers

extension View {
    func helpTooltip(_ text: String, position: TooltipPosition = .top) -> some View {
        HStack {
            self
            HelpTooltipView(text: text, position: position)
        }
    }
    
    func featureHighlight(title: String, description: String, isNew: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            self
            FeatureHighlightView(title: title, description: description, isNew: isNew)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Smart Goals")
            .helpTooltip("AI-generated milestones that adapt to your progress")
        
        QuickTipsView()
        
        FeatureHighlightView(
            title: "New Achievement System",
            description: "Unlock 30+ achievements as you progress on your journey",
            isNew: true
        )
    }
    .padding()
}