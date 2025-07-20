//
//  WelcomeView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 20) {
                Image(systemName: "scalemass")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("PesoTracker")
                    .font(.title)
                    .bold()
                
                Text("Rastrea tu peso fácilmente")
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 15) {
                Button("Iniciar Sesión") {
                    viewModel.switchToLogin()
                }
                .frame(maxWidth: 250)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Crear Cuenta") {
                    viewModel.switchToRegister()
                }
                .frame(maxWidth: 250)
                .padding()
                .background(Color.clear)
                .foregroundColor(.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
        }
        .padding()
    }
}
