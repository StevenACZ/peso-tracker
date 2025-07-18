//
//  LoadingButton.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

/// Modern loading button with smooth animations and states
struct LoadingButton: View {
    
    // MARK: - Properties
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let style: LoadingButtonStyle
    let action: () -> Void
    
    // MARK: - State
    @State private var isPressed = false
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        switch style {
        case .primary:
            if !isEnabled {
                return .gray.opacity(0.3)
            } else if isPressed {
                return .accentColor.opacity(0.8)
            } else {
                return .accentColor
            }
        case .secondary:
            if !isEnabled {
                return Color(NSColor.controlBackgroundColor).opacity(0.5)
            } else if isPressed {
                return Color(NSColor.controlBackgroundColor).opacity(0.8)
            } else {
                return Color(NSColor.controlBackgroundColor)
            }
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? .white : .gray
        case .secondary:
            return isEnabled ? .primary : .gray
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return .clear
        case .secondary:
            if !isEnabled {
                return .gray.opacity(0.3)
            } else {
                return Color(NSColor.separatorColor)
            }
        }
    }
    
    // MARK: - Initializer
    init(
        title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        style: LoadingButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.style = style
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                // Haptic feedback
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .generic,
                    performanceTime: .default
                )
                action()
            }
        }) {
            HStack(spacing: 8) {
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Button text
                Text(isLoading ? "Loading..." : title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(foregroundColor)
                    .animation(.easeInOut(duration: 0.2), value: isLoading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .scaleEffect(isPressed ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled || isLoading)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading, please wait" : "Double tap to \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Loading Button Style
enum LoadingButtonStyle {
    case primary
    case secondary
}

// MARK: - Preview
struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            LoadingButton(
                title: "Sign In",
                isLoading: false,
                isEnabled: true,
                style: .primary
            ) {
                print("Sign In tapped")
            }
            
            LoadingButton(
                title: "Sign In",
                isLoading: true,
                isEnabled: true,
                style: .primary
            ) {
                print("Sign In tapped")
            }
            
            LoadingButton(
                title: "Sign In",
                isLoading: false,
                isEnabled: false,
                style: .primary
            ) {
                print("Sign In tapped")
            }
            
            LoadingButton(
                title: "Create Account",
                isLoading: false,
                isEnabled: true,
                style: .secondary
            ) {
                print("Create Account tapped")
            }
            
            LoadingButton(
                title: "Create Account",
                isLoading: true,
                isEnabled: true,
                style: .secondary
            ) {
                print("Create Account tapped")
            }
        }
        .padding()
        .frame(width: 300)
    }
}