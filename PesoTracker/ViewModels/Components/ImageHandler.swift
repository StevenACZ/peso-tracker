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
        
        // Debug: Print all available type identifiers
        print("🔍 [DRAG DROP] Available types: \(provider.registeredTypeIdentifiers)")
        
        // Try file URL first (most reliable for Finder drops)
        if provider.hasItemConformingToTypeIdentifier("public.file-url") {
            print("📁 [DRAG DROP] Processing as file URL")
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { [weak self] (item, error) in
                guard error == nil else { 
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error al procesar el archivo arrastrado."
                    }
                    return 
                }
                
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        self?.loadImage(from: url)
                    } else if let url = item as? URL {
                        self?.loadImage(from: url)
                    } else {
                        self?.errorMessage = "No se pudo acceder al archivo arrastrado."
                    }
                }
            }
            return true
        }
        
        // Handle direct image data (browsers, Preview, etc.)
        if provider.hasItemConformingToTypeIdentifier("public.image") {
            print("🖼️ [DRAG DROP] Processing as public.image")
            provider.loadItem(forTypeIdentifier: "public.image", options: nil) { [weak self] (item, error) in
                guard error == nil else { 
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error al procesar la imagen arrastrada."
                    }
                    return 
                }
                
                DispatchQueue.main.async {
                    self?.processDroppedImageItem(item)
                }
            }
            return true
        }
        
        // Handle specific image types as fallback
        let specificTypes = ["public.jpeg", "public.png", "public.gif", "public.heic", "public.tiff"]
        for imageType in specificTypes {
            if provider.hasItemConformingToTypeIdentifier(imageType) {
                print("📷 [DRAG DROP] Processing as \(imageType)")
                provider.loadItem(forTypeIdentifier: imageType, options: nil) { [weak self] (item, error) in
                    guard error == nil else { 
                        DispatchQueue.main.async {
                            self?.errorMessage = "Error al procesar la imagen arrastrada."
                        }
                        return 
                    }
                    
                    DispatchQueue.main.async {
                        if let data = item as? Data {
                            self?.processDroppedImageData(data)
                        } else {
                            self?.processDroppedImageItem(item)
                        }
                    }
                }
                return true
            }
        }
        
        // Try to handle any available type that contains image data
        for typeIdentifier in provider.registeredTypeIdentifiers {
            if typeIdentifier.lowercased().contains("image") || 
               typeIdentifier.contains("jpeg") || 
               typeIdentifier.contains("png") || 
               typeIdentifier.contains("gif") {
                print("🎯 [DRAG DROP] Attempting fallback with type: \(typeIdentifier)")
                provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] (item, error) in
                    guard error == nil else { 
                        DispatchQueue.main.async {
                            self?.errorMessage = "Error al procesar la imagen arrastrada."
                        }
                        return 
                    }
                    
                    DispatchQueue.main.async {
                        if let data = item as? Data {
                            self?.processDroppedImageData(data)
                        } else {
                            self?.processDroppedImageItem(item)
                        }
                    }
                }
                return true
            }
        }
        
        print("❌ [DRAG DROP] No compatible image type found in: \(provider.registeredTypeIdentifiers)")
        return false
    }
    
    // MARK: - Private Helper Methods
    
    private func processDroppedImageItem(_ item: Any?) {
        print("🔄 [DRAG DROP] processDroppedImageItem called with item type: \(type(of: item))")
        
        if let image = item as? NSImage {
            print("✅ [DRAG DROP] Found NSImage, converting to data")
            // Convert NSImage to JPEG data
            guard let tiffData = image.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let imageData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
                errorMessage = "No se pudo procesar la imagen arrastrada."
                return
            }
            
            processDroppedImageData(imageData, originalImage: image)
            
        } else if let data = item as? Data {
            print("✅ [DRAG DROP] Found Data, processing directly")
            processDroppedImageData(data)
            
        } else if let url = item as? URL {
            print("✅ [DRAG DROP] Found URL, loading image from path")
            loadImage(from: url)
            
        } else if let urlString = item as? String, let url = URL(string: urlString) {
            print("✅ [DRAG DROP] Found URL string, loading image from path")
            loadImage(from: url)
            
        } else {
            print("❌ [DRAG DROP] Unknown item type: \(type(of: item))")
            // Try to convert to NSImage as a last resort
            if let data = String(describing: item).data(using: .utf8),
               let image = NSImage(data: data) {
                print("🎯 [DRAG DROP] Successfully converted unknown type to NSImage")
                processDroppedImageItem(image)
            } else {
                errorMessage = "Tipo de contenido no compatible. Por favor, arrastra un archivo de imagen válido."
            }
        }
    }
    
    private func processDroppedImageData(_ data: Data, originalImage: NSImage? = nil) {
        guard data.count <= maxImageSize else {
            errorMessage = "La imagen es muy grande. El tamaño máximo es 10MB."
            return
        }
        
        if let image = originalImage ?? NSImage(data: data) {
            selectedImage = image
            imageData = data
            errorMessage = nil
            print("✅ [DRAG DROP] Imagen procesada exitosamente - Tamaño: \(data.count) bytes")
        } else {
            errorMessage = "No se pudo cargar la imagen arrastrada."
        }
    }
}