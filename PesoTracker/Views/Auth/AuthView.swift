import SwiftUI

struct AuthView: View {
    @State private var isShowingLogin = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Top header
            AuthHeader()
            
            // Main content area
            mainContent
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            // Adaptive background
            Color(NSColor.windowBackgroundColor)
            
            // Content
            if isShowingLogin {
                AuthLoginView(switchToRegister: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingLogin = false
                    }
                })
            } else {
                AuthRegisterView(switchToLogin: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingLogin = true
                    }
                })
            }
        }
    }
}

#Preview {
    AuthView()
}