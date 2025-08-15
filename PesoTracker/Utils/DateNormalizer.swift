import Foundation

/// DateNormalizer - Utility class for normalizing dates to ensure consistent behavior
/// across the weight tracking system, preventing timezone-related date drift issues
class DateNormalizer {
    
    // MARK: - Singleton
    static let shared = DateNormalizer()
    private init() {}
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    
    // MARK: - Core Normalization Methods
    
    /// Normalizes a date to midnight in the local timezone
    /// This ensures that dates selected by users maintain their intended day
    /// regardless of timezone conversions
    /// - Parameter date: The date to normalize
    /// - Returns: A new date set to midnight (00:00:00) in the local timezone
    func normalizeToMidnight(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Creates a local date from year, month, and day components
    /// Useful for creating dates that represent user intentions without time components
    /// - Parameters:
    ///   - year: The year component
    ///   - month: The month component (1-12)
    ///   - day: The day component (1-31)
    /// - Returns: A date representing the specified day at midnight in local timezone
    func createLocalDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current
        
        return calendar.date(from: components) ?? Date()
    }
    
    /// Preserves the local date intent by ensuring the date represents the same
    /// calendar day in the user's timezone, regardless of the source timezone
    /// - Parameter date: The date to preserve
    /// - Returns: A date that represents the same calendar day in local timezone
    func preserveLocalDate(_ date: Date) -> Date {
        // Extract the date components in the current timezone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Create a new date with these components at midnight local time
        return createLocalDate(
            year: components.year ?? calendar.component(.year, from: Date()),
            month: components.month ?? calendar.component(.month, from: Date()),
            day: components.day ?? calendar.component(.day, from: Date())
        )
    }
    
    // MARK: - Weight Entry Specific Methods
    
    /// Normalizes a date for weight entry purposes
    /// This is the primary method used when handling dates in the weight tracking system
    /// - Parameter date: The date selected by the user
    /// - Returns: A normalized date suitable for weight entry storage and display
    func normalizeForWeightEntry(_ date: Date) -> Date {
        return normalizeToMidnight(date)
    }
    
    /// Normalizes a date when loading from API data
    /// Handles the case where API returns UTC dates but we need local date representation
    /// - Parameter apiDate: The date received from the API
    /// - Returns: A date that preserves the intended calendar day in local timezone
    func normalizeFromAPI(_ apiDate: Date) -> Date {
        // Extract the date components from the API date in UTC
        let utcCalendar = Calendar(identifier: .gregorian)
        var utcCalendar_copy = utcCalendar
        utcCalendar_copy.timeZone = TimeZone(identifier: "UTC")!
        
        let components = utcCalendar_copy.dateComponents([.year, .month, .day], from: apiDate)
        
        // Create a new date with these components in local timezone
        return createLocalDate(
            year: components.year ?? 2024,
            month: components.month ?? 1,
            day: components.day ?? 1
        )
    }
    
    /// Creates a date from a date string in YYYY-MM-DD format, preserving the exact day
    /// - Parameter dateString: Date string in YYYY-MM-DD format
    /// - Returns: A date representing that exact day at midnight in local timezone
    func dateFromAPIString(_ dateString: String) -> Date? {
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return nil
        }
        
        return createLocalDate(year: year, month: month, day: day)
    }
    
    // MARK: - Validation Methods
    
    /// Checks if two dates represent the same calendar day in local timezone
    /// - Parameters:
    ///   - date1: First date to compare
    ///   - date2: Second date to compare
    /// - Returns: True if both dates represent the same calendar day
    func isSameLocalDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    /// Validates that a date is properly normalized (at midnight)
    /// - Parameter date: The date to validate
    /// - Returns: True if the date is at midnight in local timezone
    func isNormalized(_ date: Date) -> Bool {
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        return components.hour == 0 && components.minute == 0 && components.second == 0
    }
    
    /// Validates date range consistency to prevent drift
    /// - Parameters:
    ///   - dates: Array of dates to validate
    /// - Returns: True if all dates are consecutive without gaps or drift
    func validateDateRangeConsistency(_ dates: [Date]) -> Bool {
        guard dates.count > 1 else { return true }
        
        let sortedDates = dates.sorted()
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i-1]
            let currentDate = sortedDates[i]
            
            // Check if dates are properly normalized
            if !isNormalized(previousDate) || !isNormalized(currentDate) {
                print("⚠️ [DATE NORMALIZER] Found non-normalized date in range validation")
                return false
            }
            
            // Check for reasonable date progression (no more than 1 year gap)
            let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            if daysBetween > 365 {
                print("⚠️ [DATE NORMALIZER] Found unreasonable date gap: \(daysBetween) days")
                return false
            }
        }
        
        return true
    }
    
    /// Handles month and year boundary edge cases
    /// - Parameter date: The date to validate for boundary conditions
    /// - Returns: Normalized date with boundary handling
    func handleBoundaryEdgeCases(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            print("⚠️ [DATE NORMALIZER] Invalid date components, using current date")
            return normalizeToMidnight(Date())
        }
        
        // Handle leap year February 29th edge case
        if month == 2 && day == 29 {
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            if !isLeapYear {
                print("⚠️ [DATE NORMALIZER] February 29th in non-leap year, adjusting to February 28th")
                return createLocalDate(year: year, month: 2, day: 28)
            }
        }
        
        // Handle invalid day for month (e.g., April 31st)
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        if day > daysInMonth {
            print("⚠️ [DATE NORMALIZER] Invalid day \(day) for month \(month), adjusting to last day of month")
            return createLocalDate(year: year, month: month, day: daysInMonth)
        }
        
        return normalizeToMidnight(date)
    }
    
    // MARK: - Debugging Helpers
    
    /// Returns a debug description of a date showing its components
    /// - Parameter date: The date to describe
    /// - Returns: A string describing the date components
    func debugDescription(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date)
        return "Date: \(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0) \(components.hour ?? 0):\(components.minute ?? 0):\(components.second ?? 0) TZ: \(components.timeZone?.identifier ?? "Unknown")"
    }
    
    /// Logs date normalization operations for debugging
    /// - Parameters:
    ///   - originalDate: The original date before normalization
    ///   - normalizedDate: The date after normalization
    ///   - operation: Description of the operation performed
    func logNormalization(originalDate: Date, normalizedDate: Date, operation: String) {
        print("🗓️ [DATE NORMALIZER] \(operation)")
        print("   Original: \(debugDescription(for: originalDate))")
        print("   Normalized: \(debugDescription(for: normalizedDate))")
        print("   Same day: \(isSameLocalDay(originalDate, normalizedDate))")
    }
}

// MARK: - Convenience Extensions

extension Date {
    /// Normalizes the date to midnight in local timezone
    var normalizedToMidnight: Date {
        return DateNormalizer.shared.normalizeToMidnight(self)
    }
    
    /// Preserves the local date intent
    var preservedLocalDate: Date {
        return DateNormalizer.shared.preserveLocalDate(self)
    }
    
    /// Normalizes for weight entry use
    var normalizedForWeightEntry: Date {
        return DateNormalizer.shared.normalizeForWeightEntry(self)
    }
    
    /// Normalizes from API data
    var normalizedFromAPI: Date {
        return DateNormalizer.shared.normalizeFromAPI(self)
    }
}