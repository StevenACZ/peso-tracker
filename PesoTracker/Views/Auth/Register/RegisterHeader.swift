import SwiftUI

struct RegisterHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Crea tu cuenta")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    RegisterHeader()
}