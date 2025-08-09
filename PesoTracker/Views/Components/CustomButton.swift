import SwiftUI
import AppKit

/// CustomButton is the standard button component for PesoTracker
/// Provides consistent hover cursor behavior and maintains all SwiftUI Button functionality
struct CustomButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content
    
    @State private var isHovered = false
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            content()
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .onAppear {
            // Ensure cursor is reset when button appears
            if !isHovered {
                NSCursor.arrow.set()
            }
        }
        .onDisappear {
            // Reset cursor when button disappears
            NSCursor.arrow.set()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CustomButton(action: {
            print("Primary button tapped")
        }) {
            Text("Primary Button")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        
        CustomButton(action: {
            print("Secondary button tapped")
        }) {
            Text("Secondary Button")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.secondary)
                .cornerRadius(8)
        }
        
        CustomButton(action: {}) {
            HStack {
                Image(systemName: "photo")
                Text("Button with Icon")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(6)
        }
    }
    .padding()
}