//
//  ValidationTextField.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

/// Modern validation text field with error display and smooth animations
struct ValidationTextField: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    @Binding var text: String
    let errorMessage: String?
    let isSecure: Bool
    @Binding var showSecureText: Bool
    let onEditingChanged: ((Bool) -> Void)?
    let onCommit: (() -> Void)?
    
    // MARK: - State
    @State private var isFocused = false
    @State private var hasBeenEdited = false
    
    // MARK: - Computed Properties
    private var hasError: Bool {
        errorMessage != nil && hasBeenEdited
    }
    
    private var borderColor: Color {
        if hasError {
            return .red.opacity(0.8)
        } else if isFocused {
            return .accentColor
        } else {
            return Color(NSColor.separatorColor)
        }
    }
    
    private var backgroundColor: Color {
        if hasError {
            return .red.opacity(0.05)
        } else if isFocused {
            return .accentColor.opacity(0.05)
        } else {
            return Color(NSColor.controlBackgroundColor)
        }
    }
    
    // MARK: - Initializers
    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        errorMessage: String? = nil,
        isSecure: Bool = false,
        showSecureText: Binding<Bool> = .constant(false),
        onEditingChanged: ((Bool) -> Void)? = nil,
        onCommit: (() -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
        self.isSecure = isSecure
        self._showSecureText = showSecureText
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title Label
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Error indicator
                if hasError {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Text Field Container
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                    .animation(.easeInOut(duration: 0.2), value: hasError)
                
                // Text Field
                HStack {
                    if isSecure && !showSecureText {
                        SecureField(placeholder, text: $text, onCommit: {
                            onCommit?()
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14))
                    } else {
                        TextField(placeholder, text: $text, onEditingChanged: { editing in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isFocused = editing
                            }
                            if editing {
                                hasBeenEdited = true
                            }
                            onEditingChanged?(editing)
                        }, onCommit: {
                            onCommit?()
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14))
                    }
                    
                    // Show/Hide Password Button
                    if isSecure {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showSecureText.toggle()
                            }
                        }) {
                            Image(systemName: showSecureText ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel(showSecureText ? "Hide password" : "Show password")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(height: 40)
            
            // Error Message
            if let errorMessage = errorMessage, hasBeenEdited {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 11))
                    
                    Text(errorMessage)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: errorMessage)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(text.isEmpty ? "Empty" : text)
        .accessibilityHint(hasError ? errorMessage ?? "" : "")
    }
}

// MARK: - Preview
struct ValidationTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ValidationTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: Binding.constant("test@example.com")
            )
            
            ValidationTextField(
                title: "Email with Error",
                placeholder: "Enter your email",
                text: Binding.constant("invalid-email"),
                errorMessage: "Please enter a valid email address"
            )
            
            ValidationTextField(
                title: "Password",
                placeholder: "Enter your password",
                text: Binding.constant("password123"),
                isSecure: true,
                showSecureText: Binding.constant(false)
            )
        }
        .padding()
        .frame(width: 300)
    }
}