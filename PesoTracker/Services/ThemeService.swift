import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Claro"
        case .dark:
            return "Oscuro"
        case .system:
            return "Automático Sistema"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class ThemeService: ObservableObject {
    static let shared = ThemeService()
    
    @Published private(set) var currentTheme: AppTheme
    @Published private(set) var effectiveColorScheme: ColorScheme?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Load saved theme preference or default to system
        let savedTheme = UserDefaults.standard.string(forKey: Constants.UserDefaults.themePreference) ?? AppTheme.system.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .system
        self.effectiveColorScheme = currentTheme.colorScheme
        
        // Monitor system appearance changes when using system theme
        setupSystemAppearanceMonitoring()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        effectiveColorScheme = theme.colorScheme
        
        // Save preference
        UserDefaults.standard.set(theme.rawValue, forKey: Constants.UserDefaults.themePreference)
        
        // Apply theme immediately
        applyTheme()
    }
    
    private func setupSystemAppearanceMonitoring() {
        // Monitor for system appearance changes using distributed notifications
        DistributedNotificationCenter.default.publisher(for: .init("AppleInterfaceThemeChangedNotification"))
            .sink { [weak self] _ in
                self?.updateEffectiveColorScheme()
            }
            .store(in: &cancellables)
        
        // Initial update
        updateEffectiveColorScheme()
    }
    
    private func updateEffectiveColorScheme() {
        guard currentTheme == .system else { return }
        
        let systemAppearance = NSApp.effectiveAppearance
        let isDark = systemAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        effectiveColorScheme = isDark ? .dark : .light
    }
    
    private func applyTheme() {
        DispatchQueue.main.async {
            if let colorScheme = self.effectiveColorScheme {
                let appearance: NSAppearance = colorScheme == .dark ? 
                    NSAppearance(named: .darkAqua)! : 
                    NSAppearance(named: .aqua)!
                NSApp.appearance = appearance
            } else {
                // Use system appearance
                NSApp.appearance = nil
            }
        }
    }
}