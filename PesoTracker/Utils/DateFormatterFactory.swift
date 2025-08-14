import Foundation

/// DateFormatterFactory - Centralized date formatter creation and management
/// Replaces duplicate DateFormatter creation patterns found throughout the app
/// Provides pre-configured formatters for common use cases
class DateFormatterFactory {
    
    // MARK: - Singleton
    static let shared = DateFormatterFactory()
    private init() {}
    
    // MARK: - Cached Formatters (for performance)
    
    /// ISO 8601 formatter for API communication
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
    
    /// Spanish locale formatter for display
    private lazy var spanishFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /// Default system formatter
    private lazy var systemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /// English locale formatter for internal processing
    private lazy var englishFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /// UTC formatter for API communication (only use for server communication)
    private lazy var utcFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    // MARK: - Common Date Formats
    
    /// Weight entry format: "dd/MM/yyyy" (e.g., "15/03/2024")
    func weightEntryFormatter() -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
    
    /// Display format: Medium date style (e.g., "15 mar 2024")
    func displayFormatter() -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    /// Export filename format: "yyyy-MM-dd_HH-mm" (e.g., "2024-03-15_14-30")
    func filenameFormatter() -> DateFormatter {
        let formatter = englishFormatter
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return formatter
    }
    
    /// API format: "yyyy-MM-dd" (e.g., "2024-03-15") - Uses UTC for server communication
    func apiDateFormatter() -> DateFormatter {
        let formatter = utcFormatter
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    /// Full display format with time: "dd/MM/yyyy HH:mm" (e.g., "15/03/2024 14:30")
    func fullDisplayFormatter() -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }
    
    /// Short display format: "dd/MM" (e.g., "15/03")
    func shortDisplayFormatter() -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateFormat = "dd/MM"
        return formatter
    }
    
    /// Month and year format: "MMM yyyy" (e.g., "mar 2024")
    func monthYearFormatter() -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
    
    /// Chart label format: "MMM dd" (e.g., "mar 15")
    func chartLabelFormatter() -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateFormat = "MMM dd"
        return formatter
    }
    
    // MARK: - ISO 8601 Formatters
    
    /// ISO 8601 formatter for API requests
    func getISO8601Formatter() -> ISO8601DateFormatter {
        return iso8601Formatter
    }
    
    /// ISO 8601 string from date
    func iso8601String(from date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }
    
    /// Date from ISO 8601 string
    func dateFromISO8601(_ string: String) -> Date? {
        return iso8601Formatter.date(from: string)
    }
    
    // MARK: - Custom Formatters
    
    /// Create custom formatter with specific pattern
    func customFormatter(pattern: String, locale: Locale = Locale(identifier: "es_ES")) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }
    
    /// Create formatter with date and time styles
    func styledFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> DateFormatter {
        let formatter = spanishFormatter
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
    
    // MARK: - Convenience Methods
    
    /// Format date for weight entry (dd/MM/yyyy)
    func formatForWeightEntry(_ date: Date) -> String {
        return weightEntryFormatter().string(from: date)
    }
    
    /// Format date for display (medium style)
    func formatForDisplay(_ date: Date) -> String {
        return displayFormatter().string(from: date)
    }
    
    /// Format date for API (yyyy-MM-dd)
    func formatForAPI(_ date: Date) -> String {
        return apiDateFormatter().string(from: date)
    }
    
    /// Format date for filename (yyyy-MM-dd_HH-mm)
    func formatForFilename(_ date: Date) -> String {
        return filenameFormatter().string(from: date)
    }
    
    /// Parse date from weight entry string (dd/MM/yyyy)
    func parseWeightEntryDate(_ string: String) -> Date? {
        return weightEntryFormatter().date(from: string)
    }
    
    /// Parse date from API string (yyyy-MM-dd)
    func parseAPIDate(_ string: String) -> Date? {
        return apiDateFormatter().date(from: string)
    }
    
    // MARK: - Relative Formatting
    
    /// Get relative date string (e.g., "hoy", "ayer", "hace 2 días")
    func relativeString(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "hoy"
        } else if calendar.isDateInYesterday(date) {
            return "ayer"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: now).day {
            if daysAgo < 7 {
                return "hace \(daysAgo) día\(daysAgo == 1 ? "" : "s")"
            } else if daysAgo < 30 {
                let weeksAgo = daysAgo / 7
                return "hace \(weeksAgo) semana\(weeksAgo == 1 ? "" : "s")"
            } else {
                return formatForDisplay(date)
            }
        }
        
        return formatForDisplay(date)
    }
}

// MARK: - Convenience Extensions

extension Date {
    /// Format using DateFormatterFactory
    func formatted(using formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
    
    /// Weight entry format (dd/MM/yyyy)
    var weightEntryFormat: String {
        return DateFormatterFactory.shared.formatForWeightEntry(self)
    }
    
    /// Display format (medium style)
    var displayFormat: String {
        return DateFormatterFactory.shared.formatForDisplay(self)
    }
    
    /// API format (yyyy-MM-dd)
    var apiFormat: String {
        return DateFormatterFactory.shared.formatForAPI(self)
    }
    
    /// Filename format (yyyy-MM-dd_HH-mm)
    var filenameFormat: String {
        return DateFormatterFactory.shared.formatForFilename(self)
    }
    
    /// Relative format (e.g., "hoy", "ayer")
    var relativeFormat: String {
        return DateFormatterFactory.shared.relativeString(for: self)
    }
}

extension String {
    /// Parse weight entry date (dd/MM/yyyy)
    var asWeightEntryDate: Date? {
        return DateFormatterFactory.shared.parseWeightEntryDate(self)
    }
    
    /// Parse API date (yyyy-MM-dd)  
    var asAPIDate: Date? {
        return DateFormatterFactory.shared.parseAPIDate(self)
    }
    
    /// Parse ISO 8601 date
    var asISO8601Date: Date? {
        return DateFormatterFactory.shared.dateFromISO8601(self)
    }
}