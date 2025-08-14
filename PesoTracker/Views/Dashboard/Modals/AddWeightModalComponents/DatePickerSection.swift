import SwiftUI

struct DatePickerSection: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Fecha")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            CustomButton(action: {
                if !viewModel.isLoading {
                    viewModel.showDatePicker.toggle()
                }
            }) {
                HStack {
                    Text(viewModel.dateString.isEmpty ? "DD/MM/AAAA" : viewModel.dateString)
                        .font(.system(size: 14))
                        .foregroundColor(viewModel.dateString.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(NSColor.textBackgroundColor))
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
            
            .popover(isPresented: $viewModel.showDatePicker) {
                DatePickerPopover(viewModel: viewModel)
            }
        }
    }
}

struct DatePickerPopover: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Seleccionar Fecha")
                .font(Typography.title3)
                .foregroundColor(.primary)
            
            // Use our custom calendar instead of native DatePicker
            CustomCalendar(selectedDate: $viewModel.date)
                .onChange(of: viewModel.date) { _, _ in
                    viewModel.updateDateString()
                }
            
            HStack(spacing: Spacing.lg) {
                CustomButton(action: {
                    if !viewModel.isLoading {
                        viewModel.showDatePicker = false
                    }
                }) {
                    Text(SpanishCalendarLocalization.cancelButtonText)
                        .font(Typography.modalButton)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(NSColor.controlBackgroundColor))
                        .foregroundColor(.secondary)
                        .cornerRadius(Spacing.radiusStandard)
                        .overlay(
                            RoundedRectangle(cornerRadius: Spacing.radiusStandard)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                }
                
                CustomButton(action: {
                    if !viewModel.isLoading {
                        viewModel.updateDateString()
                        viewModel.showDatePicker = false
                    }
                }) {
                    Text(SpanishCalendarLocalization.selectButtonText)
                        .font(Typography.modalButton)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ColorTheme.success)
                        .foregroundColor(.white)
                        .cornerRadius(Spacing.radiusStandard)
                        .shadow(color: ColorTheme.success.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(Spacing.modalPadding)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(Spacing.radiusModal)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}