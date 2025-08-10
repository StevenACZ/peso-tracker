import SwiftUI

struct CodeVerificationView: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let switchToLogin: () -> Void
    let switchToResetPassword: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 32) {
                    // Header with icon
                    CodeVerificationHeader(email: passwordRecoveryViewModel.email)
                    
                    // Code input form
                    CodeVerificationForm(
                        passwordRecoveryViewModel: passwordRecoveryViewModel,
                        onSubmit: {
                            Task {
                                await passwordRecoveryViewModel.verifyResetCode()
                            }
                        }
                    )
                    
                    // Actions
                    CodeVerificationActions(
                        passwordRecoveryViewModel: passwordRecoveryViewModel,
                        switchToLogin: switchToLogin,
                        onSubmit: {
                            Task {
                                await passwordRecoveryViewModel.verifyResetCode()
                            }
                        }
                    )
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .disabled(passwordRecoveryViewModel.showError || passwordRecoveryViewModel.isLoading)
            .opacity(passwordRecoveryViewModel.showError ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: passwordRecoveryViewModel.showError)
            
            // Error Modal with Retry Option
            if passwordRecoveryViewModel.showError {
                ErrorModalWithRetry(
                    title: "Error de Verificación",
                    message: passwordRecoveryViewModel.errorMessage ?? "Ha ocurrido un error inesperado",
                    isPresented: $passwordRecoveryViewModel.showError,
                    canRetry: passwordRecoveryViewModel.canRetry,
                    onDismiss: {
                        passwordRecoveryViewModel.dismissError()
                    },
                    onRetry: {
                        Task {
                            await passwordRecoveryViewModel.retryCurrentOperation()
                        }
                    }
                )
            }
            
            // Success Modal with Check Animation
            if passwordRecoveryViewModel.showSuccessMessage {
                SuccessCheckModal(
                    message: passwordRecoveryViewModel.successMessage,
                    isPresented: $passwordRecoveryViewModel.showSuccessMessage
                )
            }
        }
        .onAppear {
            // Validate that we're in the correct step for this view
            if passwordRecoveryViewModel.currentStep != .verifyCode {
                passwordRecoveryViewModel.resetFlow()
                switchToLogin()
            }
            // Handle edge cases
            passwordRecoveryViewModel.handleEdgeCases()
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
struct CodeVerificationHeader: View {
    let email: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Email icon with app color
            ZStack {
                Circle()
                    .fill(Color(hex: "34c956").opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "34c956"))
            }
            
            VStack(spacing: 12) {
                Text("Verificar Código")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    Text("Hemos enviado un código de 6 dígitos a:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(email)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "34c956"))
                    
                    Text("Revisa tu bandeja de entrada y spam")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - Form Component
struct CodeVerificationForm: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            AuthTextField(
                text: $passwordRecoveryViewModel.verificationCode,
                placeholder: "Código de 6 dígitos",
                onSubmit: {
                    if passwordRecoveryViewModel.isCodeValid {
                        onSubmit()
                    }
                },
                errorMessage: passwordRecoveryViewModel.codeValidationError,
                validationState: passwordRecoveryViewModel.codeValidationState
            )
            
            if !passwordRecoveryViewModel.verificationCode.isEmpty {
                Text("Ingresa solo los 6 dígitos del código")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Actions Component
struct CodeVerificationActions: View {
    @ObservedObject var passwordRecoveryViewModel: PasswordRecoveryViewModel
    let switchToLogin: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Verify button with app color
            AuthButton(
                title: passwordRecoveryViewModel.isLoading ? "Verificando..." : "Verificar",
                isLoading: passwordRecoveryViewModel.isLoading,
                isEnabled: passwordRecoveryViewModel.isCodeValid,
                backgroundColor: Color(hex: "34c956")
            ) {
                onSubmit()
            }
            
            VStack(spacing: 12) {
                // Resend code option
                HStack(spacing: 4) {
                    Text("¿No recibiste el código?")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    CustomButton(action: {
                        // Request new code
                        Task {
                            passwordRecoveryViewModel.currentStep = .requestCode
                            await passwordRecoveryViewModel.requestPasswordReset()
                        }
                    }) {
                        Text("Reenviar")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "34c956"))
                }
                
                // Back to login link
                HStack(spacing: 4) {
                    Text("¿Quieres cancelar?")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    CustomButton(action: {
                        // Only allow cancellation if not currently loading
                        if passwordRecoveryViewModel.canNavigateBack {
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
}

// MARK: - Success Check Modal
struct SuccessCheckModal: View {
    let message: String
    @Binding var isPresented: Bool
    @State private var showCheck = false
    @State private var checkScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.2), value: isPresented)
            
            VStack(spacing: 24) {
                // Animated check icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "34c956"))
                        .frame(width: 80, height: 80)
                        .scaleEffect(showCheck ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showCheck)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(checkScale)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2), value: checkScale)
                }
                
                Text(message)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .opacity(showCheck ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.3).delay(0.4), value: showCheck)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(isPresented ? 1.0 : 0.9)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        }
        .onAppear {
            showCheck = true
            checkScale = 1.0
        }
    }
}


#Preview {
    CodeVerificationView(
        passwordRecoveryViewModel: PasswordRecoveryViewModel(),
        switchToLogin: {},
        switchToResetPassword: {}
    )
}