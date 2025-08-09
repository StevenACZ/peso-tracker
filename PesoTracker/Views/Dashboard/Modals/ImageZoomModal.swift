import SwiftUI

struct ImageZoomModal: View {
    @Binding var isPresented: Bool
    
    // Support both NSImage and URL
    let image: NSImage?
    let imageURL: URL?
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    // For NSImage
    init(image: NSImage, isPresented: Binding<Bool>) {
        self.image = image
        self.imageURL = nil
        self._isPresented = isPresented
    }
    
    // For URL
    init(imageURL: URL, isPresented: Binding<Bool>) {
        self.image = nil
        self.imageURL = imageURL
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            // Background - click to close
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                // Header with close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .background(Color.green.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                Spacer()
                
                // Image content
                imageContent
                    .scaleEffect(scale)
                    .offset(offset)
                    .clipped()
                    .gesture(
                        SimultaneousGesture(
                            // Magnification gesture
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    scale = max(0.5, min(newScale, 5.0))
                                }
                                .onEnded { value in
                                    lastScale = scale
                                },
                            
                            // Drag gesture
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { value in
                                    lastOffset = offset
                                }
                        )
                    )
                
                Spacer()
                
                // Bottom controls
                HStack(spacing: 20) {
                    // Reset zoom button
                    Button(action: resetZoom) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Resetear")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Zoom info
                    Text("\(Int(scale * 100))%")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14, design: .monospaced))
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var imageContent: some View {
        if let image = image {
            // Display NSImage directly
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let imageURL = imageURL {
            // Display image from URL
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(1.5)
                    
                    Text("Cargando imagen...")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16))
                }
            }
        } else {
            // Fallback
            VStack(spacing: 16) {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("No se pudo cargar la imagen")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 16))
            }
        }
    }
    
    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }
}

// MARK: - Preview
#Preview {
    // Create a sample NSImage for preview
    let sampleImage = NSImage(size: NSSize(width: 200, height: 200))
    sampleImage.lockFocus()
    NSColor.blue.set()
    NSRect(x: 0, y: 0, width: 200, height: 200).fill()
    sampleImage.unlockFocus()
    
    return ImageZoomModal(image: sampleImage, isPresented: .constant(true))
}