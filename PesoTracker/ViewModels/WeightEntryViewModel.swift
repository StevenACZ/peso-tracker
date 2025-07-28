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
    
    // MARK: - Delegated Properties (from components)
    @Published var selectedImage: NSImage?
    @Published var imageData: Data?
    @Published var weightError: String?
    @Published var dateError: String?
    @Published var isValid = false
    
    // MARK: - Editing State
    @Published var isEditMode = false
    @Published var editingWeightId: Int?
    @Published var existingPhotoUrl: String?
    @Published var existingPhotoId: Int?
    @Published var hasExistingPhoto = false
    
    // MARK: - Services and Helpers
    private let weightService = WeightService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private let minWeight: Double = 1.0
    private let maxWeight: Double = 1000.0
    private let maxImageSize: Int = 10 * 1024 * 1024 // 10MB
    
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
        
        guard weightValue >= minWeight && weightValue <= maxWeight else {
            weightError = "El peso debe estar entre \(String(format: "%.2f", minWeight)) y \(String(format: "%.0f", maxWeight)) kg"
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
    
    // MARK: - Image Handling
    
    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.jpeg, .png, .gif]
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.prompt = "Seleccionar"
        panel.message = "Selecciona una foto de progreso"
        
        if panel.runModal() == .OK, let url = panel.url {
            loadImage(from: url)
        }
    }
    
    func loadImage(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            
            guard data.count <= maxImageSize else {
                errorMessage = "La imagen es muy grande. El tamaño máximo es 10MB."
                return
            }
            
            guard let image = NSImage(data: data) else {
                errorMessage = "No se pudo cargar la imagen. Asegúrate de que sea un archivo de imagen válido."
                return
            }
            
            selectedImage = image
            imageData = data
            errorMessage = nil
        } catch {
            errorMessage = "Error al cargar la imagen: \(error.localizedDescription)"
        }
    }
    
    func removeImage() {
        selectedImage = nil
        imageData = nil
    }
    
    // MARK: - Drag and Drop Support
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        if provider.hasItemConformingToTypeIdentifier("public.file-url") {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { [weak self] (item, error) in
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        self?.loadImage(from: url)
                    }
                }
            }
            return true
        }
        
        return false
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