//
//  ContentView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 25/07/25.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isCheckingAuth = true
    
    var body: some View {
        Group {
            if isCheckingAuth {
                // Loading screen while checking authentication
                splashScreen
            } else if authViewModel.isAuthenticated {
                // Main app content for authenticated users
                MainDashboardView()
            } else {
                // Authentication flow for non-authenticated users
                AuthView()
            }
        }
        .onAppear {
            checkInitialAuthState()
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            // Handle authentication state changes
            if isAuthenticated {
                print("Usuario autenticado exitosamente")
            } else {
                print("Usuario no autenticado")
            }
        }
    }
    
    // MARK: - Splash Screen
    private var splashScreen: some View {
        ZStack {
            // Background - adapts to dark mode
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Icon - green like in dashboard
                Image(systemName: "figure.walk.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                
                // App Name
                Text("PesoTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .scaleEffect(1.2)
                
                Text("Cargando...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Authentication Check
    private func checkInitialAuthState() {
        // Simulate a brief loading time for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Check if user has valid authentication token
            authViewModel.checkAuthenticationStatus()
            
            // Update loading state
            withAnimation(.easeInOut(duration: 0.3)) {
                isCheckingAuth = false
            }
        }
    }
}

#Preview {
    ContentView()
}
