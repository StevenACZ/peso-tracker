//
//  PesoTrackerApp.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

@main
struct PesoTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    DashboardView()
                } else {
                    AuthenticationContainerView()
                }
            }
            .task {
                await authManager.initialize()
            }
        }
        .defaultSize(width: 800, height: 600)
    }
}
