import SwiftUI

struct AuthRegisterView: View {
    @StateObject private var authViewModel = AuthViewModel()
    let switchToLogin: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    UniversalAuthHeader.register
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
            .disabled(authViewModel.showErrorModal)
            .opacity(authViewModel.showErrorModal ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: authViewModel.showErrorModal)
            
            // Error Modal
            if authViewModel.showErrorModal {
                UniversalErrorModal(
                    title: "Error de Registro",
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
    AuthRegisterView(switchToLogin: {})
}