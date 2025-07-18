//
//  RootView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

/// Root view that manages navigation between authentication and main app
struct RootView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authManager: AuthenticationManager
    
    // MARK: - Body
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainDashboardView()
            } else {
                AuthenticationContainerView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authManager: AuthenticationManager
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "scalemass")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                
                Text("PesoTracker")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                if let user = authManager.currentUser {
                    Text("Bienvenido, \(user.username)")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            
            // Main content
            VStack(spacing: 20) {
                Text("Dashboard Principal")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Aquí irá tu seguimiento de peso")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Simple status indicator
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Sistema de autenticación funcionando")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Logout button
            Button("Cerrar Sesión") {
                authManager.logout()
            }
            .foregroundColor(.red)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationManager.shared)
            .frame(width: 800, height: 600)
    }
}
