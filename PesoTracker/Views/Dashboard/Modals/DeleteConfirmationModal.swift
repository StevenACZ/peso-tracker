import SwiftUI

struct DeleteConfirmationModal: View {
    @Binding var isPresented: Bool
    let recordToDelete: WeightRecord?
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
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
                
                if let record = recordToDelete {
                    Text("Peso: \(record.weight) - \(record.date)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text("Esta acción no se puede deshacer.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // Buttons
            HStack(spacing: 12) {
                Button("Cancelar") {
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
                
                Button("Eliminar") {
                    onConfirm()
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(24)
        .frame(width: 350)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    DeleteConfirmationModal(
        isPresented: .constant(true),
        recordToDelete: WeightRecord(id: 1, date: "2024-01-15", weight: "82 kg", notes: "Test", hasPhotos: false),
        onConfirm: {}
    )
}