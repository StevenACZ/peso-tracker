//
//  EditWeightView.swift
//  PesoTracker
//
//  Created by Kiro on 22/07/25.
//

import SwiftUI

struct EditWeightView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let weightEntry: WeightEntry
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var date = Date().addingTimeInterval(-24 * 60 * 60) // Default to yesterday, will be overridden in setupInitialValues
    @State private var selectedImage: NSImage?
    @State private var currentPhoto: NSImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @StateObject private var localPhotoService = LocalPhotoService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Weight Entry")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Date picker (editable)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker("Select date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    
                    // Weight input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight (kg)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter weight", text: $weight)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Notes input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Add notes about your progress...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    
                    // Photo section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Photo")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Current photo display
                        if let currentPhoto = currentPhoto {
                            VStack(spacing: 8) {
                                Text("Current Photo:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Image(nsImage: currentPhoto)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 120)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // New photo selection
                        VStack(spacing: 8) {
                            if selectedImage != nil {
                                Text("New Photo Selected:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: selectPhoto) {
                                HStack {
                                    Image(systemName: selectedImage != nil ? "photo.badge.checkmark" : currentPhoto != nil ? "photo.badge.arrow.down" : "photo.badge.plus")
                                        .font(.title2)
                                    
                                    Text(selectedImage != nil ? "Change Photo" : currentPhoto != nil ? "Replace Photo" : "Add Photo")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // New selected image preview
                            if let newSelectedImage = selectedImage {
                                VStack(spacing: 4) {
                                    Image(nsImage: newSelectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 120)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                    
                                    Button("Remove New Photo") {
                                        selectedImage = nil
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save Changes") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .disabled(weight.isEmpty || isLoading)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 500, maxWidth: 500, minHeight: 600, maxHeight: 600)
        .fixedSize()
        .onAppear {
            setupInitialValues()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialValues() {
        weight = String(format: "%.1f", weightEntry.weightValue)
        notes = weightEntry.notes ?? ""
        
        // Parse the date from the weight entry
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let parsedDate = dateFormatter.date(from: weightEntry.date) {
            date = parsedDate
        }
        
        // Load current photo if exists
        currentPhoto = localPhotoService.getPhoto(for: weightEntry.id)
    }
    
    private func selectPhoto() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            if let url = panel.url,
               let image = NSImage(contentsOf: url) {
                selectedImage = image
            } else {
                errorMessage = "Failed to load selected image"
            }
        }
    }
    
    private func saveChanges() {
        guard let weightValue = Double(weight) else {
            errorMessage = "Please enter a valid weight"
            return
        }
        
        guard weightValue > 0 else {
            errorMessage = "Weight must be greater than 0"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Update the weight entry using the selected date from DatePicker
                try await viewModel.updateWeight(
                    id: weightEntry.id,
                    weight: weightValue,
                    date: date,
                    notes: notes.isEmpty ? nil : notes
                )
                
                // Handle photo update if new photo selected
                if let newPhoto = selectedImage {
                    localPhotoService.savePhoto(newPhoto, for: weightEntry.id)
                    print("📸 EditWeightView: Photo updated for weight entry \(weightEntry.id)")
                }
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update weight entry: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    EditWeightView(
        viewModel: DashboardViewModel(),
        weightEntry: WeightEntry(
            id: 1,
            weight: 75.0,
            date: "2024-01-15",
            notes: "Sample notes"
        )
    )
}
