//
//  LoginView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 16) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Form
            VStack(spacing: 20) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                Button("Sign In") {
                    Task { 
                        await viewModel.login() 
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

    }

    private var isFormValid: Bool {
        !viewModel.email.isEmpty && !viewModel.password.isEmpty
    }
}
