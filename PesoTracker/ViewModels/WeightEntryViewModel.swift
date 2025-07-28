import Foundation
import SwiftUI
import AppKit
import Combine

@MainActor
class WeightEntryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var weight: String = ""
    @Published var date: Date = Date()
    @Published var dateString: String = ""
    @Published var notes: String = ""
    @Published var showDatePicker = false
    
    // MARK: - State Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Form Validation Properties
    @Published var selectedImage: NSImage?
    @Published var imageData: Data?
    @Published var weightError: String?
    @Published var dateError: String?
    @Published var isValid = false
    
    // MARK: - Component Handlers
    private let validator = WeightFormValidator()
    private let imageHandler = ImageHandler()
    
    // MARK: - Editing State
    @Published var isEditMode = false
    @Published var editingWeightId: Int?
    @Published var existingPhotoUrl: String?
    @Published var existingPhotoId: Int?
    @Published var hasExistingPhoto = false
    
    // MARK: - Services and Helpers
    private let weightService = WeightService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
        updateDateString()
    }
    
    // MARK: - Setup Methods
    
    private func setupValidation() {
        // Validate form in real-time
        Publishers.CombineLatest($weight, $date)
            .map { [weak self] weight, date in
                guard let self = self else { return false }
                let weightValid = self.validateWeight(weight)
                let dateValid = self.validateDate(date)
                return weightValid && dateValid
            }
            .assign(to: &$isValid)
        
        // Bind image handler properties
        imageHandler.$selectedImage
            .assign(to: &$selectedImage)
        
        imageHandler.$imageData
            .assign(to: &$imageData)
        
        imageHandler.$errorMessage
            .compactMap { $0 }
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Validation Methods
    
    private func validateWeight(_ weightText: String) -> Bool {
        weightError = nil
        
        guard !weightText.isEmpty else {
            weightError = "El peso es requerido"
            return false
        }
        
        guard let weightValue = Double(weightText.replacingOccurrences(of: ",", with: ".")) else {
            weightError = "Ingresa un peso válido"
            return false
        }
        
        guard weightValue >= 1.0 && weightValue <= 1000.0 else {
            weightError = "El peso debe estar entre 1.0 y 1000.0 kg"
            return false
        }
        
        return true
    }
    
    private func validateDate(_ date: Date) -> Bool {
        dateError = nil
        
        let calendar = Calendar.current
        let now = Date()
        
        // Don't allow future dates
        if date > now {
            dateError = "No puedes registrar un peso en el futuro"
            return false
        }
        
        // Don't allow dates more than 2 years ago
        if let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: now), date < twoYearsAgo {
            dateError = "La fecha no puede ser anterior a 2 años"
            return false
        }
        
        return true
    }
    
    
    // MARK: - Image Handling (Delegated)
    func selectImage() {
        imageHandler.selectImage()
    }
    
    func removeImage() {
        imageHandler.removeImage()
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        return imageHandler.handleDrop(providers: providers)
    }
    
    // MARK: - Date Handling Methods
    
    func updateDateString() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateString = formatter.string(from: date)
    }
    
    func parseDateString() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        if let parsedDate = formatter.date(from: dateString) {
            date = parsedDate
        }
    }
    
    // MARK: - Photo Management
    // Note: Photo deletion is handled automatically by the API when updating without photo
    
    // MARK: - Save Methods
    
    func saveWeight() async {
        guard isValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Convert weight string to double
            let weightValue = Double(weight.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            
            let weightResult: Weight
            
            if isEditMode, let weightId = editingWeightId {
                // Update existing weight
                weightResult = try await weightService.updateWeight(
                    id: weightId,
                    weight: weightValue,
                    date: date,
                    notes: notes.isEmpty ? nil : notes,
                    image: selectedImage
                )
            } else {
                // Create new weight entry
                weightResult = try await weightService.createWeight(
                    weight: weightValue,
                    date: date,
                    notes: notes.isEmpty ? nil : notes,
                    image: selectedImage
                )
            }
            
            // Reset form
            resetForm()
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    func resetForm() {
        weight = ""
        date = Date()
        dateString = ""
        notes = ""
        errorMessage = nil
        isEditMode = false
        editingWeightId = nil
        existingPhotoUrl = nil
        existingPhotoId = nil
        hasExistingPhoto = false
        
        updateDateString()
        imageHandler.removeImage()
    }
    
    func loadExistingWeightSimple(_ weight: Weight) async {
        isEditMode = true
        editingWeightId = weight.id
        self.weight = String(format: "%.2f", weight.weight)
        self.notes = weight.notes ?? ""
        self.date = weight.date
        updateDateString()
        
        // Handle photo data from the new API structure
        if let photo = weight.photo {
            // Full photo data available (from individual endpoint)
            hasExistingPhoto = true
            existingPhotoUrl = photo.thumbnailUrl
            existingPhotoId = photo.id
        } else if weight.hasPhoto {
            // Photo exists but we need to fetch full details
            do {
                let fullWeight = try await weightService.getWeight(id: weight.id)
                if let photo = fullWeight.photo {
                    hasExistingPhoto = true
                    existingPhotoUrl = photo.thumbnailUrl
                    existingPhotoId = photo.id
                } else {
                    hasExistingPhoto = false
                    existingPhotoUrl = nil
                    existingPhotoId = nil
                }
            } catch {
                hasExistingPhoto = false
                existingPhotoUrl = nil
                existingPhotoId = nil
            }
        } else {
            hasExistingPhoto = false
            existingPhotoUrl = nil
            existingPhotoId = nil
        }
    }
    
    func loadExistingWeight(_ weightRecord: WeightRecord) {
        // This method is kept for backward compatibility
        // but we should use loadExistingWeightWithPhotos when possible
        isEditMode = true
        editingWeightId = weightRecord.id
        weight = weightRecord.weight.replacingOccurrences(of: " kg", with: "")
        notes = weightRecord.notes
        hasExistingPhoto = weightRecord.hasPhotos
        
        // Parse date from string format
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let parsedDate = formatter.date(from: weightRecord.date) {
            date = parsedDate
            updateDateString()
        }
        
        // Note: This method doesn't have photo ID info, so photo deletion won't work
        existingPhotoId = nil
        existingPhotoUrl = nil
        
        print("✏️ [EDIT MODE] Loaded weight for editing (limited photo info):")
        print("   - Weight ID: \(weightRecord.id)")
        print("   - Weight: \(weight)")
        print("   - Date: \(weightRecord.date)")
        print("   - Notes: \(notes)")
        print("   - Has Photos: \(hasExistingPhoto)")
        print("   ⚠️  Photo deletion will not work - missing photo ID")
    }
    
    
    // MARK: - Computed Properties
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    var canSave: Bool {
        return isValid && !isLoading
    }
    
    var saveButtonText: String {
        return isLoading ? "Guardando..." : "Guardar"
    }
}

// MARK: - Extensions

extension WeightEntryViewModel {
    var weightPlaceholder: String {
        return "0.0"
    }
    
    var notesPlaceholder: String {
        return "Ej: Me sentí con más energía hoy."
    }
}