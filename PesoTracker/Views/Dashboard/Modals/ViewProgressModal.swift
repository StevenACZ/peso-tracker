import SwiftUI

struct ViewProgressModal: View {
    @Binding var isPresented: Bool
    @State private var currentPhotoIndex = 0
    @State private var progressData: [ProgressResponse] = []
    @State private var isLoading = true
    @State private var error: String?
    
    // Computed properties para datos actuales
    private var totalPhotos: Int {
        return progressData.count
    }
    
    private var currentData: ProgressResponse? {
        guard !progressData.isEmpty && currentPhotoIndex < progressData.count else { return nil }
        return progressData[currentPhotoIndex]
    }
    
    private var progressValue: Double {
        guard totalPhotos > 0 else { return 0 }
        return Double(currentPhotoIndex + 1) / Double(totalPhotos)
    }
    
    private var isLastPhoto: Bool {
        return currentPhotoIndex == totalPhotos - 1
    }
    
    // Formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Cargando progreso...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                // Error state
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
                    
                    Button("Cerrar") {
                        isPresented = false
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else if progressData.isEmpty {
                // Empty state
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
                    
                    Button("Cerrar") {
                        isPresented = false
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                // Content with data
                contentView
            }
        }
        .frame(width: 400, height: 640)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            loadProgressData()
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
                // Área de imagen con navegación
                ZStack {
                    // Imagen real o placeholder
                    if let currentData = currentData, let photo = currentData.photo {
                        AsyncImage(url: URL(string: photo.mediumUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.black.opacity(0.8))
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        }
                        .frame(height: 320)
                        .clipped()
                        .cornerRadius(12)
                        .onTapGesture { location in
                            // Detectar si el tap fue en la mitad izquierda o derecha
                            let imageWidth = 360.0 // Ancho aproximado de la imagen (400 - 40 padding)
                            let halfWidth = imageWidth / 2
                            
                            if location.x < halfWidth {
                                // Tap en la mitad izquierda - ir atrás
                                if currentPhotoIndex > 0 {
                                    currentPhotoIndex -= 1
                                }
                            } else {
                                // Tap en la mitad derecha - ir adelante
                                if currentPhotoIndex < totalPhotos - 1 {
                                    currentPhotoIndex += 1
                                }
                            }
                        }
                    } else {
                        // Placeholder cuando no hay foto
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .frame(height: 320)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                            .onTapGesture { location in
                                let imageWidth = 360.0
                                let halfWidth = imageWidth / 2
                                
                                if location.x < halfWidth {
                                    if currentPhotoIndex > 0 {
                                        currentPhotoIndex -= 1
                                    }
                                } else {
                                    if currentPhotoIndex < totalPhotos - 1 {
                                        currentPhotoIndex += 1
                                    }
                                }
                            }
                    }
                    
                    // Iconos de navegación (transparentes) - solo visuales
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .opacity(currentPhotoIndex == 0 ? 0.3 : 0.8)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .opacity(currentPhotoIndex == totalPhotos - 1 ? 0.3 : 0.8)
                    }
                    .padding(.horizontal, 20)
                    .allowsHitTesting(false) // Los íconos no interceptan los taps
                }
                .padding(.horizontal, 20)
                
                // Indicadores de puntos
                HStack(spacing: 8) {
                    ForEach(0..<totalPhotos, id: \.self) { index in
                        Circle()
                            .fill(index == currentPhotoIndex ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Información del peso
                VStack(spacing: 8) {
                    Text(currentData?.weight != nil ? String(format: "%.1f kg", currentData!.weight) : "Sin datos")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(currentData?.date != nil ? dateFormatter.string(from: currentData!.date) : "Sin fecha")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Descripción
                Text(currentData?.notes ?? "Sin notas")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                
                // Barra de progreso
                VStack(spacing: 8) {
                    ProgressView(value: progressValue)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("Photo \(currentPhotoIndex + 1) of \(totalPhotos)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                // Botón Close
                Button(action: {
                    isPresented = false
                }) {
                    Text(isLastPhoto ? "Completar" : "Cerrar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .padding(.top, 16)
        }
    
    // MARK: - Load Progress Data
    private func loadProgressData() {
        Task {
            do {
                let data = try await DashboardService.shared.loadProgressData()
                await MainActor.run {
                    progressData = data
                    isLoading = false
                    error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ViewProgressModal(isPresented: .constant(true))
        .preferredColorScheme(.dark)
}