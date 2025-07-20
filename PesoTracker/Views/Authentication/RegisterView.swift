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
        VStack(spacing: 30) {
            Text("Crear Cuenta")
                .font(.title)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Nombre de usuario", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Contraseña", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Confirmar Contraseña", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                
                Button("Crear Cuenta") {
                    Task { await viewModel.register() }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isLoading || viewModel.password != confirmPassword)
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: 300)
        }
        .padding()
    }
}
