import SwiftUI

/// Individual day cell component for the calendar grid
struct CalendarDayView: View {
    
    // MARK: - Properties
    let day: CalendarDay
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let isHovered: Bool
    let onTap: () -> Void
    let onHover: (Bool) -> Void
    
    // MARK: - Computed Properties
    
    /// Text color based on day state
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    /// Background color based on day state
    private var backgroundColor: Color {
        if isSelected {
            return ColorTheme.success
        } else if isHovered && isCurrentMonth {
            return ColorTheme.success.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    /// Border overlay for today's date
    @ViewBuilder
    private var borderOverlay: some View {
        if isToday && !isSelected {
            RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                .stroke(ColorTheme.success, lineWidth: 2)
        }
    }
    
    /// Scale effect for interactions
    private var scaleEffect: CGFloat {
        if isSelected {
            return 1.05
        } else if isHovered {
            return 1.02
        } else {
            return 1.0
        }
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            Text("\(day.dayNumber)")
                .font(Typography.body)
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .overlay(borderOverlay)
                .cornerRadius(Spacing.radiusSmall)
                .scaleEffect(scaleEffect)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            onHover(hovering)
        }
        .disabled(!day.isSelectable)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(isCurrentMonth ? "Toca para seleccionar esta fecha" : "Fecha de otro mes")
    }
    
    // MARK: - Accessibility
    
    /// Comprehensive accessibility label
    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .full
        
        var label = formatter.string(from: day.date)
        
        if isToday {
            label += ", hoy"
        }
        
        if isSelected {
            label += ", seleccionado"
        }
        
        if !isCurrentMonth {
            label += ", mes diferente"
        }
        
        return label
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            // Regular day
            CalendarDayView(
                day: CalendarDay(date: Date()),
                isSelected: false,
                isToday: false,
                isCurrentMonth: true,
                isHovered: false,
                onTap: {},
                onHover: { _ in }
            )
            
            // Today
            CalendarDayView(
                day: CalendarDay(date: Date()),
                isSelected: false,
                isToday: true,
                isCurrentMonth: true,
                isHovered: false,
                onTap: {},
                onHover: { _ in }
            )
            
            // Selected
            CalendarDayView(
                day: CalendarDay(date: Date()),
                isSelected: true,
                isToday: false,
                isCurrentMonth: true,
                isHovered: false,
                onTap: {},
                onHover: { _ in }
            )
            
            // Other month
            CalendarDayView(
                day: CalendarDay(date: Date()),
                isSelected: false,
                isToday: false,
                isCurrentMonth: false,
                isHovered: false,
                onTap: {},
                onHover: { _ in }
            )
            
            // Hovered
            CalendarDayView(
                day: CalendarDay(date: Date()),
                isSelected: false,
                isToday: false,
                isCurrentMonth: true,
                isHovered: true,
                onTap: {},
                onHover: { _ in }
            )
        }
    }
    .padding()
}