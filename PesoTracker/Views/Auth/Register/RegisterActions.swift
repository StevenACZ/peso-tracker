import SwiftUI

struct RegisterActions: View {
    @ObservedObject var authViewModel: AuthViewModel
    let switchToLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Register button
            AuthButton(
                title: authViewModel.isLoading ? "Creando cuenta..." : "Registrarse",
                isLoading: authViewModel.isLoading,
                isEnabled: authViewModel.isRegisterFormValid
            ) {
                Task {
                    await authViewModel.register()
                }
            }
            
            // Login link
            HStack(spacing: 4) {
                Text("¿Ya tienes una cuenta?")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Button("Iniciar sesión") {
                    switchToLogin()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    RegisterActions(
        authViewModel: AuthViewModel(),
        switchToLogin: {}
    )
}