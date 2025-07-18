//
//  MessageBanner.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

/// Modern message banner for success and error states
struct MessageBanner: View {
    
    // MARK: - Properties
    let message: String
    let type: MessageType
    let isVisible: Bool
    let onDismiss: (() -> Void)?
    
    // MARK: - State
    @State private var offset: CGFloat = -100
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        switch type {
        case .success:
            return .green.opacity(0.9)
        case .error:
            return .red.opacity(0.9)
        case .info:
            return .blue.opacity(0.9)
        }
    }
    
    private var iconName: String {
        switch type {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    // MARK: - Initializer
    init(
        message: String,
        type: MessageType,
        isVisible: Bool,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.type = type
        self.isVisible = isVisible
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                
                // Message
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Dismiss button
                if onDismiss != nil {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onDismiss?()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Dismiss message")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(
                        color: backgroundColor.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .offset(y: offset)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    offset = 0
                }
            }
            .onDisappear {
                offset = -100
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(type.rawValue): \(message)")
        }
    }
}

// MARK: - Message Type
enum MessageType: String, CaseIterable {
    case success = "Success"
    case error = "Error"
    case info = "Info"
}

// MARK: - Preview
struct MessageBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MessageBanner(
                message: "Account created successfully!",
                type: .success,
                isVisible: true
            ) {
                print("Dismiss success")
            }
            
            MessageBanner(
                message: "Invalid email or password. Please try again.",
                type: .error,
                isVisible: true
            ) {
                print("Dismiss error")
            }
            
            MessageBanner(
                message: "Please check your internet connection.",
                type: .info,
                isVisible: true
            ) {
                print("Dismiss info")
            }
        }
        .padding()
        .frame(width: 400)
    }
}