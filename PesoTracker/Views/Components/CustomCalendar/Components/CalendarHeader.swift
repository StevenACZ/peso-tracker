import SwiftUI

/// Calendar header component with navigation controls and today button
struct CalendarHeader: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: CalendarViewModel
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Navigation row with month/year controls
            HStack {
                NavigationButton(
                    direction: .previous,
                    accessibilityLabel: viewModel.previousMonthAccessibilityLabel
                ) {
                    viewModel.navigateToPreviousMonth()
                }
                Spacer()
                MonthYearDisplay(
                    month: viewModel.monthName,
                    year: viewModel.yearString
                )
                Spacer()
                NavigationButton(
                    direction: .next,
                    accessibilityLabel: viewModel.nextMonthAccessibilityLabel
                ) {
                    viewModel.navigateToNextMonth()
                }
            }
            // Today button centered below
            HStack {
                Spacer()
                TodayButton {
                    viewModel.selectToday()
                }
                Spacer()
            }
        }
        .frame(height: 70) // Increased height for two rows
    }
}

/// Navigation button for previous/next month
struct NavigationButton: View {
    
    enum Direction {
        case previous
        case next
        
        var iconName: String {
            switch self {
            case .previous: return "chevron.left"
            case .next: return "chevron.right"
            }
        }
    }
    
    let direction: Direction
    let accessibilityLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(Color.clear)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .onHover { hovering in
            DispatchQueue.main.async {
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
        }
    }
}

/// Month and year display component
struct MonthYearDisplay: View {
    
    let month: String
    let year: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(month)
                .font(Typography.title3)
                .foregroundColor(.primary)
            
            Text(year)
                .font(Typography.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(month) \(year)")
    }
}

/// Today button component
struct TodayButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(SpanishCalendarLocalization.todayButtonText)
                .font(Typography.buttonText)
                .foregroundColor(ColorTheme.success)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                        .stroke(ColorTheme.success, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                                .fill(ColorTheme.success.opacity(0.1))
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(SpanishCalendarLocalization.todayLabel)
        .accessibilityHint("Navega al mes actual y selecciona la fecha de hoy")
        .onHover { hovering in
            DispatchQueue.main.async {
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CalendarHeader(viewModel: CalendarViewModel())
        
        Divider()
        
        // Individual component previews
        HStack {
            NavigationButton(direction: .previous, accessibilityLabel: "Mes anterior") {}
            Spacer()
            NavigationButton(direction: .next, accessibilityLabel: "Mes siguiente") {}
        }
        
        MonthYearDisplay(month: "Enero", year: "2025")
        
        TodayButton {}
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}