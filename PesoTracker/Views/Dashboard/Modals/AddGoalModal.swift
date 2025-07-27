import SwiftUI

struct AddGoalModal: View {
    @Binding var isPresented: Bool
    let isEditing: Bool
    
    init(isPresented: Binding<Bool>, isEditing: Bool = false) {
        self._isPresented = isPresented
        self.isEditing = isEditing
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(isEditing ? "Editar Meta" : "Agregar Meta Principal")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Content placeholder
            VStack(spacing: 16) {
                Text("Modal para agregar/editar meta")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("Aquí irán los campos para establecer la meta de peso")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Buttons
            HStack(spacing: 12) {
                Button("Cancelar") {
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
                
                Button(isEditing ? "Actualizar Meta" : "Establecer Meta") {
                    // TODO: Save logic
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.green)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    AddGoalModal(isPresented: .constant(true))
}