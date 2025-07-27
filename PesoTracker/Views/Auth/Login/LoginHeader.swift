import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Bienvenido de nuevo")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Inicia sesión para continuar a tu panel.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LoginHeader()
}