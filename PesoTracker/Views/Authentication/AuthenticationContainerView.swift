//
//  AuthenticationContainerView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct AuthenticationContainerView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        VStack {
            // Simple navigation
            if viewModel.currentFlow != .welcome {
                HStack {
                    Button("← Atrás") {
                        viewModel.switchToWelcome()
                    }
                    
                    Spacer()
                    
                    Button(viewModel.currentFlow == .login ? "Crear Cuenta" : "Iniciar Sesión") {
                        if viewModel.currentFlow == .login {
                            viewModel.switchToRegister()
                        } else {
                            viewModel.switchToLogin()
                        }
                    }
                    .foregroundColor(.blue)
                }
                .padding()
            }
            
            // Main content
            switch viewModel.currentFlow {
            case .welcome:
                WelcomeView(viewModel: viewModel)
            case .login:
                LoginView(viewModel: viewModel)
            case .register:
                RegisterView(viewModel: viewModel)
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.dismissErrorAlert()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
