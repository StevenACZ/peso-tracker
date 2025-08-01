import SwiftUI

// MARK: - Progress State Management
enum ProgressViewState {
    case loading
    case error(String)
    case empty
    case content([ProgressResponse])
}

// MARK: - Progress Data Manager
struct ProgressDataManager {
    static func loadProgressData() async -> Result<[ProgressResponse], Error> {
        do {
            let data = try await DashboardService.shared.loadProgressData()
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

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

// MARK: - Progress Indicators Component
struct ProgressIndicators: View {
    let totalPhotos: Int
    let currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPhotos, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Progress Weight Info Component
struct ProgressWeightInfo: View {
    let currentData: ProgressResponse?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(currentData?.weight != nil ? String(format: "%.1f kg", currentData!.weight) : "Sin datos")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(currentData?.date != nil ? dateFormatter.string(from: currentData!.date) : "Sin fecha")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Progress Notes Component
struct ProgressNotes: View {
    let notes: String?
    
    var body: some View {
        Text(notes ?? "Sin notas")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, 20)
    }
}

// MARK: - Progress Bar Component
struct ProgressBarView: View {
    let currentIndex: Int
    let totalPhotos: Int
    
    private var progressValue: Double {
        guard totalPhotos > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalPhotos)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("Photo \(currentIndex + 1) of \(totalPhotos)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Progress Content View Component
struct ProgressContentView: View {
    let progressData: [ProgressResponse]
    @Binding var currentPhotoIndex: Int
    let onClose: () -> Void
    
    private var currentData: ProgressResponse? {
        guard !progressData.isEmpty && currentPhotoIndex < progressData.count else { return nil }
        return progressData[currentPhotoIndex]
    }
    
    private var isLastPhoto: Bool {
        return currentPhotoIndex == progressData.count - 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressPhotoViewer(
                currentData: currentData,
                currentIndex: currentPhotoIndex,
                totalPhotos: progressData.count,
                onNavigate: handlePhotoNavigation
            )
            
            ProgressIndicators(
                totalPhotos: progressData.count,
                currentIndex: currentPhotoIndex
            )
            
            ProgressWeightInfo(currentData: currentData)
            
            ProgressNotes(notes: currentData?.notes)
            
            ProgressBarView(
                currentIndex: currentPhotoIndex,
                totalPhotos: progressData.count
            )
            
            ProgressActionButton(
                title: isLastPhoto ? "Completar" : "Cerrar",
                action: onClose
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .padding(.top, 16)
    }
    
    private func handlePhotoNavigation(location: CGPoint) {
        let imageWidth = 360.0 // Approximate image width (400 - 40 padding)
        let halfWidth = imageWidth / 2
        
        if location.x < halfWidth {
            // Tap on left half - go back
            if currentPhotoIndex > 0 {
                currentPhotoIndex -= 1
            }
        } else {
            // Tap on right half - go forward
            if currentPhotoIndex < progressData.count - 1 {
                currentPhotoIndex += 1
            }
        }
    }
}