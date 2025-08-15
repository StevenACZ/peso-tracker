import SwiftUI
import Foundation

/// Extensions - Consolidated utility extensions for common types
/// Provides consistent data formatting, validation, and UI helpers across the app

// MARK: - Color Extensions

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex string (supports 3, 6, or 8 character formats)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - String Extensions

extension String {
    /// Check if string is a valid email format
    var isValidEmail: Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Remove leading and trailing whitespace
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Check if string contains only alphanumeric characters and underscores
    var isValidUsername: Bool {
        let usernameRegex = "^[a-zA-Z0-9_]+$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        let lengthValid = self.count >= Constants.Validation.minUsernameLength && self.count <= Constants.Validation.maxUsernameLength
        return usernamePredicate.evaluate(with: self) && lengthValid
    }
    
    /// Convert string to Double for weight values
    /// Handles both comma and dot decimal separators
    var weightValue: Double? {
        let normalized = self.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
    
    /// Check if string represents a valid weight value
    var isValidWeight: Bool {
        guard let weight = self.weightValue else { return false }
        return weight >= Constants.WeightTracking.minWeight && weight <= Constants.WeightTracking.maxWeight
    }
    
    /// Capitalize first letter only (useful for names)
    var capitalizingFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - Double Extensions

extension Double {
    /// Format weight value consistently across the app
    /// - Parameter unit: Weight unit to append (default: "kg")
    /// - Returns: Formatted weight string like "75.5 kg"
    func weightFormatted(unit: String = Constants.WeightTracking.defaultWeightUnit) -> String {
        return String(format: "%.1f %@", self, unit)
    }
    
    /// Format weight value with precision
    /// - Parameter precision: Number of decimal places (default: 1)
    /// - Returns: Formatted weight string without unit
    func weightString(precision: Int = 1) -> String {
        return String(format: "%.\(precision)f", self)
    }
    
    /// Get weight change color based on positive/negative value
    var weightChangeColor: Color {
        return ColorTheme.weightChangeColor(for: self)
    }
    
    /// Format as percentage with sign
    var percentageFormatted: String {
        let sign = self >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", self))%"
    }
}

// MARK: - Date Extensions

extension Date {
    /// Format date consistently for weight entries
    var weightDisplayFormat: String {
        return DateFormatterFactory.shared.weightEntryFormatter().string(from: self)
    }
    
    /// Format date for dashboard display
    var dashboardDisplayFormat: String {
        return DateFormatterFactory.shared.displayFormatter().string(from: self)
    }
    
    /// Check if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is this week
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Get number of days from today (negative = past, positive = future)
    var daysFromToday: Int {
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: self)).day ?? 0
    }
    
    /// Format as relative time (e.g., "hace 2 días", "hoy", "en 3 días")
    var relativeFormatted: String {
        let days = daysFromToday
        switch days {
        case 0: return "hoy"
        case 1: return "mañana"
        case -1: return "ayer"
        case let x where x < -1: return "hace \(abs(x)) días"
        case let x where x > 1: return "en \(x) días"
        default: return weightDisplayFormat
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply conditional modifier
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply weight change color based on value
    func weightChangeColor(for value: Double?) -> some View {
        self.foregroundColor(ColorTheme.weightChangeColor(for: value))
    }
    
    /// Hide view based on condition
    @ViewBuilder func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
    
    /// Apply loading overlay
    func loadingOverlay(_ isLoading: Bool, message: String = "Cargando...") -> some View {
        self.overlay(
            Group {
                if isLoading {
                    VStack(spacing: Spacing.md) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .cardPadding()
                    .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
                    .standardCornerRadius()
                }
            }
        )
    }
}

// MARK: - Array Extensions

extension Array where Element == Weight {
    /// Sort weights by date (newest first)
    var sortedByDate: [Weight] {
        return self.sorted { $0.date > $1.date }
    }
    
    /// Filter weights by date range
    func filtered(by dateRange: ClosedRange<Date>) -> [Weight] {
        return self.filter { dateRange.contains($0.date) }
    }
    
    /// Get latest weight entry
    var latest: Weight? {
        return self.sortedByDate.first
    }
    
    /// Get oldest weight entry
    var oldest: Weight? {
        return self.sortedByDate.last
    }
}