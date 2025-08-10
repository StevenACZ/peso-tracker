import SwiftUI

struct LoginForm: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
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
            
            // Forgot password link
            HStack {
                Spacer()
                CustomButton(action: {
                    // TODO: Implement forgot password
                }) {
                    Text("¿Olvidaste tu contraseña?")
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
                
            }
        }
    }
}

#Preview {
    LoginForm(authViewModel: AuthViewModel(), onSubmit: {})
}