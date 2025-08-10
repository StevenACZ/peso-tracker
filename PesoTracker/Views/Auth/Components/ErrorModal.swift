import SwiftUI

struct ErrorModal: View {
    let title: String
    let message: String
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    
    init(title: String = "Error", message: String, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.isPresented = isPresented
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // Modal content
            VStack(spacing: 20) {
                // Header with icon
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                // Message
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Dismiss button
                CustomButton(action: {
                    dismissModal()
                }) {
                    Text("Entendido")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            )
            .frame(maxWidth: 350)
            .animation(.easeInOut(duration: 0.3), value: isPresented.wrappedValue)
        }
        .opacity(isPresented.wrappedValue ? 1 : 0)
        .scaleEffect(isPresented.wrappedValue ? 1 : 0.8)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }
    
    private func dismissModal() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented.wrappedValue = false
        }
        onDismiss?()
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        ErrorModal(
            title: "Error de Autenticación",
            message: "Las credenciales proporcionadas no son correctas. Por favor, verifica tu email y contraseña.",
            isPresented: .constant(true)
        )
    }
}