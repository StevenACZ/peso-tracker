import SwiftUI

struct RegisterForm: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Username field
            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre de usuario")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.registerUsername,
                    placeholder: "Ingresa tu nombre de usuario",
                    errorMessage: authViewModel.usernameValidationError,
                    validationState: authViewModel.usernameValidationState,
                    isValidating: authViewModel.isCheckingUsernameAvailability
                )
            }
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Correo electrónico")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.registerEmail,
                    placeholder: "Ingresa tu correo electrónico",
                    errorMessage: authViewModel.emailValidationError,
                    validationState: authViewModel.emailValidationState,
                    isValidating: authViewModel.isCheckingEmailAvailability
                )
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Contraseña")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.registerPassword,
                    placeholder: "Ingresa tu contraseña",
                    isSecure: true,
                    onSubmit: {
                        if authViewModel.isRegisterFormValid {
                            onSubmit()
                        }
                    },
                    errorMessage: authViewModel.passwordValidationError,
                    validationState: authViewModel.passwordValidationState
                )
            }
            
            // Confirm password field (optional, but good UX)
            if !authViewModel.registerPassword.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirmar contraseña")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    AuthTextField(
                        text: $authViewModel.confirmPassword,
                        placeholder: "Confirma tu contraseña",
                        isSecure: true,
                        onSubmit: {
                            if authViewModel.isRegisterFormValid {
                                onSubmit()
                            }
                        },
                        errorMessage: authViewModel.confirmPasswordError,
                        validationState: authViewModel.confirmPasswordError == nil && !authViewModel.confirmPassword.isEmpty ? .valid : (authViewModel.confirmPasswordError != nil ? .invalid : .none)
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.3), value: authViewModel.registerPassword.isEmpty)
            }
        }
    }
}

#Preview {
    RegisterForm(authViewModel: AuthViewModel(), onSubmit: {})
}