import SwiftUI

struct AuthLoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    let switchToRegister: () -> Void
    let switchToForgotPassword: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    UniversalAuthHeader.login
                    LoginForm(authViewModel: authViewModel) {
                        Task {
                            await authViewModel.login()
                        }
                    }
                    LoginActions(
                        authViewModel: authViewModel,
                        switchToRegister: switchToRegister,
                        switchToForgotPassword: switchToForgotPassword
                    )
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .disabled(authViewModel.showErrorModal)
            .opacity(authViewModel.showErrorModal ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: authViewModel.showErrorModal)
            
            // Error Modal
            if authViewModel.showErrorModal {
                UniversalErrorModal(
                    title: "Error de Inicio de Sesión",
                    message: authViewModel.errorModalMessage,
                    isPresented: $authViewModel.showErrorModal,
                    onDismiss: {
                        authViewModel.dismissErrorModal()
                    }
                )
            }
        }
    }
}

#Preview {
    AuthLoginView(switchToRegister: {}, switchToForgotPassword: {})
}