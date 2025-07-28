import Foundation
import AppKit

class ImageCompressionHelper {
    
    // MARK: - Constants
    private let maxSize: CGFloat = 1024
    private let compressionQuality: CGFloat = 0.8
    
    // MARK: - Image Compression Methods
    
    func compressImage(_ image: NSImage) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            print("❌ [IMAGE COMPRESSION] Failed to get bitmap representation")
            return nil
        }
        
        print("📸 [IMAGE COMPRESSION] Original image size: \(image.size)")
        
        // Resize if needed (max 1024px)
        var newSize = image.size
        
        if max(newSize.width, newSize.height) > maxSize {
            let scale = maxSize / max(newSize.width, newSize.height)
            newSize = CGSize(width: newSize.width * scale, height: newSize.height * scale)
            
            print("📸 [IMAGE COMPRESSION] Resizing to: \(newSize)")
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: newSize))
            resizedImage.unlockFocus()
            
            guard let resizedTiffData = resizedImage.tiffRepresentation,
                  let resizedBitmapImage = NSBitmapImageRep(data: resizedTiffData) else {
                print("⚠️ [IMAGE COMPRESSION] Failed to resize, using original")
                return compressToJPEG(bitmapImage)
            }
            
            return compressToJPEG(resizedBitmapImage)
        }
        
        print("📸 [IMAGE COMPRESSION] No resizing needed")
        return compressToJPEG(bitmapImage)
    }
    
    private func compressToJPEG(_ bitmapImage: NSBitmapImageRep) -> Data? {
        let compressedData = bitmapImage.representation(
            using: .jpeg, 
            properties: [.compressionFactor: compressionQuality]
        )
        
        if let data = compressedData {
            print("📸 [IMAGE COMPRESSION] Compressed to \(data.count) bytes")
        } else {
            print("❌ [IMAGE COMPRESSION] Failed to compress to JPEG")
        }
        
        return compressedData
    }
    
    // MARK: - Validation Methods
    
    func validateImageSize(_ data: Data, maxSizeBytes: Int = 10 * 1024 * 1024) -> Bool {
        let isValid = data.count <= maxSizeBytes
        
        if !isValid {
            print("❌ [IMAGE VALIDATION] Image too large: \(data.count) bytes (max: \(maxSizeBytes))")
        } else {
            print("✅ [IMAGE VALIDATION] Image size valid: \(data.count) bytes")
        }
        
        return isValid
    }
    
    func validateImageFormat(_ data: Data) -> Bool {
        guard NSImage(data: data) != nil else {
            print("❌ [IMAGE VALIDATION] Invalid image format")
            return false
        }
        
        print("✅ [IMAGE VALIDATION] Image format valid")
        return true
    }
}