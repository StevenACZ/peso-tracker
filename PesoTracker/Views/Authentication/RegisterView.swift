//
//  RegisterView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, email, password, confirmPassword
    }
    
    private var canRegister: Bool {
        !viewModel.username.isEmpty &&
        viewModel.isValidEmail &&
        !viewModel.password.isEmpty &&
        viewModel.password == confirmPassword &&
        viewModel.password.count >= 6
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(NSColor.windowBackgroundColor)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor)
                            
                            Text("Crear nueva cuenta")
                                .font(.title)
                                .bold()
                            
                            Text("Únete a PesoTracker y comienza tu viaje")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Form
                        VStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.secondary)
                                    TextField("Nombre de usuario", text: $viewModel.username)
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .username)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .email
                                        }
                                }
                                .authenticationField()
                                
                                if !viewModel.username.isEmpty && viewModel.username.count < 3 {
                                    Text("El nombre debe tener al menos 3 caracteres")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.secondary)
                                    TextField("Email", text: $viewModel.email)
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .email)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .password
                                        }
                                }
                                .authenticationField()
                                
                                if !viewModel.email.isEmpty && !viewModel.isValidEmail {
                                    Text("Por favor ingresa un email válido")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.secondary)
                                    SecureField("Contraseña", text: $viewModel.password)
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .confirmPassword
                                        }
                                }
                                .authenticationField()
                                
                                if !viewModel.password.isEmpty && viewModel.password.count < 6 {
                                    Text("La contraseña debe tener al menos 6 caracteres")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.secondary)
                                    SecureField("Confirmar Contraseña", text: $confirmPassword)
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .confirmPassword)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            if canRegister {
                                                Task { await viewModel.register() }
                                            }
                                        }
                                }
                                .authenticationField()
                                
                                if !confirmPassword.isEmpty && viewModel.password != confirmPassword {
                                    Text("Las contraseñas no coinciden")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Action Button
                            Button("Crear Cuenta") {
                                Task { await viewModel.register() }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!canRegister || viewModel.isLoading)
                            .opacity(canRegister ? 1 : 0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .padding(.top, 10)
                        }
                        .frame(maxWidth: 380)
                        .padding(30)
                        
                        // Loading Indicator
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.2)
                                .padding(.top, 20)
                        }
                    }
                    Spacer()
                    // Back to Login
                    Button("¿Ya tienes una cuenta? Inicia sesión") {
                        viewModel.switchToLogin()
                    }
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: 420)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .alert("Error", isPresented: $viewModel.showErrorAlert) {
                    Button("OK") { viewModel.dismissErrorAlert() }
                } message: {
                    Text(viewModel.errorMessage ?? "Ha ocurrido un error")
                }
            }
        }
    }
}
