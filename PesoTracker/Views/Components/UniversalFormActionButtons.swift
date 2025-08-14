import SwiftUI

/// Universal Form Action Buttons - Standardized button layout for forms and modals
/// Replaces duplicate button patterns across AddWeightModal, AddGoalModal, DeleteConfirmationModal
struct UniversalFormActionButtons: View {
    
    // MARK: - Button Configuration
    struct ButtonConfig {
        let text: String
        let style: ButtonStyle
        let action: () -> Void
        let isEnabled: Bool
        
        enum ButtonStyle {
            case cancel       // Gray background, secondary text
            case primary      // Blue background, white text
            case success      // Green background, white text  
            case destructive  // Red background, white text
            case disabled     // Disabled appearance
        }
        
        init(text: String, style: ButtonStyle, isEnabled: Bool = true, action: @escaping () -> Void) {
            self.text = text
            self.style = style
            self.isEnabled = isEnabled
            self.action = action
        }
    }
    
    // MARK: - Properties
    let buttons: [ButtonConfig]
    let spacing: CGFloat
    
    // MARK: - Initializers
    
    /// Standard cancel + action buttons (most common pattern)
    init(
        cancelText: String = "Cancelar",
        actionText: String,
        actionStyle: ButtonConfig.ButtonStyle = .success,
        isActionEnabled: Bool = true,
        spacing: CGFloat = 12,
        onCancel: @escaping () -> Void,
        onAction: @escaping () -> Void
    ) {
        self.spacing = spacing
        self.buttons = [
            ButtonConfig(text: cancelText, style: .cancel, action: onCancel),
            ButtonConfig(text: actionText, style: actionStyle, isEnabled: isActionEnabled, action: onAction)
        ]
    }
    
    /// Custom buttons configuration
    init(buttons: [ButtonConfig], spacing: CGFloat = 12) {
        self.buttons = buttons
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(buttons.indices, id: \.self) { index in
                let button = buttons[index]
                
                CustomButton(action: button.action) {
                    Text(button.text)
                        .typography(Typography.buttonText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(backgroundForStyle(button.style, isEnabled: button.isEnabled))
                        .foregroundColor(textColorForStyle(button.style, isEnabled: button.isEnabled))
                        .cornerRadius(8)
                }
                .disabled(!button.isEnabled)
            }
        }
    }
    
    // MARK: - Style Helpers
    
    private func backgroundForStyle(_ style: ButtonConfig.ButtonStyle, isEnabled: Bool) -> Color {
        if !isEnabled {
            return style.baseColor.opacity(0.5)
        }
        
        switch style {
        case .cancel: return Color.secondary.opacity(0.1)
        case .primary: return ColorTheme.info
        case .success: return ColorTheme.success
        case .destructive: return ColorTheme.error
        case .disabled: return Color.secondary.opacity(0.5)
        }
    }
    
    private func textColorForStyle(_ style: ButtonConfig.ButtonStyle, isEnabled: Bool) -> Color {
        if !isEnabled && style == .cancel {
            return .secondary.opacity(0.6)
        }
        
        switch style {
        case .cancel: return .secondary
        case .primary, .success, .destructive: return .white
        case .disabled: return .secondary.opacity(0.6)
        }
    }
}

// MARK: - ButtonStyle Extension

extension UniversalFormActionButtons.ButtonConfig.ButtonStyle {
    var baseColor: Color {
        switch self {
        case .cancel: return .secondary
        case .primary: return ColorTheme.info
        case .success: return ColorTheme.success
        case .destructive: return ColorTheme.error
        case .disabled: return .secondary
        }
    }
}

// MARK: - Convenience Factories

extension UniversalFormActionButtons {
    
    /// Weight form buttons (Cancelar + Guardar)
    static func weightForm(
        saveText: String = "Guardar",
        isEnabled: Bool,
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) -> UniversalFormActionButtons {
        return UniversalFormActionButtons(
            actionText: saveText,
            actionStyle: .success,
            isActionEnabled: isEnabled,
            onCancel: onCancel,
            onAction: onSave
        )
    }
    
    /// Goal form buttons (Cancelar + Crear Meta)
    static func goalForm(
        createText: String = "Crear Meta",
        isEnabled: Bool,
        onCancel: @escaping () -> Void,
        onCreate: @escaping () -> Void
    ) -> UniversalFormActionButtons {
        return UniversalFormActionButtons(
            actionText: createText,
            actionStyle: .primary,
            isActionEnabled: isEnabled,
            onCancel: onCancel,
            onAction: onCreate
        )
    }
    
    /// Delete confirmation buttons (Cancelar + Eliminar)
    static func deleteConfirmation(
        deleteText: String = "Eliminar",
        onCancel: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> UniversalFormActionButtons {
        return UniversalFormActionButtons(
            actionText: deleteText,
            actionStyle: .destructive,
            isActionEnabled: true,
            onCancel: onCancel,
            onAction: onDelete
        )
    }
    
    /// Auth form buttons (Cancelar + action with loading)
    static func authForm(
        actionText: String,
        isLoading: Bool,
        isEnabled: Bool,
        onCancel: @escaping () -> Void,
        onAction: @escaping () -> Void
    ) -> UniversalFormActionButtons {
        let loadingText = isLoading ? "Cargando..." : actionText
        return UniversalFormActionButtons(
            actionText: loadingText,
            actionStyle: .primary,
            isActionEnabled: isEnabled && !isLoading,
            onCancel: onCancel,
            onAction: onAction
        )
    }
    
    /// Single action button (just one button)
    static func singleAction(
        text: String,
        style: ButtonConfig.ButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> UniversalFormActionButtons {
        return UniversalFormActionButtons(
            buttons: [ButtonConfig(text: text, style: style, isEnabled: isEnabled, action: action)]
        )
    }
    
    /// Three buttons (Cancel + Secondary + Primary)
    static func threeButtons(
        cancelText: String = "Cancelar",
        secondaryText: String,
        primaryText: String,
        isPrimaryEnabled: Bool = true,
        onCancel: @escaping () -> Void,
        onSecondary: @escaping () -> Void,
        onPrimary: @escaping () -> Void
    ) -> UniversalFormActionButtons {
        return UniversalFormActionButtons(
            buttons: [
                ButtonConfig(text: cancelText, style: .cancel, action: onCancel),
                ButtonConfig(text: secondaryText, style: .primary, action: onSecondary),
                ButtonConfig(text: primaryText, style: .success, isEnabled: isPrimaryEnabled, action: onPrimary)
            ],
            spacing: 8
        )
    }
}

// MARK: - Previews

#Preview("Weight Form Buttons") {
    VStack(spacing: 20) {
        UniversalFormActionButtons.weightForm(
            isEnabled: true,
            onCancel: {},
            onSave: {}
        )
        
        UniversalFormActionButtons.weightForm(
            saveText: "Guardando...",
            isEnabled: false,
            onCancel: {},
            onSave: {}
        )
    }
    .padding()
}

#Preview("Delete Confirmation") {
    UniversalFormActionButtons.deleteConfirmation(
        onCancel: {},
        onDelete: {}
    )
    .padding()
}

#Preview("Goal Form") {
    UniversalFormActionButtons.goalForm(
        isEnabled: true,
        onCancel: {},
        onCreate: {}
    )
    .padding()
}

#Preview("Custom Three Buttons") {
    UniversalFormActionButtons.threeButtons(
        secondaryText: "Guardar Borrador",
        primaryText: "Publicar",
        onCancel: {},
        onSecondary: {},
        onPrimary: {}
    )
    .padding()
}