import SwiftUI

struct AddGoalModal: View {
    @Binding var isPresented: Bool
    let isEditing: Bool
    let existingGoal: DashboardGoal?
    let onSave: () -> Void
    
    @State private var targetWeight: String = ""
    @State private var targetDate: Date = Date()
    @State private var showDatePicker = false
    @State private var isLoading = false
    @State private var error: String?
    
    @StateObject private var goalService = GoalService.shared
    
    init(isPresented: Binding<Bool>, isEditing: Bool = false, existingGoal: DashboardGoal? = nil, onSave: @escaping () -> Void = {}) {
        self._isPresented = isPresented
        self.isEditing = isEditing
        self.existingGoal = existingGoal
        self.onSave = onSave
    }
    
    private var dateString: String {
        return DateFormatterFactory.shared.weightEntryFormatter().string(from: targetDate)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(isEditing ? "Editar Meta" : "Agregar Meta")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(isEditing ? "Actualiza tu peso y fecha objetivo." : "Establece tu peso y fecha objetivo.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Form Fields
            VStack(spacing: 20) {
                // Peso Objetivo Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Peso Objetivo (kg)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("p.ej., 75", text: $targetWeight)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(6)
                }
                
                // Fecha Objetivo Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha Objetivo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    CustomButton(action: {
                        showDatePicker.toggle()
                    }) {
                        HStack {
                            Text(dateString)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(6)
                    }
                    
                    .popover(isPresented: $showDatePicker) {
                        GoalDatePickerPopover(targetDate: $targetDate, showDatePicker: $showDatePicker)
                    }
                }
            }
            
            // Error message
            if let error = error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Buttons
            HStack(spacing: 12) {
                CustomButton(action: {
                    isPresented = false
                }) {
                    Text("Cancelar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
                
                
                CustomButton(action: {
                    saveGoal()
                }) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("Guardar Cambios")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                .cornerRadius(6)
                
                .disabled(isLoading || targetWeight.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            loadExistingGoal()
        }
    }
    
    // MARK: - Actions
    private func saveGoal() {
        guard !targetWeight.isEmpty else {
            error = "Por favor ingresa un peso objetivo"
            return
        }
        
        guard let weight = Double(targetWeight), weight > 0 else {
            error = "Por favor ingresa un peso válido"
            return
        }
        
        guard weight <= 1000.0 else {
            error = "El peso debe ser menor a 1000 kg"
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                if isEditing, let existingGoal = existingGoal {
                    // Update existing goal
                    _ = try await goalService.updateGoal(
                        goalId: existingGoal.id,
                        targetWeight: weight,
                        targetDate: targetDate
                    )
                } else {
                    // Create new goal
                    _ = try await goalService.createGoal(
                        targetWeight: weight,
                        targetDate: targetDate
                    )
                }
                
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                    onSave() // Refresh dashboard data
                }
                
            } catch {
                await MainActor.run {
                    self.error = goalService.error ?? "Error al guardar la meta"
                    isLoading = false
                }
            }
        }
    }
    
    private func loadExistingGoal() {
        if isEditing, let existingGoal = existingGoal {
            targetWeight = String(format: "%.1f", existingGoal.targetWeight)
            targetDate = existingGoal.targetDate
        } else {
            // Set default date to 3 months from now for new goals
            targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        }
    }
}

struct GoalDatePickerPopover: View {
    @Binding var targetDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Seleccionar Fecha Objetivo")
                .font(Typography.title3)
                .foregroundColor(.primary)
            
            // Use our modern custom calendar
            CustomCalendar(selectedDate: $targetDate)
            
            HStack(spacing: Spacing.lg) {
                CustomButton(action: {
                    showDatePicker = false
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
                    showDatePicker = false
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

#Preview {
    AddGoalModal(isPresented: .constant(true), onSave: {})
}