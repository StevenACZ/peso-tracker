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

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Form
            VStack(spacing: 20) {
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)

                Button("Create Account") {
                    Task { 
                        await viewModel.register() 
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isLoading || !isFormValid)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                // Show validation errors
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: 400)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            viewModel.validateCurrentForm()
        }
        .onChange(of: viewModel.username) { _ in
            viewModel.validateField("username")
        }
        .onChange(of: viewModel.email) { _ in
            viewModel.validateField("email")
        }
        .onChange(of: viewModel.password) { _ in
            viewModel.validateField("password")
        }
    }

    private var isFormValid: Bool {
        !viewModel.username.isEmpty &&
        !viewModel.email.isEmpty &&
        !viewModel.password.isEmpty &&
        viewModel.password == confirmPassword &&
        confirmPassword.count > 0
    }
}
