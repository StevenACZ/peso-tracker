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
                    placeholder: "Ingresa tu nombre de usuario"
                )
                
                if let usernameError = authViewModel.usernameValidationError {
                    Text(usernameError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Correo electrónico")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.registerEmail,
                    placeholder: "Ingresa tu correo electrónico"
                )
                
                if let emailError = authViewModel.emailValidationError {
                    Text(emailError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Contraseña")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                AuthTextField(
                    text: $authViewModel.registerPassword,
                    placeholder: "Ingresa tu contraseña",
                    isSecure: true
                ) {
                    if authViewModel.isRegisterFormValid {
                        onSubmit()
                    }
                }
                
                if let passwordError = authViewModel.passwordValidationError {
                    Text(passwordError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    RegisterForm(authViewModel: AuthViewModel(), onSubmit: {})
}