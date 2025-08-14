import SwiftUI

/// Calendar grid component that displays the days in a month
struct CalendarGrid: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: CalendarViewModel
    
    // MARK: - Constants
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let fixedHeight: CGFloat = 240 // Fixed height to prevent layout jumps
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Spacing.xs) {
            WeekdayHeaders()
            
            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(viewModel.daysInMonth, id: \.date) { day in
                    CalendarDayView(
                        day: day,
                        isSelected: viewModel.isSelected(day.date),
                        isToday: viewModel.isToday(day.date),
                        isCurrentMonth: viewModel.isCurrentMonth(day.date),
                        isHovered: viewModel.isHovered(day.date),
                        onTap: {
                            viewModel.selectDate(day.date)
                        },
                        onHover: { hovering in
                            if hovering {
                                viewModel.setHoveredDate(day.date)
                            } else {
                                viewModel.clearHoveredDate()
                            }
                        }
                    )
                }
            }
        }
        .frame(height: fixedHeight)
        .clipped() // Ensure content doesn't overflow the fixed height
    }
}

/// Weekday headers component showing Spanish day abbreviations
struct WeekdayHeaders: View {
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SpanishCalendarLocalization.weekdayNames, id: \.self) { weekday in
                Text(weekday)
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CalendarGrid(viewModel: CalendarViewModel())
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
}