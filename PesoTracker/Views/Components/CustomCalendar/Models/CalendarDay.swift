import Foundation

/// Represents a single day in the calendar grid
struct CalendarDay {
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelectable: Bool
    
    init(date: Date, isCurrentMonth: Bool = true, isSelectable: Bool = true) {
        self.date = date
        self.dayNumber = Calendar.current.component(.day, from: date)
        self.isCurrentMonth = isCurrentMonth
        self.isToday = Calendar.current.isDateInToday(date)
        self.isSelectable = isSelectable
    }
}

// MARK: - Identifiable
extension CalendarDay: Identifiable {
    var id: Date { date }
}

// MARK: - Equatable
extension CalendarDay: Equatable {
    static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        return Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}