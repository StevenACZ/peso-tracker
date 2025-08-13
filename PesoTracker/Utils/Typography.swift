import SwiftUI

/// Typography - Centralized typography utilities for consistent text styling
/// Replaces duplicate font patterns found throughout the app
struct Typography {
    
    // MARK: - Semantic Typography
    
    /// Large title (32pt, semibold) - For main headings
    static let largeTitle = Font.system(size: 32, weight: .semibold)
    
    /// Title (28pt, semibold) - For auth headers, modal titles
    static let title = Font.system(size: 28, weight: .semibold)
    
    /// Title 2 (24pt, bold) - For section headings
    static let title2 = Font.system(size: 24, weight: .bold)
    
    /// Title 3 (20pt, semibold) - For card titles
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    /// Headline (18pt, semibold) - For prominent text
    static let headline = Font.system(size: 18, weight: .semibold)
    
    /// Subheadline (16pt, medium) - For button text, important labels
    static let subheadline = Font.system(size: 16, weight: .medium)
    
    /// Body (14pt, regular) - For main body text
    static let body = Font.system(size: 14, weight: .regular)
    
    /// Callout (12pt, medium) - For section headers, small labels
    static let callout = Font.system(size: 12, weight: .medium)
    
    /// Caption (12pt, regular) - For secondary text, descriptions
    static let caption = Font.system(size: 12, weight: .regular)
    
    /// Caption 2 (10pt, regular) - For very small text
    static let caption2 = Font.system(size: 10, weight: .regular)
    
    // MARK: - Specialized Typography
    
    /// Error icon text (40pt) - For large error icons
    static let errorIcon = Font.system(size: 40)
    
    /// Auth title (28pt, semibold) - Specific for auth headers
    static let authTitle = Font.system(size: 28, weight: .semibold)
    
    /// Auth body (14pt, regular) - For auth descriptions
    static let authBody = Font.system(size: 14, weight: .regular)
    
    /// Card header (12pt, medium, tracked) - For dashboard card headers
    static let cardHeader = Font.system(size: 12, weight: .medium)
    
    /// Weight value (16pt, semibold) - For displaying weight values
    static let weightValue = Font.system(size: 16, weight: .semibold)
    
    /// Button text (14pt, medium) - For standard buttons
    static let buttonText = Font.system(size: 14, weight: .medium)
    
    /// Modal button (16pt, medium) - For modal action buttons
    static let modalButton = Font.system(size: 16, weight: .medium)
    
    // MARK: - Dynamic Typography
    
    /// Custom font with size and weight
    static func custom(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.system(size: size, weight: weight)
    }
    
    /// Custom font with size, weight, and design
    static func custom(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return Font.system(size: size, weight: weight, design: design)
    }
}

// MARK: - Font Extensions

extension Font {
    /// Convenience typography access
    static var typography: Typography.Type {
        return Typography.self
    }
}

// MARK: - Text Extensions

extension Text {
    /// Apply typography style with method chaining
    func typography(_ font: Font) -> Text {
        return self.font(font)
    }
    
    /// Apply common text styles
    func authTitle() -> Text {
        return self.font(Typography.authTitle).foregroundColor(.primary)
    }
    
    func authBody() -> Text {
        return self.font(Typography.authBody).foregroundColor(.secondary)
    }
    
    func cardHeader() -> Text {
        return self.font(Typography.cardHeader)
            .foregroundColor(.secondary)
            .tracking(0.5)
    }
    
    func weightValue(color: Color = .primary) -> Text {
        return self.font(Typography.weightValue).foregroundColor(color)
    }
    
    func buttonLabel() -> Text {
        return self.font(Typography.buttonText).foregroundColor(.white)
    }
    
    func modalButton() -> Text {
        return self.font(Typography.modalButton).foregroundColor(.white)
    }
    
    func errorMessage() -> some View {
        return self.font(Typography.body)
            .foregroundColor(ColorTheme.error)
            .multilineTextAlignment(.center)
    }
}