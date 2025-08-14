import SwiftUI

/// Main custom calendar component that replaces the native DatePicker
struct CustomCalendar: View {
    
    // MARK: - Properties
    @Binding var selectedDate: Date
    @StateObject private var viewModel: CalendarViewModel
    
    // MARK: - Initialization
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._viewModel = StateObject(wrappedValue: CalendarViewModel(selectedDate: selectedDate.wrappedValue))
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Spacing.md) {
            CalendarHeader(viewModel: viewModel)
            
            CalendarGrid(viewModel: viewModel)
        }
        .padding(Spacing.modalPadding)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(Spacing.radiusModal)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .frame(width: 340)
        .onChange(of: viewModel.selectedDate) { _, newDate in
            selectedDate = newDate
        }
        .onChange(of: selectedDate) { _, newDate in
            if !CalendarDateUtilities.isSameDay(newDate, viewModel.selectedDate) {
                viewModel.selectDate(newDate)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calendario personalizado")
        .accessibilityHint("Usa las flechas para navegar entre meses y selecciona una fecha")
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CustomCalendar(selectedDate: .constant(Date()))
        
        Divider()
        
        // Different states preview
        CustomCalendar(selectedDate: .constant(Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()))
    }
    .padding()
    .background(Color(NSColor.controlBackgroundColor))
}