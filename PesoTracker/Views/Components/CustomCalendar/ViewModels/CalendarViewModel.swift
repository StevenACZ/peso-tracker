import Foundation
import SwiftUI

/// ViewModel for managing calendar state and interactions
@MainActor
class CalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedDate: Date
    @Published var displayedMonth: Date
    @Published var hoveredDate: Date?
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
        self.displayedMonth = selectedDate
    }
    
    // MARK: - Computed Properties
    
    /// Spanish month name for the displayed month
    var monthName: String {
        SpanishCalendarLocalization.monthName(for: displayedMonth)
    }
    
    /// Year string in "2025" format
    var yearString: String {
        SpanishCalendarLocalization.yearString(for: displayedMonth)
    }
    
    /// Complete month and year string (e.g., "Enero 2025")
    var monthYearString: String {
        SpanishCalendarLocalization.monthYearString(for: displayedMonth)
    }
    
    /// Array of calendar days to display in the grid
    var daysInMonth: [CalendarDay] {
        CalendarDateUtilities.generateCalendarDays(for: displayedMonth)
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to the next month
    func navigateToNextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = CalendarDateUtilities.nextMonth(from: displayedMonth)
        }
    }
    
    /// Navigate to the previous month
    func navigateToPreviousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = CalendarDateUtilities.previousMonth(from: displayedMonth)
        }
    }
    
    /// Navigate to today's month and select today
    func selectToday() {
        let today = Date()
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = today
            selectedDate = today
        }
    }
    
    /// Select a specific date
    func selectDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = date
            
            // If the selected date is not in the current displayed month, navigate to it
            if !CalendarDateUtilities.isSameMonth(date, displayedMonth) {
                displayedMonth = date
            }
        }
    }
    
    // MARK: - State Helper Methods
    
    /// Check if a date is today
    func isToday(_ date: Date) -> Bool {
        CalendarDateUtilities.isToday(date)
    }
    
    /// Check if a date is the selected date
    func isSelected(_ date: Date) -> Bool {
        CalendarDateUtilities.isSameDay(selectedDate, date)
    }
    
    /// Check if a date is in the currently displayed month
    func isCurrentMonth(_ date: Date) -> Bool {
        CalendarDateUtilities.isSameMonth(date, displayedMonth)
    }
    
    /// Check if a date is hovered
    func isHovered(_ date: Date) -> Bool {
        guard let hoveredDate = hoveredDate else { return false }
        return CalendarDateUtilities.isSameDay(hoveredDate, date)
    }
    
    // MARK: - Hover Methods
    
    /// Set the hovered date
    func setHoveredDate(_ date: Date?) {
        hoveredDate = date
    }
    
    /// Clear the hovered date
    func clearHoveredDate() {
        hoveredDate = nil
    }
    
    // MARK: - Accessibility Methods
    
    /// Get accessibility label for a specific date
    func accessibilityLabel(for date: Date) -> String {
        var label = SpanishCalendarLocalization.accessibilityLabel(for: date)
        
        if isToday(date) {
            label += ", hoy"
        }
        
        if isSelected(date) {
            label += ", seleccionado"
        }
        
        if !isCurrentMonth(date) {
            label += ", mes diferente"
        }
        
        return label
    }
    
    /// Get accessibility hint for navigation buttons
    var previousMonthAccessibilityLabel: String {
        let previousMonth = CalendarDateUtilities.previousMonth(from: displayedMonth)
        return "\(SpanishCalendarLocalization.previousMonthLabel): \(SpanishCalendarLocalization.monthYearString(for: previousMonth))"
    }
    
    var nextMonthAccessibilityLabel: String {
        let nextMonth = CalendarDateUtilities.nextMonth(from: displayedMonth)
        return "\(SpanishCalendarLocalization.nextMonthLabel): \(SpanishCalendarLocalization.monthYearString(for: nextMonth))"
    }
}