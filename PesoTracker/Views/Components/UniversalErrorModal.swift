import SwiftUI

/// Universal Error Modal - Consolidates ErrorModal and ErrorModalWithRetry
/// Supports customizable actions: dismiss only, retry, or custom actions
struct UniversalErrorModal: View {
    let title: String
    let message: String
    let isPresented: Binding<Bool>
    let actions: [ModalAction]
    let onDismiss: (() -> Void)?
    
    /// Modal action configuration
    struct ModalAction {
        let text: String
        let style: ActionStyle
        let action: () -> Void
        
        enum ActionStyle {
            case primary    // Blue background
            case secondary  // Gray background  
            case destructive // Red background
        }
        
        /// Convenience factory methods
        static func dismiss(onDismiss: @escaping () -> Void) -> ModalAction {
            ModalAction(text: "Entendido", style: .destructive, action: onDismiss)
        }
        
        static func close(onClose: @escaping () -> Void) -> ModalAction {
            ModalAction(text: "Cerrar", style: .secondary, action: onClose)
        }
        
        static func retry(onRetry: @escaping () -> Void) -> ModalAction {
            ModalAction(text: "Reintentar", style: .primary, action: onRetry)
        }
        
        static func custom(text: String, style: ActionStyle, action: @escaping () -> Void) -> ModalAction {
            ModalAction(text: text, style: style, action: action)
        }
    }
    
    /// Single dismiss button (legacy ErrorModal compatibility)
    init(title: String = "Error", message: String, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.isPresented = isPresented
        self.actions = [.dismiss(onDismiss: onDismiss ?? {})]
        self.onDismiss = onDismiss
    }
    
    /// Multiple actions (advanced usage)
    init(title: String, message: String, isPresented: Binding<Bool>, actions: [ModalAction], onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.isPresented = isPresented
        self.actions = actions
        self.onDismiss = onDismiss
    }
    
    /// Retry modal (legacy ErrorModalWithRetry compatibility)
    init(title: String, message: String, isPresented: Binding<Bool>, canRetry: Bool, onDismiss: @escaping () -> Void, onRetry: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        
        var actions: [ModalAction] = [.close(onClose: onDismiss)]
        if canRetry {
            actions.append(.retry(onRetry: onRetry))
        }
        self.actions = actions
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
                    .padding(.horizontal, actions.count > 1 ? 16 : 0)
                
                // Action buttons
                actionButtons
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            )
            .frame(maxWidth: actions.count > 1 ? 400 : 350)
            .animation(.easeInOut(duration: 0.3), value: isPresented.wrappedValue)
        }
        .opacity(isPresented.wrappedValue ? 1 : 0)
        .scaleEffect(isPresented.wrappedValue ? 1 : 0.8)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        if actions.count == 1 {
            // Single button (full width)
            singleActionButton(actions[0])
        } else {
            // Multiple buttons (horizontal)
            HStack(spacing: 12) {
                ForEach(actions.indices, id: \.self) { index in
                    multiActionButton(actions[index])
                }
            }
        }
    }
    
    private func singleActionButton(_ action: ModalAction) -> some View {
        CustomButton(action: {
            dismissModal()
            action.action()
        }) {
            Text(action.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorForStyle(action.style))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func multiActionButton(_ action: ModalAction) -> some View {
        CustomButton(action: {
            dismissModal()
            action.action()
        }) {
            Text(action.text)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(backgroundForStyle(action.style))
                .foregroundColor(textColorForStyle(action.style))
                .cornerRadius(6)
        }
    }
    
    private func colorForStyle(_ style: ModalAction.ActionStyle) -> Color {
        switch style {
        case .primary: return .blue
        case .secondary: return .gray.opacity(0.2)
        case .destructive: return .red
        }
    }
    
    private func backgroundForStyle(_ style: ModalAction.ActionStyle) -> Color {
        switch style {
        case .primary: return .blue
        case .secondary: return .gray.opacity(0.2)
        case .destructive: return .red
        }
    }
    
    private func textColorForStyle(_ style: ModalAction.ActionStyle) -> Color {
        switch style {
        case .primary: return .white
        case .secondary: return .secondary
        case .destructive: return .white
        }
    }
    
    private func dismissModal() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented.wrappedValue = false
        }
        onDismiss?()
    }
}

// MARK: - Previews
#Preview("Single Action (Legacy ErrorModal)") {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        UniversalErrorModal(
            title: "Error de Autenticación",
            message: "Las credenciales proporcionadas no son correctas. Por favor, verifica tu email y contraseña.",
            isPresented: .constant(true)
        )
    }
}

#Preview("Multiple Actions (Legacy ErrorModalWithRetry)") {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        UniversalErrorModal(
            title: "Error de Conexión",
            message: "No se pudo conectar al servidor. Verifica tu conexión a internet.",
            isPresented: .constant(true),
            canRetry: true,
            onDismiss: {},
            onRetry: {}
        )
    }
}

#Preview("Custom Actions") {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        UniversalErrorModal(
            title: "Confirmar Acción",
            message: "¿Estás seguro que deseas eliminar este registro?",
            isPresented: .constant(true),
            actions: [
                .custom(text: "Cancelar", style: .secondary, action: {}),
                .custom(text: "Eliminar", style: .destructive, action: {})
            ]
        )
    }
}