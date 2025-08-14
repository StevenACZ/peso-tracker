import Foundation

/// Utility functions for calendar date calculations
struct CalendarDateUtilities {
    
    private static let calendar = Calendar.current
    
    // MARK: - Month Navigation
    
    /// Get the first day of the month for a given date
    static func firstDayOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Get the last day of the month for a given date
    static func lastDayOfMonth(for date: Date) -> Date {
        let firstDay = firstDayOfMonth(for: date)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay) ?? date
        return calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? date
    }
    
    /// Navigate to the previous month
    static func previousMonth(from date: Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }
    
    /// Navigate to the next month
    static func nextMonth(from date: Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }
    
    // MARK: - Week Calculations
    
    /// Get the first day of the week containing the given date
    static func firstDayOfWeek(containing date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    /// Get the weekday index (0 = Monday, 6 = Sunday) for a given date
    static func weekdayIndex(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        // Convert from Sunday=1 to Monday=0 system
        return (weekday + 5) % 7
    }
    
    // MARK: - Calendar Grid Generation
    
    /// Generate all days to display in the calendar grid for a given month
    static func generateCalendarDays(for displayedMonth: Date) -> [CalendarDay] {
        var days: [CalendarDay] = []
        
        let firstDayOfMonth = firstDayOfMonth(for: displayedMonth)
        _ = lastDayOfMonth(for: displayedMonth)
        
        // Calculate the first day to show (might be from previous month)
        let firstWeekday = weekdayIndex(for: firstDayOfMonth)
        let startDate = calendar.date(byAdding: .day, value: -firstWeekday, to: firstDayOfMonth) ?? firstDayOfMonth
        
        // Generate 42 days (6 weeks × 7 days) to ensure consistent grid
        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                let day = CalendarDay(date: date, isCurrentMonth: isCurrentMonth)
                days.append(day)
            }
        }
        
        return days
    }
    
    // MARK: - Date Comparisons
    
    /// Check if two dates are in the same day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    /// Check if a date is today
    static func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    /// Check if a date is in the same month as another date
    static func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }
    
    // MARK: - Leap Year Calculations
    
    /// Check if a given year is a leap year
    static func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
    
    /// Get the number of days in February for a given year
    static func daysInFebruary(for year: Int) -> Int {
        return isLeapYear(year) ? 29 : 28
    }
    
    /// Get the number of days in a specific month and year
    static func daysInMonth(month: Int, year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 4, 6, 9, 11:
            return 30
        case 2:
            return daysInFebruary(for: year)
        default:
            return 30
        }
    }
}