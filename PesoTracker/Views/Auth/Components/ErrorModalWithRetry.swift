import SwiftUI

// MARK: - Error Modal with Retry (Shared Component)
struct ErrorModalWithRetry: View {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    let canRetry: Bool
    let onDismiss: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                    onDismiss()
                }
            
            // Error modal
            VStack(spacing: 20) {
                // Error icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                
                // Title
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                // Message
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                // Action buttons
                HStack(spacing: 12) {
                    // Dismiss button
                    CustomButton(action: {
                        isPresented = false
                        onDismiss()
                    }) {
                        Text("Cerrar")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.secondary)
                            .cornerRadius(6)
                    }
                    
                    // Retry button (only show if retry is available)
                    if canRetry {
                        CustomButton(action: {
                            isPresented = false
                            onRetry()
                        }) {
                            Text("Reintentar")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            .padding(32)
            .frame(maxWidth: 400)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Preview
#Preview {
    ErrorModalWithRetry(
        title: "Error de Prueba",
        message: "Este es un mensaje de error de prueba con opción de reintentar.",
        isPresented: .constant(true),
        canRetry: true,
        onDismiss: {},
        onRetry: {}
    )
}