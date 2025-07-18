//
//  RegisterView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

// MARK: - Register View
struct RegisterView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 32) {
            Text("Crear Cuenta")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Nombre de usuario", text: $viewModel.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Contraseña", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Confirmar Contraseña", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Crear Cuenta") {
                    Task { await viewModel.register() }
                }
                .buttonStyle(PrimaryButtonStyle(color: .green))
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
        !viewModel.username.isEmpty &&
        !viewModel.email.isEmpty &&
        !viewModel.password.isEmpty &&
        viewModel.password == confirmPassword
    }
}
