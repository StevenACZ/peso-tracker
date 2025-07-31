//
//  PesoTrackerApp.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 25/07/25.
//

import SwiftUI

@main
struct PesoTrackerApp: App {
    @StateObject private var themeViewModel = ThemeViewModel()
    
    init() {
        // Log build configuration on app startup
        Constants.logBuildConfiguration()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000, minHeight: 700)
                .environmentObject(themeViewModel)
                .preferredColorScheme(themeViewModel.effectiveColorScheme)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    }
}
