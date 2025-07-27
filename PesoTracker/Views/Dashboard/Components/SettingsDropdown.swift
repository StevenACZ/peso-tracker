import SwiftUI

struct SettingsDropdown: View {
    let onAdvancedSettings: () -> Void
    let onLogout: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main dropdown content
            VStack(spacing: 0) {
                // Advanced Settings
                Button(action: {
                    onAdvancedSettings()
                    onDismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .frame(width: 16)
                        
                        Text("Opciones Avanzadas")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.clear)
                .onHover { isHovered in
                    // Add subtle hover effect
                }
                
                Divider()
                    .padding(.horizontal, 8)
                
                // Logout
                Button(action: {
                    onLogout()
                    onDismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(width: 16)
                        
                        Text("Cerrar Sesión")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.clear)
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
        onLogout: {},
        onDismiss: {}
    )
}