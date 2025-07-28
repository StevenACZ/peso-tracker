import SwiftUI

struct UserProfileSection: View {
    @ObservedObject var viewModel: DashboardViewModel
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
                    Text(viewModel.formattedUserName)
                        .font(.system(size: 14, weight: .medium))
                    Text(viewModel.formattedUserEmail)
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
    
    private var userInitials: String {
        let name = viewModel.formattedUserName
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let first = String(components[0].prefix(1))
            let last = String(components[1].prefix(1))
            return "\(first)\(last)".uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
}

#Preview {
    UserProfileSection(
        viewModel: DashboardViewModel(),
        showSettingsDropdown: .constant(false),
        onAdvancedSettings: {},
        onLogout: {}
    )
}