//
//  LocalPhotoService.swift
//  PesoTracker
//
//  Created by Kiro on 22/07/25.
//

import Foundation
import AppKit

class LocalPhotoService: ObservableObject {
    static let shared = LocalPhotoService()
    
    private let documentsDirectory: URL
    private let photosDirectory: URL
    
    @Published private var photoStorage: [Int: NSImage] = [:]
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        photosDirectory = documentsDirectory.appendingPathComponent("PesoTracker/Photos")
        
        // Create photos directory if it doesn't exist
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        
        loadStoredPhotos()
    }
    
    // MARK: - Public Methods
    
    func savePhoto(_ image: NSImage, for weightEntryId: Int) {
        // Save to memory
        photoStorage[weightEntryId] = image
        
        // Save to disk
        savePhotoToDisk(image, for: weightEntryId)
    }
    
    func getPhoto(for weightEntryId: Int) -> NSImage? {
        return photoStorage[weightEntryId]
    }
    
    func deletePhoto(for weightEntryId: Int) {
        // Remove from memory
        photoStorage.removeValue(forKey: weightEntryId)
        
        // Remove from disk
        let photoURL = photosDirectory.appendingPathComponent("\(weightEntryId).jpg")
        try? FileManager.default.removeItem(at: photoURL)
    }
    
    func hasPhoto(for weightEntryId: Int) -> Bool {
        return photoStorage[weightEntryId] != nil
    }
    
    // MARK: - Private Methods
    
    private func savePhotoToDisk(_ image: NSImage, for weightEntryId: Int) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            print("❌ LocalPhotoService: Failed to convert image to JPEG")
            return
        }
        
        let photoURL = photosDirectory.appendingPathComponent("\(weightEntryId).jpg")
        
        do {
            try jpegData.write(to: photoURL)
            print("✅ LocalPhotoService: Photo saved for weight entry \(weightEntryId)")
        } catch {
            print("❌ LocalPhotoService: Failed to save photo: \(error)")
        }
    }
    
    private func loadStoredPhotos() {
        do {
            let photoFiles = try FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            for photoURL in photoFiles {
                let filename = photoURL.deletingPathExtension().lastPathComponent
                if let weightEntryId = Int(filename),
                   let image = NSImage(contentsOf: photoURL) {
                    photoStorage[weightEntryId] = image
                    print("✅ LocalPhotoService: Loaded photo for weight entry \(weightEntryId)")
                }
            }
        } catch {
            print("❌ LocalPhotoService: Failed to load stored photos: \(error)")
        }
    }
}
