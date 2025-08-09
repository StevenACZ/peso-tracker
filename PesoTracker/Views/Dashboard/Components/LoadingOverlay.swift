import SwiftUI

/// Manages loading states and overlays for the dashboard
struct LoadingOverlay: View {
    let isLoading: Bool
    let isLoadingPhoto: Bool
    
    var body: some View {
        ZStack {
            if isLoading {
                loadingView(title: "Cargando datos...")
            } else if isLoadingPhoto {
                loadingView(title: "Cargando foto...")
            }
        }
    }
    
    private func loadingView(title: String) -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .scaleEffect(1.2)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}