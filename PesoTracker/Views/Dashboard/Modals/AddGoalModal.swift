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
    
    // Date formatter for display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    private var dateString: String {
        return dateFormatter.string(from: targetDate)
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
        VStack(spacing: 20) {
            Text("Seleccionar Fecha Objetivo")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            ZStack {
                DatePicker("", selection: $targetDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .accentColor(.green)
                    .background(Color.clear)
                
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
                    showDatePicker = false
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
                    showDatePicker = false
                }) {
                    Text("Seleccionar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(color: Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.3), radius: 4, x: 0, y: 2)
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

#Preview {
    AddGoalModal(isPresented: .constant(true), onSave: {})
}