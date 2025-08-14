import SwiftUI

struct DeleteConfirmationModal: View {
    @Binding var isPresented: Bool
    let recordToDelete: WeightRecord?
    let weightToDelete: Weight?
    let onConfirm: () -> Void
    
    @State private var isDeleting = false
    @State private var errorMessage: String?
    private let weightService = WeightService()
    
    // Computed properties for display
    private var displayWeight: String {
        if let record = recordToDelete {
            return record.weight
        } else if let weight = weightToDelete {
            return weight.formattedWeight
        }
        return ""
    }
    
    private var displayDate: String {
        if let record = recordToDelete {
            return record.date
        } else if let weight = weightToDelete {
            return weight.formattedDate
        }
        return ""
    }
    
    private var weightId: Int? {
        if let record = recordToDelete {
            return record.id
        } else if let weight = weightToDelete {
            return weight.id
        }
        return nil
    }
    
    init(isPresented: Binding<Bool>, recordToDelete: WeightRecord?, onConfirm: @escaping () -> Void) {
        self._isPresented = isPresented
        self.recordToDelete = recordToDelete
        self.weightToDelete = nil
        self.onConfirm = onConfirm
    }
    
    init(isPresented: Binding<Bool>, weightToDelete: Weight?, onConfirm: @escaping () -> Void) {
        self._isPresented = isPresented
        self.recordToDelete = nil
        self.weightToDelete = weightToDelete
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: Spacing.sectionSpacing) {
            // Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            // Title
            Text("Confirmar Eliminación")
                .font(.system(size: 18, weight: .semibold))
            
            // Message
            VStack(spacing: 8) {
                Text("¿Estás seguro de que quieres eliminar este registro?")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                
                if !displayWeight.isEmpty && !displayDate.isEmpty {
                    Text("Peso: \(displayWeight) - \(displayDate)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(Spacing.radiusSmall)
                }
                
                Text("Esta acción no se puede deshacer.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // Buttons
            HStack(spacing: Spacing.buttonSpacing) {
                CustomButton(action: {
                    isPresented = false
                }) {
                    Text("Cancelar")
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(Spacing.radiusSmall)
                }
                
                CustomButton(action: {
                    Task {
                        await deleteWeight()
                    }
                }) {
                    Text("Eliminar")
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(Spacing.radiusSmall)
                }
            }
            }
            .padding(Spacing.modalPadding)
            .frame(width: 350)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(Spacing.radiusModal)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .disabled(isDeleting)
            .opacity(isDeleting ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDeleting)
            
            // Loading overlay during delete operation
            if isDeleting {
                LoadingOverlay(isLoading: true, title: "Eliminando peso...")
                    .cornerRadius(Spacing.radiusModal)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Delete Weight Method
    
    private func deleteWeight() async {
        guard let id = weightId else {
            errorMessage = "No se pudo identificar el peso a eliminar"
            return
        }
        
        isDeleting = true
        errorMessage = nil
        
        do {
            _ = try await weightService.deleteWeight(id: id)
            
            // Call the completion handler
            onConfirm()
            
            // Close the modal
            isPresented = false
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
        
        isDeleting = false
    }
}

#Preview {
    DeleteConfirmationModal(
        isPresented: .constant(true),
        recordToDelete: WeightRecord(id: 1, date: "2024-01-15", weight: "82 kg", notes: "Test", hasPhotos: false),
        onConfirm: {}
    )
}