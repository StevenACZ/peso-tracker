import SwiftUI

struct LoginForm: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Email field
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Correo electrónico")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.loginEmail,
                    placeholder: "Ingresa tu correo electrónico",
                    errorMessage: authViewModel.loginEmailError,
                    validationState: authViewModel.loginEmailValidationState
                )
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Contraseña")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.loginPassword,
                    placeholder: "Ingresa tu contraseña",
                    isSecure: true,
                    onSubmit: {
                        if authViewModel.isLoginFormValid {
                            onSubmit()
                        }
                    },
                    errorMessage: authViewModel.loginPasswordError,
                    validationState: authViewModel.loginPasswordValidationState
                )
            }
        }
    }
}

#Preview {
    LoginForm(authViewModel: AuthViewModel(), onSubmit: {})
}