import SwiftUI

// MARK: - Progress Loading View Component
struct ProgressLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Cargando progreso...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Progress Error View Component
struct ProgressErrorView: View {
    let error: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text("Error al cargar progreso")
                .font(.system(size: 16, weight: .medium))
            
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            ProgressActionButton(
                title: "Cerrar",
                action: onClose
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

// MARK: - Progress Empty View Component
struct ProgressEmptyView: View {
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("Sin fotos de progreso")
                .font(.system(size: 16, weight: .medium))
            
            Text("Agrega fotos a tus registros de peso para ver tu progreso visual")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            ProgressActionButton(
                title: "Cerrar",
                action: onClose
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

// MARK: - Progress Action Button Component
struct ProgressActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}