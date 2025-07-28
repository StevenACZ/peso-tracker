import SwiftUI

struct ViewProgressModal: View {
    @Binding var isPresented: Bool
    @State private var currentPhotoIndex = 0
    
    // Sample data - esto se reemplazará con datos reales después
    private let totalPhotos = 5
    
    // Datos que cambian por foto
    private let photoData = [
        (weight: "145 lbs", date: "May 1, 2024", description: "Starting my fitness journey.\nExcited for the changes ahead!"),
        (weight: "147 lbs", date: "May 8, 2024", description: "Week 1 complete!\nFeeling more energetic already."),
        (weight: "149 lbs", date: "May 15, 2024", description: "Feeling great and on track with my fitness goals.\nConsistency is key!"),
        (weight: "151 lbs", date: "May 22, 2024", description: "Halfway to my goal!\nSeeing real progress now."),
        (weight: "153 lbs", date: "May 29, 2024", description: "Goal achieved! 🎉\nProud of this transformation!")
    ]
    
    // Computed properties para datos actuales
    private var currentData: (weight: String, date: String, description: String) {
        return photoData[currentPhotoIndex]
    }
    
    private var progressValue: Double {
        return Double(currentPhotoIndex + 1) / Double(totalPhotos)
    }
    
    private var isLastPhoto: Bool {
        return currentPhotoIndex == totalPhotos - 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Contenido principal
            VStack(spacing: 20) {
                // Área de imagen con navegación
                ZStack {
                    // Imagen placeholder (fondo gris oscuro como en la imagen)
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 200)
                        .cornerRadius(12)
                        .onTapGesture { location in
                            print("Tap en imagen - location: \(location)")
                            // Detectar si el tap fue en la mitad izquierda o derecha
                            let imageWidth = 360.0 // Ancho aproximado de la imagen (400 - 40 padding)
                            let halfWidth = imageWidth / 2
                            
                            if location.x < halfWidth {
                                // Tap en la mitad izquierda - ir atrás
                                print("Navegando atrás")
                                if currentPhotoIndex > 0 {
                                    currentPhotoIndex -= 1
                                }
                            } else {
                                // Tap en la mitad derecha - ir adelante
                                print("Navegando adelante")
                                if currentPhotoIndex < totalPhotos - 1 {
                                    currentPhotoIndex += 1
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
                    Text(currentData.weight)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(currentData.date)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Descripción
                Text(currentData.description)
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
        .frame(width: 400, height: 520)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    ViewProgressModal(isPresented: .constant(true))
}