import SwiftUI

// MARK: - Progress Photo Viewer Component
struct ProgressPhotoViewer: View {
    let currentData: ProgressResponse?
    let currentIndex: Int
    let totalPhotos: Int
    let onNavigate: (CGPoint) -> Void
    
    var body: some View {
        ZStack {
            // Main image or placeholder
            if let currentData = currentData, let photo = currentData.photo {
                LazyAsyncImage(url: URL(string: photo.mediumUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            VStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.2)
                                Text("Cargando imagen...")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        )
                }
                .frame(height: 320)
                .clipped()
                .cornerRadius(12)
                .onTapGesture(perform: onNavigate)
            } else {
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 320)
                    .cornerRadius(12)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.6))
                            Text("Sin imagen")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    )
                    .onTapGesture(perform: onNavigate)
            }
            
            // Navigation chevrons
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(currentIndex == 0 ? 0.3 : 0.8)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(currentIndex == totalPhotos - 1 ? 0.3 : 0.8)
            }
            .padding(.horizontal, 20)
            .allowsHitTesting(false)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Lazy Async Image Component
struct LazyAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var isVisible = false
    
    var body: some View {
        Group {
            if isVisible {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        content(image)
                    case .failure(_):
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange.opacity(0.8))
                                    Text("Error al cargar")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            )
                    case .empty:
                        placeholder()
                    @unknown default:
                        placeholder()
                    }
                }
            } else {
                placeholder()
                    .onAppear {
                        // Small delay to ensure smooth navigation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isVisible = true
                        }
                    }
            }
        }
    }
}