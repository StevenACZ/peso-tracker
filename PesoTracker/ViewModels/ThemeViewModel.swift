import Foundation
import SwiftUI
import Combine

class ThemeViewModel: ObservableObject {
    @Published var selectedTheme: AppTheme
    @Published var effectiveColorScheme: ColorScheme?
    
    private let themeService = ThemeService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.selectedTheme = themeService.currentTheme
        self.effectiveColorScheme = themeService.effectiveColorScheme
        
        // Subscribe to theme service changes
        themeService.$currentTheme
            .assign(to: \.selectedTheme, on: self)
            .store(in: &cancellables)
        
        themeService.$effectiveColorScheme
            .assign(to: \.effectiveColorScheme, on: self)
            .store(in: &cancellables)
    }
    
    func updateTheme(_ theme: AppTheme) {
        themeService.setTheme(theme)
    }
    
    var allThemes: [AppTheme] {
        return AppTheme.allCases
    }
}