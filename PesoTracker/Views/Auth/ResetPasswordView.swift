import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let switchToLogin: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    // Header
                    ResetPasswordHeader()
                    
                    // Form
                    ResetPasswordForm(
                        passwordRecoveryViewModel: passwordRecoveryViewModel,
                        onSubmit: {
                            Task {
                                await passwordRecoveryViewModel.resetPasswordWithCode()
                            }
                        }
                    )
                    
                    // Actions
                    ResetPasswordActions(
                        passwordRecoveryViewModel: passwordRecoveryViewModel,
                        switchToLogin: switchToLogin,
                        onSubmit: {
                            Task {
                                await passwordRecoveryViewModel.resetPasswordWithCode()
                            }
                        }
                    )
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .disabled(passwordRecoveryViewModel.showError || passwordRecoveryViewModel.showSuccessMessage)
            .opacity(passwordRecoveryViewModel.showError || passwordRecoveryViewModel.showSuccessMessage ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: passwordRecoveryViewModel.showError)
            .animation(.easeInOut(duration: 0.2), value: passwordRecoveryViewModel.showSuccessMessage)
            
            // Error Modal
            if passwordRecoveryViewModel.showError {
                UniversalErrorModal(
                    title: "Error al Cambiar Contraseña",
                    message: passwordRecoveryViewModel.errorMessage ?? "Ha ocurrido un error inesperado",
                    isPresented: $passwordRecoveryViewModel.showError,
                    canRetry: false,
                    onDismiss: {
                        passwordRecoveryViewModel.dismissError()
                    },
                    onRetry: {}
                )
            }
            
            // Success Message
            if passwordRecoveryViewModel.showSuccessMessage {
                SuccessMessageOverlay(
                    message: passwordRecoveryViewModel.successMessage,
                    onComplete: {
                        // Auto-navigate to login after success message
                        switchToLogin()
                    }
                )
            }
        }
        .onAppear {
            // Validate that we're in the correct step and have required data
            if passwordRecoveryViewModel.currentStep != .resetPassword || !passwordRecoveryViewModel.validateFlowIntegrity() {
                // Invalid state, return to login and reset
                passwordRecoveryViewModel.resetFlow()
                switchToLogin()
            }
            // Handle edge cases
            passwordRecoveryViewModel.handleNavigationEdgeCase()
        }
    }
}

// MARK: - Header Component
struct ResetPasswordHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Nueva Contraseña")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Establece tu nueva contraseña")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Form Component
struct ResetPasswordForm: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // New Password Field
            AuthTextField(
                text: $passwordRecoveryViewModel.newPassword,
                placeholder: "Nueva contraseña",
                isSecure: true,
                onSubmit: {
                    // Move focus to confirm password or submit if valid
                    if passwordRecoveryViewModel.canResetPassword {
                        onSubmit()
                    }
                },
                errorMessage: nil,
                validationState: passwordRecoveryViewModel.isPasswordValid ? .valid : .none
            )
            
            // Confirm Password Field
            AuthTextField(
                text: $passwordRecoveryViewModel.confirmPassword,
                placeholder: "Repetir contraseña",
                isSecure: true,
                onSubmit: {
                    if passwordRecoveryViewModel.canResetPassword {
                        onSubmit()
                    }
                },
                errorMessage: passwordRecoveryViewModel.passwordsMatch ? nil : "Las contraseñas no coinciden",
                validationState: passwordRecoveryViewModel.passwordsMatch && !passwordRecoveryViewModel.confirmPassword.isEmpty ? .valid : .none
            )
        }
    }
}

// MARK: - Actions Component
struct ResetPasswordActions: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let switchToLogin: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Reset password button
            AuthButton(
                title: passwordRecoveryViewModel.isLoading ? "Cambiando contraseña..." : "Cambiar contraseña",
                isLoading: passwordRecoveryViewModel.isLoading,
                isEnabled: passwordRecoveryViewModel.canResetPassword
            ) {
                onSubmit()
            }
            
            // Back to login link
            HStack(spacing: 4) {
                Text("¿Quieres volver?")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                CustomButton(action: {
                    // Only allow cancellation if not currently loading
                    if !passwordRecoveryViewModel.isLoading {
                        passwordRecoveryViewModel.cancelFlow()
                        switchToLogin()
                    }
                }) {
                    Text("Volver al login")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
        }
    }
}



// MARK: - Success Message Overlay
struct SuccessMessageOverlay: View {
    let message: String
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Success message card
            VStack(spacing: 16) {
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                
                // Success message
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Animate in with a slight delay for smoother appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
            
            // Auto-dismiss after 2 seconds (matching the ViewModel duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scale = 0.9
                    opacity = 0.0
                }
                
                // Call completion after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    ResetPasswordView(
        passwordRecoveryViewModel: PasswordRecoveryViewModel(),
        switchToLogin: {}
    )
}