import SwiftUI

struct AuthHeader: View {
    var body: some View {
        HStack {
            Spacer()
            
            // Logo centered
            HStack(spacing: 8) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text("PesoTracker")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .frame(height: 70)
        .padding(.top, 25)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}

#Preview {
    AuthHeader()
}