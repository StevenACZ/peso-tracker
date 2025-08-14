import Foundation

/// Spanish localization constants for the custom calendar
struct SpanishCalendarLocalization {
    
    // MARK: - Month Names
    static let monthNames = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]
    
    // MARK: - Weekday Names (Short)
    static let weekdayNames = ["L", "M", "X", "J", "V", "S", "D"]
    
    // MARK: - Weekday Names (Full)
    static let fullWeekdayNames = [
        "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"
    ]
    
    // MARK: - Button Text
    static let todayButtonText = "Hoy"
    static let cancelButtonText = "Cancelar"
    static let selectButtonText = "Seleccionar"
    
    // MARK: - Accessibility Labels
    static let previousMonthLabel = "Mes anterior"
    static let nextMonthLabel = "Mes siguiente"
    static let todayLabel = "Ir a hoy"
    
    // MARK: - Helper Methods
    
    /// Get Spanish month name for a given date
    static func monthName(for date: Date) -> String {
        let monthIndex = Calendar.current.component(.month, from: date) - 1
        return monthNames[monthIndex]
    }
    
    /// Get formatted year string (e.g., "2025")
    static func yearString(for date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        return "\(year)"
    }
    
    /// Get month and year string (e.g., "Enero 2025")
    static func monthYearString(for date: Date) -> String {
        return "\(monthName(for: date)) \(yearString(for: date))"
    }
    
    /// Get accessibility label for a specific date
    static func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}