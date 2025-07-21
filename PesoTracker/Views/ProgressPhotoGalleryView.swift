//
//  ProgressPhotoGalleryView.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import SwiftUI
import AppKit

struct ProgressPhotoGalleryView: View {
    @StateObject private var photoManager = PhotoManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var photos: [(WeightEntry, NSImage)] = []
    @State private var selectedPhoto: (WeightEntry, NSImage)?
    @State private var showingPhotoDetail = false
    @State private var showingBeforeAfter = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                if photos.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Photo grid
                    photoGridSection
                }
            }
            .navigationTitle("📸 Progress Photos")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if photos.count >= 2 {
                        Button("Before/After") {
                            showingBeforeAfter = true
                        }
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    if photos.count >= 2 {
                        Button("Before/After") {
                            showingBeforeAfter = true
                        }
                    }
                }
                #endif
            }
        }
        .onAppear {
            loadPhotos()
        }
        .sheet(isPresented: $showingPhotoDetail) {
            if let (entry, image) = selectedPhoto {
                PhotoDetailView(weightEntry: entry, image: image)
            }
        }
        .sheet(isPresented: $showingBeforeAfter) {
            if photos.count >= 2 {
                BeforeAfterView(
                    beforePhoto: photos.first!,
                    afterPhoto: photos.last!
                )
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Journey")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(photos.count) photos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !photos.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formattedStorageSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Storage Used")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if photos.count >= 2 {
                // Progress indicator
                let timeSpan = getTimeSpan()
                Text("Journey span: \(timeSpan)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("📸")
                .font(.system(size: 60))
            
            Text("No Progress Photos Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start taking progress photos to visually track your transformation journey.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("Add photos when logging your weight to build your visual progress story.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Photo Grid Section
    
    private var photoGridSection: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photoData in
                    PhotoGridItem(
                        weightEntry: photoData.0,
                        image: photoData.1,
                        index: index,
                        totalCount: photos.count
                    ) {
                        selectedPhoto = photoData
                        showingPhotoDetail = true
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadPhotos() {
        photos = photoManager.getAllProgressPhotos()
    }
    
    private var formattedStorageSize: String {
        let totalBytes = photoManager.getTotalStorageUsed()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalBytes)
    }
    
    private func getTimeSpan() -> String {
        guard let firstDate = parseDate(photos.first?.0.date ?? ""),
              let lastDate = parseDate(photos.last?.0.date ?? "") else {
            return "Unknown"
        }
        
        let timeInterval = lastDate.timeIntervalSince(firstDate)
        let days = Int(timeInterval / (24 * 60 * 60))
        
        if days < 30 {
            return "\(days) days"
        } else if days < 365 {
            let months = days / 30
            return "\(months) months"
        } else {
            let years = days / 365
            return "\(years) years"
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

// MARK: - Photo Grid Item

struct PhotoGridItem: View {
    let weightEntry: WeightEntry
    let image: NSImage
    let index: Int
    let totalCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Photo
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .cornerRadius(8)
                
                // Weight info
                VStack(spacing: 2) {
                    Text("\(String(format: "%.1f", weightEntry.weight)) kg")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(formattedDate(weightEntry.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Progress indicator
                if index == 0 {
                    Text("START")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                } else if index == totalCount - 1 {
                    Text("LATEST")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return dateString }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
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

// MARK: - Photo Detail View

struct PhotoDetailView: View {
    let weightEntry: WeightEntry
    let image: NSImage
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Large photo
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400, maxHeight: 400)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Weight info
                VStack(spacing: 12) {
                    Text("\(String(format: "%.1f", weightEntry.weight)) kg")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(formattedDate(weightEntry.date))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let notes = weightEntry.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Progress Photo")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return dateString }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
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

// MARK: - Before/After View

struct BeforeAfterView: View {
    let beforePhoto: (WeightEntry, NSImage)
    let afterPhoto: (WeightEntry, NSImage)
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Your Transformation")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 30) {
                    // Before photo
                    VStack(spacing: 12) {
                        Text("BEFORE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Image(nsImage: beforePhoto.1)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(12)
                        
                        VStack(spacing: 4) {
                            Text("\(String(format: "%.1f", beforePhoto.0.weight)) kg")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(formattedDate(beforePhoto.0.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Arrow
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    // After photo
                    VStack(spacing: 12) {
                        Text("AFTER")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Image(nsImage: afterPhoto.1)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(12)
                        
                        VStack(spacing: 4) {
                            Text("\(String(format: "%.1f", afterPhoto.0.weight)) kg")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(formattedDate(afterPhoto.0.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Progress summary
                VStack(spacing: 8) {
                    let weightDifference = beforePhoto.0.weight - afterPhoto.0.weight
                    
                    if weightDifference > 0 {
                        Text("🎉 You lost \(String(format: "%.1f", weightDifference)) kg!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else if weightDifference < 0 {
                        Text("You gained \(String(format: "%.1f", abs(weightDifference))) kg")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    } else {
                        Text("Weight maintained")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    let timeSpan = getTimeSpan()
                    Text("Over \(timeSpan)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Before & After")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return dateString }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func getTimeSpan() -> String {
        guard let beforeDate = parseDate(beforePhoto.0.date),
              let afterDate = parseDate(afterPhoto.0.date) else {
            return "Unknown time"
        }
        
        let timeInterval = afterDate.timeIntervalSince(beforeDate)
        let days = Int(timeInterval / (24 * 60 * 60))
        
        if days < 30 {
            return "\(days) days"
        } else if days < 365 {
            let months = days / 30
            return "\(months) months"
        } else {
            let years = days / 365
            return "\(years) years"
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

// MARK: - Preview

#Preview {
    ProgressPhotoGalleryView()
}