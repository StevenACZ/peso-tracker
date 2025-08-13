import SwiftUI

/// Manages loading states and overlays for the dashboard
struct LoadingOverlay: View {
    let isLoading: Bool
    let isLoadingPhoto: Bool
    
    var body: some View {
        ZStack {
            if isLoading {
                loadingView(title: customTitle ?? "Cargando datos...")
            } else if isLoadingPhoto {
                loadingView(title: "Cargando foto...")
            }
        }
    }
    
    /// Simple loading overlay for modals and focused contexts
    init(isLoading: Bool, title: String = "Cargando...") {
        self.isLoading = isLoading
        self.isLoadingPhoto = false
        self.customTitle = title
    }
    
    /// Default initializer for dashboard context
    init(isLoading: Bool, isLoadingPhoto: Bool) {
        self.isLoading = isLoading
        self.isLoadingPhoto = isLoadingPhoto
        self.customTitle = nil
    }
    
    private let customTitle: String?
    
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