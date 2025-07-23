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
        ZStack {
            // Background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation header
                if viewModel.currentFlow != .welcome {
                    ZStack {
                        HStack {
                            Button {
                                viewModel.switchToWelcome()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Atrás")
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                        }
                        
                        // Center text
                        Text(viewModel.currentFlow == .login ? "Iniciar Sesión" : "Crear Cuenta")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        // Right button
                        HStack {
                            Spacer()
                            
                            Button(viewModel.currentFlow == .login ? "Crear Cuenta" : "Iniciar Sesión") {
                                if viewModel.currentFlow == .login {
                                    viewModel.switchToRegister()
                                } else {
                                    viewModel.switchToLogin()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(NSColor.windowBackgroundColor))
                    .overlay(
                        Divider()
                            .opacity(0.5)
                        , alignment: .bottom
                    )
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
        }
        .frame(width: 400, height: 680)
        .fixedSize(horizontal: true, vertical: true)
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
