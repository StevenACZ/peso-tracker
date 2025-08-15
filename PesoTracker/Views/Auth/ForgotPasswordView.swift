import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let switchToLogin: () -> Void
    let switchToResetPassword: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    // Header
                    ForgotPasswordHeader()
                    
                    // Form
                    ForgotPasswordForm(
                        passwordRecoveryViewModel: passwordRecoveryViewModel,
                        onSubmit: {
                            Task {
                                await passwordRecoveryViewModel.requestPasswordReset()
                            }
                        }
                    )
                    
                    // Actions
                    ForgotPasswordActions(
                        passwordRecoveryViewModel: passwordRecoveryViewModel,
                        switchToLogin: switchToLogin,
                        onSubmit: {
                            Task {
                                await passwordRecoveryViewModel.requestPasswordReset()
                            }
                        }
                    )
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .disabled(passwordRecoveryViewModel.showError || passwordRecoveryViewModel.showSuccessMessage)
            .opacity(passwordRecoveryViewModel.showError ? 0.7 : passwordRecoveryViewModel.showSuccessMessage ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: passwordRecoveryViewModel.showError)
            .animation(.easeInOut(duration: 0.3), value: passwordRecoveryViewModel.showSuccessMessage)
            
            // Error Modal
            if passwordRecoveryViewModel.showError {
                UniversalErrorModal(
                    title: "Error de Recuperación",
                    message: passwordRecoveryViewModel.errorMessage ?? "Ha ocurrido un error inesperado",
                    isPresented: $passwordRecoveryViewModel.showError,
                    canRetry: false,
                    onDismiss: {
                        passwordRecoveryViewModel.dismissError()
                    },
                    onRetry: {}
                )
            }
            
            // Success Message Modal
            if passwordRecoveryViewModel.showSuccessMessage {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.2), value: passwordRecoveryViewModel.showSuccessMessage)
                
                VStack(spacing: 24) {
                    // Success icon with app color
                    ZStack {
                        Circle()
                            .fill(Color(hex: "34c956"))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(passwordRecoveryViewModel.successMessage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .scaleEffect(passwordRecoveryViewModel.showSuccessMessage ? 1.0 : 0.9)
                .opacity(passwordRecoveryViewModel.showSuccessMessage ? 1.0 : 0.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: passwordRecoveryViewModel.showSuccessMessage)
            }
        }
        .onAppear {
            // Validate that we're in the correct step for this view
            if passwordRecoveryViewModel.currentStep != .requestCode {
                passwordRecoveryViewModel.resetFlow()
            }
            // Handle edge cases
            passwordRecoveryViewModel.handleNavigationEdgeCase()
        }
        .onChange(of: passwordRecoveryViewModel.currentStep) { oldStep, newStep in
            // Handle automatic navigation to reset password view
            if newStep == .resetPassword {
                switchToResetPassword()
            }
        }
    }
}


// MARK: - Header Component
struct ForgotPasswordHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Recuperar Contraseña")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Ingresa tu email para recibir un código de recuperación")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Form Component
struct ForgotPasswordForm: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            AuthTextField(
                text: $passwordRecoveryViewModel.email,
                placeholder: "Email",
                onSubmit: {
                    if passwordRecoveryViewModel.canSendCode {
                        onSubmit()
                    }
                },
                errorMessage: nil,
                validationState: passwordRecoveryViewModel.isEmailValid ? .valid : .none
            )
        }
    }
}

// MARK: - Actions Component
struct ForgotPasswordActions: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let switchToLogin: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Send code button
            AuthButton(
                title: passwordRecoveryViewModel.isLoading ? "Enviando..." : "Enviar código",
                isLoading: passwordRecoveryViewModel.isLoading,
                isEnabled: passwordRecoveryViewModel.canSendCode
            ) {
                onSubmit()
            }
            
            // Back to login link
            HStack(spacing: 4) {
                Text("¿Recordaste tu contraseña?")
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



#Preview {
    ForgotPasswordView(
        passwordRecoveryViewModel: PasswordRecoveryViewModel(),
        switchToLogin: {},
        switchToResetPassword: {}
    )
}