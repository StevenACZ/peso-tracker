//
//  PhotoManager.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Photo Manager for macOS

class PhotoManager: ObservableObject {
    
    static let shared = PhotoManager()
    
    private let fileManager = FileManager.default
    private let photoDirectory: URL
    
    // MARK: - Initialization
    
    private init() {
        // Create photos directory in Application Support
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("PesoTracker")
        self.photoDirectory = appDirectory.appendingPathComponent("ProgressPhotos")
        
        createPhotoDirectoryIfNeeded()
    }
    
    private func createPhotoDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: photoDirectory.path) {
            do {
                try fileManager.createDirectory(at: photoDirectory, withIntermediateDirectories: true)
                print("📁 PhotoManager: Created photo directory at \(photoDirectory.path)")
            } catch {
                print("❌ PhotoManager: Failed to create photo directory: \(error)")
            }
        }
    }
    
    // MARK: - Photo Selection
    
    /// Show photo picker and return selected image
    func selectPhoto() -> NSImage? {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Progress Photo"
        openPanel.message = "Choose a photo to track your progress"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [.image]
        
        // Set initial directory to Pictures
        if let picturesURL = fileManager.urls(for: .picturesDirectory, in: .userDomainMask).first {
            openPanel.directoryURL = picturesURL
        }
        
        guard openPanel.runModal() == .OK,
              let selectedURL = openPanel.url,
              let image = NSImage(contentsOf: selectedURL) else {
            return nil
        }
        
        print("📸 PhotoManager: Selected photo from \(selectedURL.path)")
        return image
    }
    
    // MARK: - Photo Storage
    
    /// Save progress photo for a weight entry
    func saveProgressPhoto(_ image: NSImage, for weightEntry: WeightEntry) -> String? {
        guard let compressedData = compressImage(image, quality: 0.7) else {
            print("❌ PhotoManager: Failed to compress image")
            return nil
        }
        
        let filename = generatePhotoFilename(for: weightEntry)
        let photoURL = photoDirectory.appendingPathComponent(filename)
        
        do {
            try compressedData.write(to: photoURL)
            print("💾 PhotoManager: Saved photo to \(photoURL.path)")
            
            // Save metadata
            savePhotoMetadata(for: weightEntry, filename: filename, originalSize: image.size)
            
            return filename
        } catch {
            print("❌ PhotoManager: Failed to save photo: \(error)")
            return nil
        }
    }
    
    /// Load progress photo for a weight entry
    func loadProgressPhoto(for weightEntry: WeightEntry) -> NSImage? {
        guard let filename = getPhotoFilename(for: weightEntry) else {
            return nil
        }
        
        let photoURL = photoDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: photoURL.path),
              let image = NSImage(contentsOf: photoURL) else {
            print("❌ PhotoManager: Photo not found at \(photoURL.path)")
            return nil
        }
        
        return image
    }
    
    /// Delete progress photo for a weight entry
    func deleteProgressPhoto(for weightEntry: WeightEntry) {
        guard let filename = getPhotoFilename(for: weightEntry) else {
            return
        }
        
        let photoURL = photoDirectory.appendingPathComponent(filename)
        
        do {
            try fileManager.removeItem(at: photoURL)
            print("🗑️ PhotoManager: Deleted photo \(filename)")
            
            // Remove metadata
            removePhotoMetadata(for: weightEntry)
        } catch {
            print("❌ PhotoManager: Failed to delete photo: \(error)")
        }
    }
    
    /// Get all progress photos with their weight entries
    func getAllProgressPhotos() -> [(WeightEntry, NSImage)] {
        var photos: [(WeightEntry, NSImage)] = []
        
        let metadata = loadAllPhotoMetadata()
        
        for (entryId, photoMetadata) in metadata {
            let photoURL = photoDirectory.appendingPathComponent(photoMetadata.filename)
            
            guard let image = NSImage(contentsOf: photoURL) else { continue }
            
            // Create a mock weight entry (in real implementation, you'd fetch from storage)
            let weightEntry = WeightEntry(
                id: entryId,
                userId: 0,
                weight: 0.0,
                date: photoMetadata.date,
                notes: nil,
                createdAt: photoMetadata.date,
                updatedAt: photoMetadata.date
            )
            
            photos.append((weightEntry, image))
        }
        
        return photos.sorted { $0.0.date < $1.0.date }
    }
    
    // MARK: - Image Processing
    
    /// Compress image for storage
    func compressImage(_ image: NSImage, quality: CGFloat = 0.7) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let _ = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        // Resize if too large
        let resizedImage = resizeImage(image, maxSize: CGSize(width: 1200, height: 1200))
        
        guard let resizedTiffData = resizedImage.tiffRepresentation,
              let resizedBitmapRep = NSBitmapImageRep(data: resizedTiffData) else {
            return nil
        }
        
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: quality
        ]
        
        return resizedBitmapRep.representation(using: .jpeg, properties: properties)
    }
    
    /// Resize image to fit within max size while maintaining aspect ratio
    func resizeImage(_ image: NSImage, maxSize: CGSize) -> NSImage {
        let originalSize = image.size
        
        // Calculate new size maintaining aspect ratio
        let widthRatio = maxSize.width / originalSize.width
        let heightRatio = maxSize.height / originalSize.height
        let scaleFactor = min(widthRatio, heightRatio, 1.0) // Don't upscale
        
        let newSize = CGSize(
            width: originalSize.width * scaleFactor,
            height: originalSize.height * scaleFactor
        )
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize))
        resizedImage.unlockFocus()
        
        return resizedImage
    }
    
    // MARK: - Photo Metadata Management
    
    private func savePhotoMetadata(for weightEntry: WeightEntry, filename: String, originalSize: CGSize) {
        var metadata = loadAllPhotoMetadata()
        
        metadata[weightEntry.id] = PhotoMetadata(
            filename: filename,
            date: weightEntry.date,
            originalSize: originalSize,
            createdAt: Date()
        )
        
        saveAllPhotoMetadata(metadata)
    }
    
    private func removePhotoMetadata(for weightEntry: WeightEntry) {
        var metadata = loadAllPhotoMetadata()
        metadata.removeValue(forKey: weightEntry.id)
        saveAllPhotoMetadata(metadata)
    }
    
    func loadAllPhotoMetadata() -> [Int: PhotoMetadata] {
        let metadataURL = photoDirectory.appendingPathComponent("metadata.json")
        
        guard let data = try? Data(contentsOf: metadataURL),
              let metadata = try? JSONDecoder().decode([Int: PhotoMetadata].self, from: data) else {
            return [:]
        }
        
        return metadata
    }
    
    private func saveAllPhotoMetadata(_ metadata: [Int: PhotoMetadata]) {
        let metadataURL = photoDirectory.appendingPathComponent("metadata.json")
        
        do {
            let data = try JSONEncoder().encode(metadata)
            try data.write(to: metadataURL)
        } catch {
            print("❌ PhotoManager: Failed to save metadata: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func generatePhotoFilename(for weightEntry: WeightEntry) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        return "progress_\(weightEntry.id)_\(dateString).jpg"
    }
    
    private func getPhotoFilename(for weightEntry: WeightEntry) -> String? {
        let metadata = loadAllPhotoMetadata()
        return metadata[weightEntry.id]?.filename
    }
    
    // MARK: - Cloud Sync Preparation
    
    /// Prepare photo for cloud upload (future feature)
    func prepareForCloudUpload(_ image: NSImage) -> Data? {
        return compressImage(image, quality: 0.8)
    }
    
    /// Get photos that need cloud sync (future feature)
    func getPhotosNeedingSync() -> [PhotoSyncItem] {
        let metadata = loadAllPhotoMetadata()
        
        return metadata.compactMap { (entryId, photoMetadata) in
            guard !photoMetadata.isSynced else { return nil }
            
            let photoURL = photoDirectory.appendingPathComponent(photoMetadata.filename)
            guard let imageData = try? Data(contentsOf: photoURL) else { return nil }
            
            return PhotoSyncItem(
                entryId: entryId,
                filename: photoMetadata.filename,
                data: imageData,
                metadata: photoMetadata
            )
        }
    }
    
    /// Mark photo as synced (future feature)
    func markPhotoAsSynced(entryId: Int) {
        var metadata = loadAllPhotoMetadata()
        metadata[entryId]?.isSynced = true
        saveAllPhotoMetadata(metadata)
    }
    
    // MARK: - Storage Management
    
    /// Get total storage used by photos
    func getTotalStorageUsed() -> Int64 {
        guard let enumerator = fileManager.enumerator(at: photoDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                totalSize += Int64(resourceValues.fileSize ?? 0)
            } catch {
                continue
            }
        }
        
        return totalSize
    }
    
    /// Clean up old photos (optional)
    func cleanupOldPhotos(olderThan days: Int) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let metadata = loadAllPhotoMetadata()
        
        for (_, photoMetadata) in metadata {
            guard let photoDate = parseDate(photoMetadata.date),
                  photoDate < cutoffDate else { continue }
            
            let photoURL = photoDirectory.appendingPathComponent(photoMetadata.filename)
            
            do {
                try fileManager.removeItem(at: photoURL)
                print("🧹 PhotoManager: Cleaned up old photo \(photoMetadata.filename)")
            } catch {
                print("❌ PhotoManager: Failed to cleanup photo: \(error)")
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
}

// MARK: - Supporting Data Structures

struct PhotoMetadata: Codable {
    let filename: String
    let date: String
    let originalSize: CGSize
    let createdAt: Date
    var isSynced: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case filename, date, createdAt, isSynced
        case originalSizeWidth = "originalSize_width"
        case originalSizeHeight = "originalSize_height"
    }
    
    init(filename: String, date: String, originalSize: CGSize, createdAt: Date) {
        self.filename = filename
        self.date = date
        self.originalSize = originalSize
        self.createdAt = createdAt
        self.isSynced = false
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filename = try container.decode(String.self, forKey: .filename)
        date = try container.decode(String.self, forKey: .date)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isSynced = try container.decodeIfPresent(Bool.self, forKey: .isSynced) ?? false
        
        // Handle CGSize decoding - simplified approach
        if let width = try? container.decode(Double.self, forKey: .originalSizeWidth),
           let height = try? container.decode(Double.self, forKey: .originalSizeHeight) {
            originalSize = CGSize(width: width, height: height)
        } else {
            originalSize = .zero
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filename, forKey: .filename)
        try container.encode(date, forKey: .date)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isSynced, forKey: .isSynced)
        
        // Handle CGSize encoding - simplified approach
        try container.encode(originalSize.width, forKey: .originalSizeWidth)
        try container.encode(originalSize.height, forKey: .originalSizeHeight)
    }
}

struct PhotoSyncItem {
    let entryId: Int
    let filename: String
    let data: Data
    let metadata: PhotoMetadata
}

// MARK: - Weight Entry Extension

// MARK: - Weight Entry Extension

extension WeightEntry {
    var hasPhoto: Bool {
        let metadata = PhotoManager.shared.loadAllPhotoMetadata()
        return metadata[self.id] != nil
    }
    
    var progressPhoto: NSImage? {
        return PhotoManager.shared.loadProgressPhoto(for: self)
    }
}
