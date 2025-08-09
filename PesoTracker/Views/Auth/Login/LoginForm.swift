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