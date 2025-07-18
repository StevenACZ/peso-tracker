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
        VStack(spacing: 40) {
            Spacer()
            
            // App title
            VStack(spacing: 16) {
                Image(systemName: "scalemass")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("PesoTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your weight journey")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                Button("Sign In") {
                    viewModel.switchToLogin()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Create Account") {
                    viewModel.switchToRegister()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .frame(maxWidth: 300)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
