//
//  LoginView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 32) {
            Text("Iniciar Sesión")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(UIKeyboardType.emailAddress)
                    .autocapitalization(.none)

                SecureField("Contraseña", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Iniciar Sesión") {
                    Task { await viewModel.login() }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading || !isFormValid)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .frame(maxWidth: 280)
        }
        .padding()
    }

    private var isFormValid: Bool {
        !viewModel.email.isEmpty && !viewModel.password.isEmpty
    }
}
