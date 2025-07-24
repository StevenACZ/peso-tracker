//
//  LoginView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.linearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .symbolEffect(.bounce, value: viewModel.email)
                        
                        VStack(spacing: 8) {
                            Text("¡Bienvenido de vuelta!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Text("Ingresa tus credenciales para continuar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                        
                        // Form Section
                        VStack(spacing: 24) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 16))
                                    
                                    TextField("", text: $viewModel.email)
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .email)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .password }
                                }
                                .authenticationField()
                                
                                if !viewModel.email.isEmpty && !viewModel.isValidEmail {
                                    Label("Por favor ingresa un email válido", systemImage: "exclamationmark.circle")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 16))
                                    
                                    SecureField("", text: $viewModel.password)
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            if viewModel.canLogin {
                                                Task { await viewModel.login() }
                                            }
                                        }
                                }
                                .authenticationField()
                            }
                            
                            // Action Buttons
                            VStack(spacing: 18) {
                                Button {
                                    Task { await viewModel.login() }
                                } label: {
                                    if viewModel.isLoading {
                                        HStack {
                                            Text("Iniciando sesión...")
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        }
                                    } else {
                                        Text("Iniciar Sesión")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(!viewModel.canLogin || viewModel.isLoading)
                                .opacity(viewModel.canLogin ? 1 : 0.7)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                
                                Button("¿Olvidaste tu contraseña?") {
                                    // Implementar recuperación de contraseña
                                }
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                            }
                        }
                        .frame(maxWidth: 380)
                        .padding(30)
                        
                        // Eliminamos el indicador de carga separado ya que ahora está integrado en el botón
                    }
                    Spacer()
                    // Bottom links
                    VStack(spacing: 16) {
                        Button("¿No tienes una cuenta? Regístrate") {
                            viewModel.switchToRegister()
                        }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                    }
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

