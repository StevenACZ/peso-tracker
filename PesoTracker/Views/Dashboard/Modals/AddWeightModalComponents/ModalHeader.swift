import SwiftUI

struct ModalHeader: View {
    let isEditing: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: isEditing ? "pencil.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text(isEditing ? "Editar Registro de Peso" : "Añadir Registro de Peso")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            CustomButton(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
}