import SwiftUI

struct AuthLoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    let switchToRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                LoginHeader()
                LoginForm(authViewModel: authViewModel) {
                    Task {
                        await authViewModel.login()
                    }
                }
                LoginActions(
                    authViewModel: authViewModel,
                    switchToRegister: switchToRegister
                )
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .alert("Error de Autenticación", isPresented: $authViewModel.showError) {
            Button("OK") {
                authViewModel.showError = false
            }
        } message: {
            Text(authViewModel.errorMessage ?? "Error desconocido")
        }
    }
}

#Preview {
    AuthLoginView(switchToRegister: {})
}