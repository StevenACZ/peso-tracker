import SwiftUI

struct UserProfileSection: View {
    let userName: String
    let userEmail: String
    let userInitials: String
    @Binding var showSettingsDropdown: Bool
    let onAdvancedSettings: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(NSColor.separatorColor))
            
            HStack(spacing: 12) {
                // Profile avatar
                ZStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 32, height: 32)
                    
                    Text(userInitials)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.system(size: 14, weight: .medium))
                    Text(userEmail)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Settings button
                Button(action: {
                    showSettingsDropdown.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
        }

    }
}

#Preview {
    UserProfileSection(
        userName: "Usuario",
        userEmail: "email@example.com",
        userInitials: "U",
        showSettingsDropdown: .constant(false),
        onAdvancedSettings: {},
        onLogout: {}
    )
}