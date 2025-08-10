import SwiftUI

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let onSubmit: (() -> Void)?
    let errorMessage: String?
    let validationState: ValidationState
    let isValidating: Bool
    
    @State private var isSecureVisible = false
    @FocusState private var isFocused: Bool
    
    enum ValidationState {
        case none
        case valid
        case invalid
        case checking
    }
    
    init(text: Binding<String>, 
         placeholder: String, 
         isSecure: Bool = false, 
         onSubmit: (() -> Void)? = nil,
         errorMessage: String? = nil,
         validationState: ValidationState = .none,
         isValidating: Bool = false) {
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.onSubmit = onSubmit
        self.errorMessage = errorMessage
        self.validationState = validationState
        self.isValidating = isValidating
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Text field container
            HStack(spacing: 12) {
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(placeholder, text: $text)
                            .focused($isFocused)
                            .onSubmit {
                                onSubmit?()
                            }
                    } else {
                        TextField(placeholder, text: $text)
                            .focused($isFocused)
                            .onSubmit {
                                onSubmit?()
                            }
                    }
                }
                .font(.system(size: 16))
                .foregroundColor(Color(NSColor.textColor))
                .textFieldStyle(PlainTextFieldStyle())
                
                // Validation indicator and password toggle
                HStack(spacing: 8) {
                    // Validation indicator
                    validationIndicator
                    
                    // Password toggle (if secure field)
                    if isSecure {
                        CustomButton(action: {
                            isSecureVisible.toggle()
                        }) {
                            Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(NSColor.textBackgroundColor))
                    .shadow(color: Color.primary.opacity(0.1), radius: 1, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                borderColor,
                                lineWidth: borderWidth
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.15), value: validationState)
            
            // Error message
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.2), value: errorMessage)
            }
        }
    }
    
    @ViewBuilder
    private var validationIndicator: some View {
        switch validationState {
        case .none:
            EmptyView()
        case .valid:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
        case .invalid:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
        case .checking:
            ProgressView()
                .scaleEffect(0.8)
                .frame(width: 16, height: 16)
        }
    }
    
    private var borderColor: Color {
        if validationState == .invalid || (errorMessage != nil && !errorMessage!.isEmpty) {
            return .red.opacity(0.8)
        } else if validationState == .valid {
            return .green.opacity(0.8)
        } else if isFocused {
            return .blue.opacity(0.8)
        } else {
            return Color.primary.opacity(0.2)
        }
    }
    
    private var borderWidth: CGFloat {
        if validationState == .invalid || validationState == .valid || (errorMessage != nil && !errorMessage!.isEmpty) {
            return 1.5
        } else if isFocused {
            return 1.5
        } else {
            return 0.5
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthTextField(
            text: .constant(""),
            placeholder: "Email",
            validationState: .none
        )
        
        AuthTextField(
            text: .constant("test@example.com"),
            placeholder: "Email",
            validationState: .valid
        )
        
        AuthTextField(
            text: .constant("invalid-email"),
            placeholder: "Email",
            errorMessage: "Formato de email inválido",
            validationState: .invalid
        )
        
        AuthTextField(
            text: .constant("checking@example.com"),
            placeholder: "Email",
            validationState: .checking
        )
        
        AuthTextField(
            text: .constant(""),
            placeholder: "Contraseña",
            isSecure: true,
            onSubmit: { print("Submit") }
        )
        
        AuthTextField(
            text: .constant("short"),
            placeholder: "Contraseña",
            isSecure: true,
            errorMessage: "La contraseña debe tener al menos 6 caracteres",
            validationState: .invalid
        )
    }
    .padding()
}