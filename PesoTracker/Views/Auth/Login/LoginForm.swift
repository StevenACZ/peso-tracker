import SwiftUI

struct LoginForm: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Email field
            AuthTextField(
                text: $authViewModel.loginEmail,
                placeholder: "Dirección de correo electrónico"
            )
            
            // Password field
            AuthTextField(
                text: $authViewModel.loginPassword,
                placeholder: "Contraseña",
                isSecure: true
            ) {
                if authViewModel.isLoginFormValid {
                    onSubmit()
                }
            }
            
            // Forgot password link
            HStack {
                Spacer()
                Button("¿Olvidaste tu contraseña?") {
                    // TODO: Implement forgot password
                }
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    LoginForm(authViewModel: AuthViewModel(), onSubmit: {})
}