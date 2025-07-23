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
    
    private init() {}
    
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
        if let picturesURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first {
            openPanel.directoryURL = picturesURL
        }
        
        guard openPanel.runModal() == .OK,
              let selectedURL = openPanel.url,
              let image = NSImage(contentsOf: selectedURL) else {
            return nil
        }
        
        return image
    }
    
    // MARK: - Photo API Calls
    
    func uploadProgressPhoto(image: NSImage, weight: Double, date: String, notes: String?, weight_entry_id: Int?) async throws -> ProgressPhoto {
        return try await PhotoService.shared.uploadProgressPhoto(image: image, weight: weight, date: date, notes: notes, weight_entry_id: weight_entry_id)
    }
    
    func getProgressPhotos() async throws -> [ProgressPhoto] {
        return try await PhotoService.shared.getProgressPhotos()
    }
    
    func deleteProgressPhoto(id: Int) async throws {
        try await PhotoService.shared.deleteProgressPhoto(id: id)
    }
    
    // MARK: - Image Loading
    
    @MainActor
    func loadImage(from url: URL) async -> NSImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return NSImage(data: data)
        } catch {
            return nil
        }
    }
}

// MARK: - ProgressPhoto Extension

extension ProgressPhoto {
    @MainActor
    func loadImage() async -> NSImage? {
        // Construct full URL if needed
        let fullURLString: String
        if medium_url.hasPrefix("http") {
            fullURLString = medium_url
        } else {
            // Assume it's a relative path and prepend base URL
            fullURLString = "http://100.111.122.121:3000\(medium_url)"
        }
        
        guard let url = URL(string: fullURLString) else {
            return nil
        }
        
        return await PhotoManager.shared.loadImage(from: url)
    }
    
    /// Get full URL for thumbnail
    var fullThumbnailURL: String {
        return thumbnail_url.hasPrefix("http") ? thumbnail_url : "http://100.111.122.121:3000\(thumbnail_url)"
    }
    
    /// Get full URL for medium size
    var fullMediumURL: String {
        return medium_url.hasPrefix("http") ? medium_url : "http://100.111.122.121:3000\(medium_url)"
    }
    
    /// Get full URL for full size
    var fullURL: String {
        return full_url.hasPrefix("http") ? full_url : "http://100.111.122.121:3000\(full_url)"
    }
}