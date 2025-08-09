import SwiftUI

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let onSubmit: (() -> Void)?
    
    @State private var isSecureVisible = false
    @FocusState private var isFocused: Bool
    
    init(text: Binding<String>, placeholder: String, isSecure: Bool = false, onSubmit: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.onSubmit = onSubmit
    }
    
    var body: some View {
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
                            isFocused ? Color.blue.opacity(0.8) : Color.primary.opacity(0.2),
                            lineWidth: isFocused ? 1.5 : 0.5
                        )
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthTextField(
            text: .constant(""),
            placeholder: "Email"
        )
        
        AuthTextField(
            text: .constant(""),
            placeholder: "Password",
            isSecure: true,
            onSubmit: { print("Submit") }
        )
    }
    .padding()
}