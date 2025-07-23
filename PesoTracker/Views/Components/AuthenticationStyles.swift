import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .frame(maxWidth: CGFloat.infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .frame(maxWidth: CGFloat.infinity)
            .padding()
            .background(.clear)
            .foregroundStyle(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct AuthenticationTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(NSColor.separatorColor).opacity(0.2), lineWidth: 1)
            )
    }
}

extension View {
    func authenticationField() -> some View {
        modifier(AuthenticationTextField())
    }
}
