import SwiftUI

/// ColorTheme - Centralized color utilities for consistent theming across the app
/// Replaces duplicate color logic found in PersonalSummaryCard, WeightPredictionCard, ProgressChartView
struct ColorTheme {
    
    // MARK: - Weight Change Colors
    
    /// Standard weight change color logic used across multiple components
    /// - Parameter change: Weight change value (negative = loss, positive = gain)
    /// - Returns: Green for loss, red for gain, secondary for no change
    static func weightChangeColor(for change: Double?) -> Color {
        guard let change = change else { return .secondary }
        return change < 0 ? .green : change > 0 ? .red : .secondary
    }
    
    /// Weight change color for optional values
    static func weightChangeColor(for change: Double?, fallback: Color = .secondary) -> Color {
        guard let change = change else { return fallback }
        return change < 0 ? .green : change > 0 ? .red : fallback
    }
    
    // MARK: - Semantic Colors
    
    /// Success color (typically green)
    static let success: Color = .green
    
    /// Error/danger color (typically red) 
    static let error: Color = .red
    
    /// Warning color (typically orange/yellow)
    static let warning: Color = .orange
    
    /// Info color (typically blue)
    static let info: Color = .blue
    
    /// Neutral/secondary color
    static let neutral: Color = .secondary
    
    // MARK: - Validation Colors
    
    /// Get color for form field based on validation state
    static func fieldColor(hasError: Bool) -> Color {
        return hasError ? error : .primary
    }
    
    /// Get color for form field based on validation state with custom error color
    static func fieldColor(hasError: Bool, errorColor: Color = .red) -> Color {
        return hasError ? errorColor : .primary
    }
    
    // MARK: - Status Colors
    
    /// Get status color based on boolean condition
    static func statusColor(isPositive: Bool) -> Color {
        return isPositive ? success : error
    }
    
    /// Get trend color (up = red, down = green, neutral = secondary)
    static func trendColor(isUpward: Bool?) -> Color {
        guard let isUpward = isUpward else { return neutral }
        return isUpward ? error : success // Up is bad for weight, down is good
    }
    
    // MARK: - Progress Colors
    
    /// Get progress color based on percentage (0.0 to 1.0)
    static func progressColor(for progress: Double) -> Color {
        switch progress {
        case 0.0..<0.3: return error
        case 0.3..<0.7: return warning
        case 0.7...1.0: return success
        default: return neutral
        }
    }
}

// MARK: - Color Extensions

extension Color {
    /// Convenience property for weight change colors
    static func weightChange(for value: Double?) -> Color {
        return ColorTheme.weightChangeColor(for: value)
    }
    
    /// Convenience property for trend colors (weight context)
    static func weightTrend(isUpward: Bool?) -> Color {
        return ColorTheme.trendColor(isUpward: isUpward)
    }
}