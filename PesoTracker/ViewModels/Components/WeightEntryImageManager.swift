import Foundation
import SwiftUI
import AppKit
import Combine

/// Specialized image manager for weight entry contexts
/// Handles both new image selection and existing photo management
@MainActor
class WeightEntryImageManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedImage: NSImage?
    @Published var imageData: Data?
    @Published var errorMessage: String?
    
    // MARK: - Existing Photo Properties
    @Published var existingPhotoUrl: String?
    @Published var existingFullSizePhotoUrl: String?
    @Published var existingPhotoId: Int?
    @Published var hasExistingPhoto = false
    
    // MARK: - Dependencies
    private let imageHandler = ImageHandler()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind image handler properties
        imageHandler.$selectedImage
            .assign(to: &$selectedImage)
        
        imageHandler.$imageData
            .assign(to: &$imageData)
        
        imageHandler.$errorMessage
            .compactMap { $0 }
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Image Selection Methods
    
    /// Select image from file picker
    func selectImage() {
        imageHandler.selectImage()
    }
    
    /// Remove currently selected image
    func removeImage() {
        imageHandler.removeImage()
        clearExistingPhoto()
    }
    
    /// Handle drag and drop operations
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        let result = imageHandler.handleDrop(providers: providers)
        if result {
            // Clear existing photo when new image is selected
            clearExistingPhoto()
        }
        return result
    }
    
    // MARK: - Existing Photo Management
    
    /// Set existing photo information from weight record
    func setExistingPhoto(photoUrl: String?, fullSizeUrl: String?, photoId: Int?) {
        existingPhotoUrl = photoUrl
        existingFullSizePhotoUrl = fullSizeUrl
        existingPhotoId = photoId
        hasExistingPhoto = photoUrl != nil
        
        // Clear any newly selected image when setting existing photo
        if hasExistingPhoto {
            imageHandler.removeImage()
        }
    }
    
    /// Clear existing photo information
    func clearExistingPhoto() {
        existingPhotoUrl = nil
        existingFullSizePhotoUrl = nil
        existingPhotoId = nil
        hasExistingPhoto = false
    }
    
    /// Check if there's any image (new or existing)
    var hasAnyImage: Bool {
        return selectedImage != nil || hasExistingPhoto
    }
    
    /// Get the current image for display purposes
    var displayImage: NSImage? {
        return selectedImage // For now, we prioritize new images over existing ones
    }
    
    /// Get the current photo URL for display (existing photos)
    var displayPhotoUrl: String? {
        return existingPhotoUrl
    }
    
    // MARK: - State Management
    
    /// Reset all image-related state
    func resetAll() {
        imageHandler.removeImage()
        clearExistingPhoto()
        errorMessage = nil
    }
    
    /// Check if user has made changes to images
    var hasImageChanges: Bool {
        return selectedImage != nil // New image selected means changes
    }
    
    // MARK: - Debug Information
    
    var debugDescription: String {
        var info: [String] = []
        
        if let selectedImage = selectedImage {
            info.append("New Image: \(selectedImage.size)")
        }
        
        if hasExistingPhoto {
            info.append("Existing Photo: \(existingPhotoUrl ?? "nil")")
            if let photoId = existingPhotoId {
                info.append("Photo ID: \(photoId)")
            }
        }
        
        if info.isEmpty {
            info.append("No images")
        }
        
        return info.joined(separator: ", ")
    }
}

// MARK: - Convenience Extensions

extension WeightEntryImageManager {
    
    /// Configure for editing an existing weight entry
    func configureForEditing(weight: Weight) {
        resetAll()
        
        // Set existing photo information from Weight model
        if let photo = weight.photo {
            setExistingPhoto(
                photoUrl: photo.thumbnailUrl,
                fullSizeUrl: photo.fullUrl,
                photoId: photo.id
            )
        }
    }
    
    /// Configure for editing from a weight record (limited photo info)
    func configureForEditingRecord(hasPhotos: Bool) {
        resetAll()
        
        if hasPhotos {
            // Limited info - we know there are photos but don't have IDs
            setExistingPhoto(
                photoUrl: "placeholder", // Indicates photos exist
                fullSizeUrl: nil,
                photoId: nil // This will prevent deletion functionality
            )
        }
    }
}