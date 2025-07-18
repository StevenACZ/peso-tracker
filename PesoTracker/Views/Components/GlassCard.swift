//
//  GlassCard.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

/// Modern glass-morphism card container with blur effect
struct GlassCard<Content: View>: View {
    
    // MARK: - Properties
    let content: Content
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    // MARK: - Initializer
    init(
        padding: EdgeInsets = EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    // MARK: - Body
    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Glass background with blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.2),
                                            .white.opacity(0.1),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Subtle inner glow
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            RadialGradient(
                                colors: [
                                    .accentColor.opacity(0.05),
                                    .clear
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                }
            )
            .shadow(
                color: .black.opacity(0.1),
                radius: shadowRadius,
                x: 0,
                y: 10
            )
    }
}

// MARK: - Preview
struct GlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GlassCard {
                VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        ValidationTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: Binding.constant("test@example.com")
                        )
                        
                        ValidationTextField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: Binding.constant("password"),
                            isSecure: true,
                            showSecureText: Binding.constant(false)
                        )
                    }
                    
                    LoadingButton(
                        title: "Sign In",
                        isLoading: false,
                        style: .primary
                    ) {
                        print("Sign In")
                    }
                }
            }
            .frame(width: 400)
        }
        .frame(width: 600, height: 500)
    }
}