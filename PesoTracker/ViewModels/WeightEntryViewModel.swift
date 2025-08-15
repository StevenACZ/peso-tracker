import Foundation
import SwiftUI
import AppKit
import Combine

/// WeightEntryViewModel - Manages weight entry form data, validation, and image handling
/// 
/// Key Features:
/// - Form validation with real-time feedback for weight and date inputs
/// - Date normalization and consistency validation between picker and display
/// - Image handling through WeightEntryImageManager (drag & drop, selection, existing photos)
/// - Edit mode support for updating existing weight entries
/// - Proper error handling with user-friendly messages
/// 
/// Data Flow:
/// 1. User fills form → validates inputs in real-time → enables/disables save button
/// 2. Save action → validates again → calls WeightService → updates UI state
/// 3. Edit mode → loads existing data → pre-fills form → allows updates
/// 4. Image handling → delegates to WeightEntryImageManager → syncs with form state
///
/// Date Handling:
/// - All dates normalized to midnight local time for consistent storage
/// - Date picker changes trigger boundary validation and normalization
/// - Display dates formatted consistently across the app
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
    private let imageManager = WeightEntryImageManager()
    
    // MARK: - Exposed Image Properties
    @Published var selectedImage: NSImage?
    @Published var imageData: Data?
    @Published var existingPhotoUrl: String?
    @Published var hasExistingPhoto = false
    
    // MARK: - Editing State
    @Published var isEditMode = false
    @Published var editingWeightId: Int?
    
    // MARK: - Services and Helpers
    private let weightService = WeightService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Normalize the initial date to midnight in local timezone
        date = DateNormalizer.shared.normalizeForWeightEntry(Date())
        setupValidation()
        setupImageBindings()
        updateDateString()
    }
    
    // MARK: - Setup Methods
    
    /// Sets up real-time form validation using Combine publishers
    /// - Validates weight format and range
    /// - Validates date consistency and normalization
    /// - Updates isValid property for UI binding
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
        
    }
    
    /// Binds WeightEntryImageManager properties to ViewModel published properties
    /// - Syncs image selection state between components
    /// - Handles error propagation from image operations
    /// - Maintains separation of concerns while providing unified interface
    private func setupImageBindings() {
        // Bind image manager properties to published properties
        imageManager.$selectedImage
            .assign(to: &$selectedImage)
        
        imageManager.$imageData
            .assign(to: &$imageData)
        
        imageManager.$existingPhotoUrl
            .assign(to: &$existingPhotoUrl)
        
        imageManager.$hasExistingPhoto
            .assign(to: &$hasExistingPhoto)
        
        imageManager.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            .store(in: &cancellables)
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
        
        // First validate with the existing service
        let isBasicValid = validationService.validateDate(date)
        
        // Additional date consistency validation
        let isNormalized = DateNormalizer.shared.isNormalized(date)
        let isBoundaryValid = DateNormalizer.shared.isSameLocalDay(
            date, 
            DateNormalizer.shared.handleBoundaryEdgeCases(date)
        )
        
        let isValid = isBasicValid && isNormalized && isBoundaryValid
        
        // Set error message only if validation failed and user has attempted to save
        if !isValid && hasAttemptedSave {
            if !isBasicValid {
                dateError = validationService.getDateValidationError(date)
            } else if !isNormalized {
                dateError = "La fecha debe estar normalizada a medianoche"
            } else if !isBoundaryValid {
                dateError = "Fecha inválida para el mes/año seleccionado"
            }
        }
        
        // Log validation results for debugging
        if !isValid {
            print("🚨 [DATE VALIDATION] Date validation failed:")
            print("   Date: \(DateNormalizer.shared.debugDescription(for: date))")
            print("   Basic Valid: \(isBasicValid)")
            print("   Normalized: \(isNormalized)")
            print("   Boundary Valid: \(isBoundaryValid)")
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
    
    /// Updates the date property with proper normalization
    /// This method should be called when the date picker changes
    func updateDate(_ newDate: Date) {
        // Handle boundary edge cases first
        let boundaryHandledDate = DateNormalizer.shared.handleBoundaryEdgeCases(newDate)
        let normalizedDate = DateNormalizer.shared.normalizeForWeightEntry(boundaryHandledDate)
        
        DateNormalizer.shared.logNormalization(
            originalDate: newDate,
            normalizedDate: normalizedDate,
            operation: "updateDate - date picker change with boundary handling"
        )
        
        date = normalizedDate
        updateDateString()
    }
    
    func updateDateString() {
        // Ensure date is normalized before formatting
        let normalizedDate = DateNormalizer.shared.normalizeForWeightEntry(date)
        if !DateNormalizer.shared.isSameLocalDay(date, normalizedDate) {
            date = normalizedDate
            DateNormalizer.shared.logNormalization(
                originalDate: date,
                normalizedDate: normalizedDate,
                operation: "updateDateString normalization"
            )
        }
        dateString = DateFormatterFactory.shared.weightEntryFormatter().string(from: date)
    }
    
    func parseDateString() {
        if let parsedDate = DateFormatterFactory.shared.weightEntryFormatter().date(from: dateString) {
            // Normalize the parsed date to ensure consistency
            let normalizedDate = DateNormalizer.shared.normalizeForWeightEntry(parsedDate)
            date = normalizedDate
            
            DateNormalizer.shared.logNormalization(
                originalDate: parsedDate,
                normalizedDate: normalizedDate,
                operation: "parseDateString normalization"
            )
        }
    }
    
    // MARK: - Photo Management
    // Note: Photo deletion is handled automatically by the API when updating without photo
    
    // MARK: - Save Methods
    
    /// Saves weight entry (create new or update existing)
    /// - Validates form data and date picker consistency
    /// - Creates new entry if not in edit mode, updates if editing
    /// - Handles image upload through WeightService
    /// - Shows error modal on API failures
    /// - Resets form on successful save
    func saveWeight() async {
        // Mark that user has attempted to save (for error display)
        hasAttemptedSave = true
        
        // Validate date picker consistency before proceeding
        if !validateDatePickerConsistency() {
            showErrorModal(message: "Error de sincronización de fecha. Por favor, selecciona la fecha nuevamente.")
            return
        }
        
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
        // Normalize the reset date to ensure consistency
        date = DateNormalizer.shared.normalizeForWeightEntry(Date())
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
    
    /// Loads existing weight data for editing
    /// - Sets edit mode and pre-fills form with existing data
    /// - Normalizes date from API to local timezone
    /// - Handles existing photos with full URL information
    /// - Shows loading state only if data not in cache
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
        
        // Normalize the date from API to preserve local date intent
        let normalizedDate = DateNormalizer.shared.normalizeFromAPI(weight.date)
        self.date = normalizedDate
        
        DateNormalizer.shared.logNormalization(
            originalDate: weight.date,
            normalizedDate: normalizedDate,
            operation: "loadExistingWeightSimple - API date normalization"
        )
        
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
            // Normalize the parsed date to ensure consistency
            let normalizedDate = DateNormalizer.shared.normalizeForWeightEntry(parsedDate)
            date = normalizedDate
            
            DateNormalizer.shared.logNormalization(
                originalDate: parsedDate,
                normalizedDate: normalizedDate,
                operation: "loadExistingWeight - WeightRecord date normalization"
            )
            
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
    
    var existingFullSizePhotoUrl: String? {
        return imageManager.existingFullSizePhotoUrl
    }
    
    var hasAnyImage: Bool {
        return imageManager.hasAnyImage
    }
    
    // MARK: - Date Consistency Validation
    
    /// Validates that the date picker and display are synchronized
    func validateDatePickerConsistency() -> Bool {
        let pickerDate = date
        let displayDate = DateFormatterFactory.shared.parseWeightEntryDate(dateString) ?? Date()
        
        let isConsistent = DateNormalizer.shared.isSameLocalDay(pickerDate, displayDate)
        
        if !isConsistent {
            print("🚨 [DATE CONSISTENCY] Picker and display dates are not synchronized:")
            print("   Picker Date: \(DateNormalizer.shared.debugDescription(for: pickerDate))")
            print("   Display Date: \(DateNormalizer.shared.debugDescription(for: displayDate))")
            print("   Date String: \(dateString)")
        }
        
        return isConsistent
    }
    
    // MARK: - Error Modal Methods
    
    private func showErrorModal(message: String) {
        errorModalMessage = ErrorMessageParser.parseAPIError(from: message)
        showErrorModal = true
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