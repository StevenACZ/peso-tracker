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
        VStack(spacing: 30) {
            Text("Iniciar Sesión")
                .font(.title)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Contraseña", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                
                Button("Iniciar Sesión") {
                    Task { await viewModel.login() }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: 300)
        }
        .padding()
    }
}
