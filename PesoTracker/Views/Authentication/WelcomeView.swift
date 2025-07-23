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
            // Header
            VStack(spacing: 20) {
                Image(systemName: "scalemass.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 8) {
                    Text("PesoTracker")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Tu compañero en el viaje hacia tus metas")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Seguimiento preciso", description: "Registra y monitorea tu progreso diario")
                FeatureRow(icon: "target", title: "Establece metas", description: "Define objetivos realistas y alcanzables")
                FeatureRow(icon: "photo.on.rectangle", title: "Fotos de progreso", description: "Visualiza tu transformación con fotos")
            }
            .padding(.horizontal)
            
            // Action Buttons
            VStack(spacing: 16) {
                Button("Iniciar Sesión") {
                    viewModel.switchToLogin()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 300)
                
                Button("Crear Cuenta") {
                    viewModel.switchToRegister()
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 300)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 50)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
