import SwiftUI

struct LoginActions: View {
    @ObservedObject var authViewModel: AuthViewModel
    let switchToRegister: () -> Void
    let switchToForgotPassword: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Login button
            AuthButton(
                title: authViewModel.isLoading ? "Iniciando..." : "Iniciar sesión",
                isLoading: authViewModel.isLoading,
                isEnabled: authViewModel.isLoginFormValid
            ) {
                Task {
                    await authViewModel.login()
                }
            }
            
            // Forgot password link
            CustomButton(action: {
                switchToForgotPassword()
            }) {
                Text("Olvidé mi contraseña")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.blue)
            
            // Register link
            HStack(spacing: 4) {
                Text("¿No tienes una cuenta?")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                CustomButton(action: {
                    switchToRegister()
                }) {
                    Text("Regístrate")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                
            }
        }
    }
}

#Preview {
    LoginActions(
        authViewModel: AuthViewModel(),
        switchToRegister: {},
        switchToForgotPassword: {}
    )
}