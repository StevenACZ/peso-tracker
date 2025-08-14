import SwiftUI

/// Spacing - Centralized spacing constants to replace magic numbers
/// Provides consistent spacing throughout the app
struct Spacing {
    
    // MARK: - Base Spacing Units (8pt grid system)
    
    /// Extra small spacing: 4pt
    static let xs: CGFloat = 4
    
    /// Small spacing: 8pt  
    static let sm: CGFloat = 8
    
    /// Medium spacing: 12pt
    static let md: CGFloat = 12
    
    /// Large spacing: 16pt
    static let lg: CGFloat = 16
    
    /// Extra large spacing: 20pt
    static let xl: CGFloat = 20
    
    /// Extra extra large spacing: 24pt
    static let xxl: CGFloat = 24
    
    /// Extra extra extra large spacing: 32pt
    static let xxxl: CGFloat = 32
    
    // MARK: - Semantic Spacing
    
    /// Card padding: 12pt
    static let cardPadding: CGFloat = 12
    
    /// Modal padding: 24pt
    static let modalPadding: CGFloat = 24
    
    /// Section spacing: 20pt
    static let sectionSpacing: CGFloat = 20
    
    /// Button spacing: 12pt
    static let buttonSpacing: CGFloat = 12
    
    /// Form field spacing: 16pt
    static let fieldSpacing: CGFloat = 16
    
    /// Tight spacing: 8pt (for compact layouts)
    static let tight: CGFloat = 8
    
    /// Comfortable spacing: 16pt (for readable layouts)
    static let comfortable: CGFloat = 16
    
    /// Loose spacing: 24pt (for spacious layouts)
    static let loose: CGFloat = 24
    
    // MARK: - Component-Specific Spacing
    
    /// Dashboard spacing: 16pt
    static let dashboard: CGFloat = 16
    
    /// Sidebar spacing: 12pt
    static let sidebar: CGFloat = 12
    
    /// List item spacing: 8pt
    static let listItem: CGFloat = 8
    
    /// Error spacing: 20pt
    static let error: CGFloat = 20
    
    /// Auth form spacing: 24pt
    static let authForm: CGFloat = 24
    
    // MARK: - Border Radius
    
    /// Small border radius: 6pt
    static let radiusSmall: CGFloat = 6
    
    /// Standard border radius: 8pt
    static let radiusStandard: CGFloat = 8
    
    /// Large border radius: 12pt
    static let radiusLarge: CGFloat = 12
    
    /// Modal border radius: 12pt
    static let radiusModal: CGFloat = 12
    
    // MARK: - Padding Helpers
    
    /// Standard button padding
    static let buttonPadding = EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
    
    /// Card content padding
    static let cardContentPadding = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
    
    /// Modal content padding
    static let modalContentPadding = EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
    
    /// Form field padding
    static let fieldPadding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    
    // MARK: - Stack Spacing Presets
    
    /// VStack spacing for forms
    static let formVStack: CGFloat = 20
    
    /// VStack spacing for cards
    static let cardVStack: CGFloat = 12
    
    /// VStack spacing for compact layouts
    static let compactVStack: CGFloat = 8
    
    /// HStack spacing for buttons
    static let buttonHStack: CGFloat = 12
    
    /// HStack spacing for stats
    static let statsHStack: CGFloat = 16
    
    /// HStack spacing for compact elements
    static let compactHStack: CGFloat = 8
}

// MARK: - View Extensions

extension View {
    /// Apply standard card padding
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }
    
    /// Apply modal padding
    func modalPadding() -> some View {
        self.padding(Spacing.modalPadding)
    }
    
    /// Apply form field padding
    func fieldPadding() -> some View {
        self.padding(Spacing.fieldPadding)
    }
    
    /// Apply comfortable spacing
    func comfortableSpacing() -> some View {
        self.padding(Spacing.comfortable)
    }
    
    /// Apply tight spacing
    func tightSpacing() -> some View {
        self.padding(Spacing.tight)
    }
    
    /// Apply standard corner radius
    func standardCornerRadius() -> some View {
        self.cornerRadius(Spacing.radiusStandard)
    }
    
    /// Apply large corner radius
    func largeCornerRadius() -> some View {
        self.cornerRadius(Spacing.radiusLarge)
    }
    
    /// Apply modal corner radius
    func modalCornerRadius() -> some View {
        self.cornerRadius(Spacing.radiusModal)
    }
}

// MARK: - Stack Spacing Helpers

/// Helper functions for creating stacks with consistent spacing
struct SpacingStack {
    /// Create VStack with form spacing
    static func form<Content: View>(alignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) -> VStack<Content> {
        VStack(alignment: alignment, spacing: Spacing.formVStack, content: content)
    }
    
    /// Create VStack with card spacing
    static func card<Content: View>(alignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) -> VStack<Content> {
        VStack(alignment: alignment, spacing: Spacing.cardVStack, content: content)
    }
    
    /// Create VStack with compact spacing
    static func compact<Content: View>(alignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) -> VStack<Content> {
        VStack(alignment: alignment, spacing: Spacing.compactVStack, content: content)
    }
    
    /// Create HStack with button spacing
    static func buttons<Content: View>(alignment: VerticalAlignment = .center, @ViewBuilder content: () -> Content) -> HStack<Content> {
        HStack(alignment: alignment, spacing: Spacing.buttonHStack, content: content)
    }
    
    /// Create HStack with stats spacing
    static func stats<Content: View>(alignment: VerticalAlignment = .center, @ViewBuilder content: () -> Content) -> HStack<Content> {
        HStack(alignment: alignment, spacing: Spacing.statsHStack, content: content)
    }
    
    /// Create HStack with compact spacing
    static func compactH<Content: View>(alignment: VerticalAlignment = .center, @ViewBuilder content: () -> Content) -> HStack<Content> {
        HStack(alignment: alignment, spacing: Spacing.compactHStack, content: content)
    }
}