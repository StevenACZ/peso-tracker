import Foundation
import SwiftUI

// MARK: - Data Export Service (Refactored)
class DataExportService: ObservableObject {
    static let shared = DataExportService()
    
    @Published private(set) var isExporting: Bool = false
    @Published private(set) var exportProgress: ExportProgress?
    @Published private(set) var lastExportPath: String?
    
    // MARK: - Modular Components
    private let fileManager = ExportFileManager()
    private let dataFetcher = ExportDataFetcher()
    private let photoDownloader = ExportPhotoDownloader()
    private let metadataGenerator = ExportMetadataGenerator()
    
    private let config = ExportConfiguration.default
    
    private init() {
        self.lastExportPath = UserDefaults.standard.string(forKey: Constants.UserDefaults.lastExportPath)
    }
    
    // MARK: - Public Interface
    
    func selectExportFolder() -> Bool {
        if let selectedPath = fileManager.selectExportFolder() {
            setExportFolder(selectedPath)
            return true
        }
        return false
    }
    
    func exportAllUserData() async throws {
        guard let basePath = lastExportPath else {
            throw NSError(domain: "DataExportService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se ha seleccionado carpeta de exportación"])
        }
        
        await startExport()
        
        do {
            // Step 1: Create main export folder
            await updateProgress("Creando estructura de carpetas...", step: 1)
            let exportFolderPath = try fileManager.createExportFolderStructure(
                basePath: basePath,
                folderName: config.exportFolderName
            )
            
            // Step 2: Fetch all weights data
            await updateProgress("Descargando datos de pesos...", step: 2)
            let allWeights = try await dataFetcher.fetchAllWeightsData { message in
                Task { await self.updateProgress(message, step: 2) }
            }
            
            // Step 3: Download and organize photos
            await updateProgress("Descargando fotos...", step: 3)
            try await photoDownloader.downloadPhotosForWeights(
                allWeights,
                fileManager: fileManager,
                basePath: exportFolderPath
            ) { message in
                Task { await self.updateProgress(message, step: 3) }
            }
            
            // Step 4: Create metadata files
            await updateProgress("Creando archivos de información...", step: 4)
            try metadataGenerator.createMetadataFiles(weights: allWeights, basePath: exportFolderPath)
            
            // Step 5: Complete export
            await updateProgress("Exportación completada", step: 5, isComplete: true)
            
        } catch {
            await finishExport()
            throw error
        }
        
        await finishExport()
    }
    
    func getLastExportFolderDisplayName() -> String {
        guard let path = lastExportPath else {
            return "No seleccionada"
        }
        return fileManager.getDisplayName(for: path)
    }
    
    // MARK: - Private Methods
    
    private func setExportFolder(_ path: String) {
        lastExportPath = path
        UserDefaults.standard.set(path, forKey: Constants.UserDefaults.lastExportPath)
        print("📁 [DATA_EXPORT_SERVICE] Export folder set to: \(path)")
    }
    
    private func startExport() async {
        await MainActor.run {
            isExporting = true
            exportProgress = ExportProgress(
                currentStepMessage: "Iniciando exportación...",
                totalSteps: config.totalSteps,
                currentStepNumber: 0,
                isComplete: false
            )
        }
    }
    
    private func finishExport() async {
        await MainActor.run {
            isExporting = false
        }
    }
    
    private func updateProgress(_ message: String, step: Int, isComplete: Bool = false) async {
        await MainActor.run {
            exportProgress = ExportProgress(
                currentStepMessage: message,
                totalSteps: config.totalSteps,
                currentStepNumber: step,
                isComplete: isComplete
            )
        }
    }
}