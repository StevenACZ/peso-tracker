import SwiftUI

struct ViewProgressModal: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Ver Progreso Detallado")
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
                Text("Modal de progreso detallado")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("Aquí irán gráficos y estadísticas detalladas")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 400)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Button
            Button("Cerrar") {
                isPresented = false
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.green)
            .foregroundColor(.white)
            .cornerRadius(6)
        }
        .padding(24)
        .frame(width: 600, height: 500)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    ViewProgressModal(isPresented: .constant(true))
}