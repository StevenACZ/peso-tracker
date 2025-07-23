//
//  PesoTrackerApp.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI
import AppKit

@main
struct PesoTrackerApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(authManager: authManager)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                .edgesIgnoringSafeArea(.all)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
    
    struct ContentView: View {
        @ObservedObject var authManager: AuthenticationManager
        
        var body: some View {
            Group {
                if authManager.isAuthenticated {
                    DashboardView()
                        .frame(minWidth: 1300, minHeight: 770)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .background(Color(NSColor.windowBackgroundColor))
                } else {
                    AuthenticationContainerView()
                        .frame(width: 400, height: 680)
                        .fixedSize()
                }
            }
            .task {
                await authManager.initialize()
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                if let window = NSApplication.shared.keyWindow {
                    let size = isAuthenticated ?
                    NSSize(width: 1300, height: 770) :
                    NSSize(width: 400, height: 680)
                    
                    DispatchQueue.main.async {
                        window.setContentSize(size)
                        window.center()
                        window.styleMask.remove(.resizable)
                        window.standardWindowButton(.zoomButton)?.isEnabled = false
                    }
                }
            }
            .onAppear {
                if let window = NSApplication.shared.keyWindow {
                    let size = authManager.isAuthenticated ?
                    NSSize(width: 1300, height: 770) :
                    NSSize(width: 400, height: 680)
                    
                    window.setContentSize(size)
                    window.center()
                    window.styleMask.remove(.resizable)
                    window.standardWindowButton(.zoomButton)?.isEnabled = false
                }
            }
        }
    }
}
