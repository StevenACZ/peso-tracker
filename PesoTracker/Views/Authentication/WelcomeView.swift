//
//  WelcomeView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

// MARK: - Welcome View
struct WelcomeView: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 40) {
            // Logo and title
            VStack(spacing: 16) {
                Image(systemName: "scalemass")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("PesoTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Rastrea tu peso fácilmente")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            // Action buttons
            VStack(spacing: 16) {
                Button("Iniciar Sesión") {
                    viewModel.switchToLogin()
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Crear Cuenta") {
                    viewModel.switchToRegister()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding()
    }
}
