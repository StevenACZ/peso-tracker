import SwiftUI

struct LoginActions: View {
    @ObservedObject var authViewModel: AuthViewModel
    let switchToRegister: () -> Void
    
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
            
            // Register link
            HStack(spacing: 4) {
                Text("¿No tienes una cuenta?")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Button("Regístrate") {
                    switchToRegister()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    LoginActions(
        authViewModel: AuthViewModel(),
        switchToRegister: {}
    )
}