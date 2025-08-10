import SwiftUI

struct AuthView: View {
    @State private var currentView: AuthViewType = .login
    @StateObject private var passwordRecoveryViewModel = PasswordRecoveryViewModel()
    
    enum AuthViewType {
        case login
        case register
        case forgotPassword
        case codeVerification
        case resetPassword
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top header
            AuthHeader()
            
            // Main content area
            mainContent
        }
        .ignoresSafeArea()
        .onChange(of: passwordRecoveryViewModel.state.shouldNavigateToResetPassword) { oldValue, newValue in
            if newValue {
                // Add a small delay to ensure smooth transition after success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .resetPassword
                    }
                    passwordRecoveryViewModel.clearNavigationFlags()
                }
            }
        }
        .onChange(of: passwordRecoveryViewModel.state.shouldNavigateToLogin) { oldValue, newValue in
            if newValue {
                // Add a small delay to ensure smooth transition after success message
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    passwordRecoveryViewModel.resetFlow()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .login
                    }
                    passwordRecoveryViewModel.clearNavigationFlags()
                }
            }
        }
        .onChange(of: passwordRecoveryViewModel.state.currentStep) { oldStep, newStep in
            // Validate navigation transitions and handle edge cases
            passwordRecoveryViewModel.handleNavigationEdgeCase()
            
            // Handle navigation based on recovery step
            switch newStep {
            case .verifyCode:
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentView = .codeVerification
                }
            case .resetPassword:
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentView = .resetPassword
                }
            case .completed:
                // Clean up and return to login after successful password reset
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    passwordRecoveryViewModel.resetFlow()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .login
                    }
                }
            case .requestCode:
                // Stay on current view or navigate to forgot password if needed
                break
            }
        }
        .onAppear {
            // Validate flow integrity when view appears
            if !passwordRecoveryViewModel.validateFlowIntegrity() {
                passwordRecoveryViewModel.resetFlow()
            }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            // Adaptive background
            Color(NSColor.windowBackgroundColor)
            
            // Content
            switch currentView {
            case .login:
                AuthLoginView(
                    switchToRegister: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .register
                        }
                    },
                    switchToForgotPassword: {
                        // Reset the password recovery flow when starting
                        passwordRecoveryViewModel.resetFlow()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .forgotPassword
                        }
                    }
                )
            case .register:
                AuthRegisterView(switchToLogin: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .login
                    }
                })
            case .forgotPassword:
                ForgotPasswordView(
                    passwordRecoveryViewModel: passwordRecoveryViewModel,
                    switchToLogin: {
                        // Clean up state when returning to login
                        passwordRecoveryViewModel.resetFlow()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .login
                        }
                    },
                    switchToResetPassword: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .resetPassword
                        }
                    }
                )
            case .codeVerification:
                CodeVerificationView(
                    passwordRecoveryViewModel: passwordRecoveryViewModel,
                    switchToLogin: {
                        // Clean up state when returning to login
                        passwordRecoveryViewModel.resetFlow()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .login
                        }
                    },
                    switchToResetPassword: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .resetPassword
                        }
                    }
                )
            case .resetPassword:
                ResetPasswordView(
                    passwordRecoveryViewModel: passwordRecoveryViewModel,
                    switchToLogin: {
                        // Clean up state when returning to login after successful reset
                        passwordRecoveryViewModel.resetFlow()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentView = .login
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    AuthView()
}