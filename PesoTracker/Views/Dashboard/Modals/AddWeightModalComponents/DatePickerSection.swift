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
        VStack(spacing: 20) {
            Text("Seleccionar Fecha")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            ZStack {
                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .accentColor(.green)
                    .background(Color.clear)
                    .onChange(of: viewModel.date) {
                        viewModel.updateDateString()
                    }
                
                // Overlay to hide any focus rings or outlines
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 3)
                    .background(Color.clear)
                    .allowsHitTesting(false)
            }
            .mask(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            
            HStack(spacing: 16) {
                CustomButton(action: {
                    if !viewModel.isLoading {
                        viewModel.showDatePicker = false
                    }
                }) {
                    Text("Cancelar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(NSColor.controlBackgroundColor))
                        .foregroundColor(.secondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                }
                
                
                CustomButton(action: {
                    if !viewModel.isLoading {
                        viewModel.updateDateString()
                        viewModel.showDatePicker = false
                    }
                }) {
                    Text("Seleccionar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
            }
        }
        .padding(24)
        .frame(width: 340)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}