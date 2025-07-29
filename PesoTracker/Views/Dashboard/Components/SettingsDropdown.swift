import SwiftUI

// MARK: - Reusable Menu Item Component
struct DropdownMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isHovered ? Color.secondary.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct SettingsDropdown: View {
    let onAdvancedSettings: () -> Void
    let onCalculateBMI: () -> Void
    let onLogout: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main dropdown content
            VStack(spacing: 0) {
                DropdownMenuItem(
                    icon: "gearshape",
                    title: "Opciones Avanzadas",
                    color: .primary
                ) {
                    onAdvancedSettings()
                    onDismiss()
                }
                
                Divider()
                    .padding(.horizontal, 8)
                
                DropdownMenuItem(
                    icon: "figure.walk",
                    title: "Calcular IMC",
                    color: .primary
                ) {
                    onCalculateBMI()
                    onDismiss()
                }
                
                Divider()
                    .padding(.horizontal, 8)
                
                DropdownMenuItem(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "Cerrar Sesión",
                    color: .red
                ) {
                    onLogout()
                    onDismiss()
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
            
            // Arrow pointing down to the settings button
            VStack(spacing: 0) {
                Triangle()
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(width: 12, height: 6)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: 70) // Position arrow towards the right where settings button is
            }
        }
        .frame(width: 180)
    }
}

// Custom triangle shape for the dropdown arrow
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SettingsDropdown(
        onAdvancedSettings: {},
        onCalculateBMI: {},
        onLogout: {},
        onDismiss: {}
    )
}