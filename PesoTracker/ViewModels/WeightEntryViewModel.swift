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
    @Published var isLoadingData = false
    @Published var errorMessage: String?
    @Published var showErrorModal = false
    @Published var errorModalMessage = ""
    
    // MARK: - Form Validation Properties
    @Published var weightError: String?
    @Published var dateError: String?
    @Published var isValid = false
    @Published var hasAttemptedSave = false
    
    // MARK: - Component Handlers
    private let validationService = UniversalValidationService.shared
    @StateObject private var imageManager = WeightEntryImageManager()
    
    // MARK: - Editing State
    @Published var isEditMode = false
    @Published var editingWeightId: Int?
    
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
        
        // Bind image manager error messages
        imageManager.$errorMessage
            .compactMap { $0 }
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Validation Methods
    
    private func validateWeight(_ weightText: String) -> Bool {
        // Always clear error first
        weightError = nil
        
        let isValid = validationService.validateWeight(weightText)
        
        // Set error message only if validation failed and user has attempted to save
        if !isValid && hasAttemptedSave {
            weightError = validationService.getWeightValidationError(weightText)
        }
        
        return isValid
    }
    
    private func validateDate(_ date: Date) -> Bool {
        dateError = nil
        
        let isValid = validationService.validateDate(date)
        
        // Set error message only if validation failed and user has attempted to save
        if !isValid && hasAttemptedSave {
            dateError = validationService.getDateValidationError(date)
        }
        
        return isValid
    }
    
    
    // MARK: - Image Handling (Delegated)
    func selectImage() {
        imageManager.selectImage()
    }
    
    func removeImage() {
        imageManager.removeImage()
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        return imageManager.handleDrop(providers: providers)
    }
    
    // MARK: - Date Handling Methods
    
    func updateDateString() {
        dateString = DateFormatterFactory.shared.weightEntryFormatter().string(from: date)
    }
    
    func parseDateString() {
        if let parsedDate = DateFormatterFactory.shared.weightEntryFormatter().date(from: dateString) {
            date = parsedDate
        }
    }
    
    // MARK: - Photo Management
    // Note: Photo deletion is handled automatically by the API when updating without photo
    
    // MARK: - Save Methods
    
    func saveWeight() async {
        // Mark that user has attempted to save (for error display)
        hasAttemptedSave = true
        
        guard isValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Convert weight string to double
            let weightValue = Double(weight.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            
            if isEditMode, let weightId = editingWeightId {
                // Update existing weight
                _ = try await weightService.updateWeight(
                    id: weightId,
                    weight: weightValue,
                    date: date,
                    notes: notes.isEmpty ? nil : notes,
                    image: imageManager.selectedImage
                )
            } else {
                // Create new weight entry
                _ = try await weightService.createWeight(
                    weight: weightValue,
                    date: date,
                    notes: notes.isEmpty ? nil : notes,
                    image: imageManager.selectedImage
                )
            }
            
            // Reset form
            resetForm()
            
        } catch let error as APIError {
            showErrorModal(message: error.localizedDescription)
        } catch {
            showErrorModal(message: "Error inesperado: \(error.localizedDescription)")
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
        showErrorModal = false
        errorModalMessage = ""
        isEditMode = false
        isLoadingData = false
        editingWeightId = nil
        hasAttemptedSave = false // Reset save attempt flag
        
        updateDateString()
        imageManager.resetAll()
    }
    
    func loadExistingWeightSimple(_ weight: Weight) async {
        // Check if weight data is in cache to determine loading behavior
        let isInCache = CacheService.shared.hasWeight(weight.id)
        
        // Only show loading if data is not in cache
        if !isInCache {
            isLoadingData = true
        }
        
        isEditMode = true
        editingWeightId = weight.id
        self.weight = String(format: "%.2f", weight.weight)
        self.notes = weight.notes ?? ""
        self.date = weight.date
        updateDateString()
        
        // Handle photo data from the new API structure
        if let photo = weight.photo {
            // Full photo data available (from individual endpoint)
            imageManager.setExistingPhoto(
                photoUrl: photo.thumbnailUrl,
                fullSizeUrl: photo.fullUrl,
                photoId: photo.id
            )
        } else if weight.hasPhoto {
            // Photo exists but we need to fetch full details
            do {
                let fullWeight = try await weightService.getWeight(id: weight.id)
                if let photo = fullWeight.photo {
                    imageManager.setExistingPhoto(
                        photoUrl: photo.thumbnailUrl,
                        fullSizeUrl: photo.fullUrl,
                        photoId: photo.id
                    )
                } else {
                    imageManager.clearExistingPhoto()
                }
            } catch {
                imageManager.clearExistingPhoto()
            }
        } else {
            imageManager.clearExistingPhoto()
        }
        
        // Always hide loading when done (whether it was shown or not)
        isLoadingData = false
    }
    
    func loadExistingWeight(_ weightRecord: WeightRecord) {
        // This method is kept for backward compatibility
        // but we should use loadExistingWeightWithPhotos when possible
        isEditMode = true
        editingWeightId = weightRecord.id
        weight = weightRecord.weight.replacingOccurrences(of: " kg", with: "")
        notes = weightRecord.notes
        
        // Configure image manager for limited photo info
        imageManager.configureForEditingRecord(hasPhotos: weightRecord.hasPhotos)
        
        // Parse date from string format
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone.current
        if let parsedDate = formatter.date(from: weightRecord.date) {
            date = parsedDate
            updateDateString()
        }
        
        print("✏️ [EDIT MODE] Loaded weight for editing (limited photo info):")
        print("   - Weight ID: \(weightRecord.id)")
        print("   - Weight: \(weight)")
        print("   - Date: \(weightRecord.date)")
        print("   - Notes: \(notes)")
        print("   - Images: \(imageManager.debugDescription)")
        print("   ⚠️  Photo deletion will not work - missing photo ID")
    }
    
    
    // MARK: - Computed Properties
    
    var formattedDate: String {
        return DateFormatterFactory.shared.weightEntryFormatter().string(from: date)
    }
    
    var canSave: Bool {
        return isValid && !isLoading
    }
    
    var saveButtonText: String {
        return isLoading ? "Guardando..." : "Guardar"
    }
    
    // MARK: - Image Manager Computed Properties
    
    var selectedImage: NSImage? {
        return imageManager.selectedImage
    }
    
    var hasExistingPhoto: Bool {
        return imageManager.hasExistingPhoto
    }
    
    var existingPhotoUrl: String? {
        return imageManager.existingPhotoUrl
    }
    
    var existingFullSizePhotoUrl: String? {
        return imageManager.existingFullSizePhotoUrl
    }
    
    var hasAnyImage: Bool {
        return imageManager.hasAnyImage
    }
    
    // MARK: - Error Modal Methods
    
    private func showErrorModal(message: String) {
        errorModalMessage = parseErrorMessage(from: message)
        showErrorModal = true
    }
    
    private func parseErrorMessage(from rawError: String) -> String {
        // Try to extract clean message from server error
        guard rawError.contains("Error del servidor") && rawError.contains("{") else {
            return rawError
        }
        
        // Find the JSON part safely
        guard let jsonStart = rawError.firstIndex(of: "{"),
              let jsonEnd = rawError.lastIndex(of: "}"),
              jsonStart < jsonEnd else {
            return rawError
        }
        
        // Extract JSON string safely
        let jsonString = String(rawError[jsonStart...jsonEnd])
        
        // Try to parse JSON and extract message
        guard let jsonData = jsonString.data(using: .utf8),
              let errorObj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let message = errorObj["message"] as? String,
              !message.isEmpty else {
            return rawError
        }
        
        return message
    }
    
    func dismissErrorModal() {
        showErrorModal = false
        errorModalMessage = ""
        errorMessage = nil
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