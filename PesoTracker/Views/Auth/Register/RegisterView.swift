import SwiftUI

struct AuthRegisterView: View {
    @StateObject private var authViewModel = AuthViewModel()
    let switchToLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                RegisterHeader()
                RegisterForm(authViewModel: authViewModel) {
                    Task {
                        await authViewModel.register()
                    }
                }
                RegisterActions(
                    authViewModel: authViewModel,
                    switchToLogin: switchToLogin
                )
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .alert("Error de Registro", isPresented: $authViewModel.showError) {
            Button("OK") {
                authViewModel.showError = false
            }
        } message: {
            Text(authViewModel.errorMessage ?? "Error desconocido")
        }
    }
}

#Preview {
    AuthRegisterView(switchToLogin: {})
}