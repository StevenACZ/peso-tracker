import SwiftUI

struct AuthButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let backgroundColor: Color?
    let action: () -> Void
    
    init(title: String, isLoading: Bool, isEnabled: Bool, backgroundColor: Color? = nil, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        CustomButton(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                isEnabled && !isLoading ?
                LinearGradient(colors: [backgroundColor ?? Color.green, (backgroundColor ?? Color.green).opacity(0.9)], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [(backgroundColor ?? Color.green).opacity(0.4), (backgroundColor ?? Color.green).opacity(0.3)], startPoint: .top, endPoint: .bottom)
            )
            .foregroundColor(.white)
            .cornerRadius(6)
            .shadow(color: (backgroundColor ?? Color.green).opacity(0.3), radius: isEnabled ? 4 : 0, x: 0, y: 2)
        }
        .disabled(!isEnabled || isLoading)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthButton(
            title: "Enabled Button",
            isLoading: false,
            isEnabled: true,
            action: {}
        )
        
        AuthButton(
            title: "Loading...",
            isLoading: true,
            isEnabled: true,
            action: {}
        )
        
        AuthButton(
            title: "Disabled Button",
            isLoading: false,
            isEnabled: false,
            action: {}
        )
    }
    .padding()
}