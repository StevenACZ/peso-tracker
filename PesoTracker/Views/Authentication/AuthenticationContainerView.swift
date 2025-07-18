//
//  AuthenticationContainerView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

// MARK: - Main Container View
struct AuthenticationContainerView: View {
    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            if viewModel.currentFlow != .welcome {
                NavigationBar(viewModel: viewModel)
            }

            // Main content
            Spacer()

            switch viewModel.currentFlow {
            case .welcome:
                WelcomeView(viewModel: viewModel)
            case .login:
                LoginView(viewModel: viewModel)
            case .register:
                RegisterView(viewModel: viewModel)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
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

// MARK: - Navigation Bar
struct NavigationBar: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        HStack {
            Button("← Atrás") {
                viewModel.switchToWelcome()
            }
            .foregroundColor(.blue)

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
}
