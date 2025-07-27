import SwiftUI

struct AdvancedSettingsModal: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Opciones Avanzadas")
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
                Text("Modal de configuraciones avanzadas")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("Aquí irán las opciones de configuración del usuario")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 300)
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
                
                Button("Guardar Cambios") {
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
        .frame(width: 500)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    AdvancedSettingsModal(isPresented: .constant(true))
}