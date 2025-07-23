//
//  ProgressPhotoSliderView.swift
//  PesoTracker
//
//  Created by Kiro on 22/07/25.
//

import SwiftUI

struct ProgressPhotoSliderView: View {
    let weightEntries: [WeightEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var loadedImages: [Int: NSImage] = [:]
    @StateObject private var localPhotoService = LocalPhotoService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Progress Photos")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            if !weightEntries.isEmpty {
                // Main content
                VStack(spacing: 20) {
                    // Photo display
                    photoDisplaySection
                    
                    // Weight info
                    weightInfoSection
                    
                    // Slider
                    sliderSection
                    
                    // Navigation buttons
                    navigationButtons
                }
                .padding()
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Progress Photos")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add weight entries with photos to see your progress here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 600, height: 600)
        .fixedSize(horizontal: true, vertical: true)
        .onAppear {
            loadCurrentImage()
        }
    }
    
    // MARK: - Photo Display Section
    private var photoDisplaySection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .frame(height: 250)
            
            if let image = loadedImages[currentIndex] {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 240)
                    .cornerRadius(8)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("Loading photo...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Weight Info Section
    private var weightInfoSection: some View {
        let currentEntry = weightEntries[currentIndex]
        
        return VStack(spacing: 8) {
            HStack {
                Text("\(String(format: "%.1f", currentEntry.weightValue)) kg")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(currentEntry.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let notes = currentEntry.notes, !notes.isEmpty {
                HStack {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Progress indicator
            if currentIndex > 0 {
                let previousEntry = weightEntries[currentIndex - 1]
                let change = currentEntry.weightValue - previousEntry.weightValue
                
                HStack {
                    Text("Change from previous:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: change < 0 ? "arrow.down" : change > 0 ? "arrow.up" : "minus")
                            .foregroundColor(change < 0 ? .green : change > 0 ? .red : .secondary)
                            .font(.caption)
                        
                        Text(change == 0 ? "No change" : "\(change > 0 ? "+" : "")\(String(format: "%.1f", change)) kg")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(change < 0 ? .green : change > 0 ? .red : .secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    // MARK: - Slider Section
    private var sliderSection: some View {
        VStack(spacing: 8) {
            Slider(value: Binding(
                get: { Double(currentIndex) },
                set: { newValue in
                    let newIndex = Int(newValue.rounded())
                    if newIndex != currentIndex {
                        currentIndex = newIndex
                        loadCurrentImage()
                    }
                }
            ), in: 0...Double(weightEntries.count - 1), step: 1)
            
            HStack {
                Text("First")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(currentIndex + 1) of \(weightEntries.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Latest")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            Button("Previous") {
                if currentIndex > 0 {
                    currentIndex -= 1
                    loadCurrentImage()
                }
            }
            .disabled(currentIndex == 0)
            
            Spacer()
            
            Button("Next") {
                if currentIndex < weightEntries.count - 1 {
                    currentIndex += 1
                    loadCurrentImage()
                }
            }
            .disabled(currentIndex == weightEntries.count - 1)
        }
    }
    
    // MARK: - Helper Methods
    private func loadCurrentImage() {
        guard currentIndex < weightEntries.count else { return }
        
        let currentEntry = weightEntries[currentIndex]
        
        // Try to load the actual photo from local storage
        if let photo = localPhotoService.getPhoto(for: currentEntry.id) {
            loadedImages[currentIndex] = photo
            print("✅ ProgressPhotoSliderView: Loaded photo for weight entry \(currentEntry.id)")
        } else {
            // Create a placeholder image if no photo exists
            let placeholderImage = NSImage(size: NSSize(width: 200, height: 200))
            placeholderImage.lockFocus()
            NSColor.systemGray.set()
            NSBezierPath(rect: NSRect(x: 0, y: 0, width: 200, height: 200)).fill()
            
            // Add "No Photo" text
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 16, weight: .medium)
            ]
            let text = "No Photo"
            let textSize = text.size(withAttributes: attributes)
            let textRect = NSRect(
                x: (200 - textSize.width) / 2,
                y: (200 - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
            
            placeholderImage.unlockFocus()
            loadedImages[currentIndex] = placeholderImage
            print("📷 ProgressPhotoSliderView: No photo found for weight entry \(currentEntry.id), using placeholder")
        }
    }
}
