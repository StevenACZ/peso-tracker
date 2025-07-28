import Foundation
import AppKit

// MARK: - Image Handler
class ImageHandler: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedImage: NSImage?
    @Published var imageData: Data?
    @Published var errorMessage: String?
    
    // MARK: - Constants
    private let maxImageSize: Int = 10 * 1024 * 1024 // 10MB
    
    // MARK: - Image Selection
    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.jpeg, .png, .gif]
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.prompt = "Seleccionar"
        panel.message = "Selecciona una foto de progreso"
        
        if panel.runModal() == .OK, let url = panel.url {
            loadImage(from: url)
        }
    }
    
    func loadImage(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            
            guard data.count <= maxImageSize else {
                errorMessage = "La imagen es muy grande. El tamaño máximo es 10MB."
                return
            }
            
            guard let image = NSImage(data: data) else {
                errorMessage = "No se pudo cargar la imagen. Asegúrate de que sea un archivo de imagen válido."
                return
            }
            
            selectedImage = image
            imageData = data
            errorMessage = nil
        } catch {
            errorMessage = "Error al cargar la imagen: \(error.localizedDescription)"
        }
    }
    
    func removeImage() {
        selectedImage = nil
        imageData = nil
    }
    
    // MARK: - Drag and Drop Support
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        if provider.hasItemConformingToTypeIdentifier("public.file-url") {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { [weak self] (item, error) in
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        self?.loadImage(from: url)
                    }
                }
            }
            return true
        }
        
        return false
    }
}