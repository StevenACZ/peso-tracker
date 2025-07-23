//
//  AddWeightView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct AddWeightView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPhoto: NSImage?
    @State private var showingPhotoGallery = false
    
    @StateObject private var localPhotoService = LocalPhotoService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Text("Add Weight Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                Divider()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .background(Color(NSColor.windowBackgroundColor))
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Current weight info
                    if viewModel.currentWeight > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Progress")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("\(String(format: "%.1f", viewModel.currentWeight)) kg")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text("Last Weight")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let goal = viewModel.currentGoal {
                                    VStack(spacing: 4) {
                                        Text("\(String(format: "%.1f", goal.targetWeight)) kg")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        Text("Goal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        let remaining = viewModel.currentWeight - goal.targetWeight
                                        Text("\(String(format: "%.1f", remaining)) kg")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(remaining > 0 ? .orange : .green)
                                        Text("To Go")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                    }
                    
                    // Date selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            DatePicker("Select date", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.field)
                            
                            Spacer()
                            
                            if Calendar.current.isDateInToday(date) {
                                Text("Today")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Weight input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weight (kg)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            TextField("Enter your weight", text: $weight)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 200)
                            
                            if let weightValue = Double(weight), weightValue > 0, viewModel.currentWeight > 0 {
                                VStack(alignment: .leading, spacing: 2) {
                                    let change = weightValue - viewModel.currentWeight
                                    if change != 0 {
                                        Text("Change: \(change > 0 ? "+" : "")\(String(format: "%.1f", change)) kg")
                                            .font(.subheadline)
                                            .foregroundColor(change < 0 ? .green : .red)
                                    } else {
                                        Text("No change")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Progress photo section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Photo (optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let photo = selectedPhoto {
                            // Show selected photo
                            HStack(spacing: 16) {
                                Image(nsImage: photo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Photo selected")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("This photo will be saved with your weight entry to track visual progress")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 12) {
                                        Button("Change Photo") {
                                            selectPhoto()
                                        }
                                        .font(.caption)
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        
                                        Button("Remove") {
                                            selectedPhoto = nil
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                Spacer()
                            }
                        } else {
                            // Photo selection options
                            VStack(spacing: 12) {
                                Button(action: selectPhoto) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "camera")
                                            .font(.title2)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Add Progress Photo")
                                                .fontWeight(.medium)
                                            Text("Track your visual progress")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                                
                                Button("View Photo Gallery") {
                                    showingPhotoGallery = true
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Notes input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (optional)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Add any notes about your progress, how you're feeling, etc.", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                        
                        if !notes.isEmpty {
                            Text("\(notes.count) characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Error message
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            
                            Text(error)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(24)
            }
            
            // Bottom action bar
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Button("Save Weight Entry") {
                        Task {
                            await saveWeight()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(weight.isEmpty || isLoading)
                }
                .padding(24)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .sheet(isPresented: $showingPhotoGallery) {
            ProgressPhotoGalleryView()
        }
    }
    
    private func saveWeight() async {
        guard let weightValue = Double(weight), weightValue > 0 else {
            errorMessage = "Please enter a valid weight"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Call the API to save the weight
            let newWeightEntry = try await viewModel.addWeight(
                weight: weightValue,
                date: date,
                notes: notes.isEmpty ? nil : notes
            )
            
            // Save progress photo locally if selected
            if let photo = selectedPhoto {
                localPhotoService.savePhoto(photo, for: newWeightEntry.id)
                print("📸 AddWeightView: Photo saved locally for weight entry \(newWeightEntry.id)")
            }
            
            // Close the sheet on success
            dismiss()
            
        } catch {
            print("❌ AddWeightView: Failed to save weight: \(error)")
            errorMessage = "Failed to save weight entry: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Photo Methods
    
    private func selectPhoto() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            if let url = panel.url,
               let image = NSImage(contentsOf: url) {
                selectedPhoto = image
            } else {
                errorMessage = "Failed to load selected image"
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
