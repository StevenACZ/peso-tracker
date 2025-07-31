import Foundation
import SwiftUI
import Combine

class DataExportViewModel: ObservableObject {
    @Published var isExporting: Bool = false
    @Published var exportProgress: ExportProgress?
    @Published var exportFolderPath: String?
    @Published var folderDisplayName: String
    @Published var showingExportError: Bool = false
    @Published var exportErrorMessage: String = ""
    
    private let exportService = DataExportService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.exportFolderPath = exportService.lastExportPath
        self.folderDisplayName = exportService.getLastExportFolderDisplayName()
        
        // Subscribe to export service changes
        exportService.$isExporting
            .assign(to: \.isExporting, on: self)
            .store(in: &cancellables)
        
        exportService.$exportProgress
            .assign(to: \.exportProgress, on: self)
            .store(in: &cancellables)
        
        exportService.$lastExportPath
            .sink { [weak self] path in
                self?.exportFolderPath = path
                self?.folderDisplayName = self?.exportService.getLastExportFolderDisplayName() ?? "No seleccionada"
            }
            .store(in: &cancellables)
    }
    
    func selectExportFolder() {
        let success = exportService.selectExportFolder()
        if !success {
            exportErrorMessage = "No se pudo seleccionar la carpeta"
            showingExportError = true
        }
    }
    
    func startDataExport() {
        guard exportFolderPath != nil else {
            exportErrorMessage = "Primero selecciona una carpeta de exportación"
            showingExportError = true
            return
        }
        
        Task {
            do {
                try await exportService.exportAllUserData()
            } catch {
                await MainActor.run {
                    exportErrorMessage = "Error durante la exportación: \(error.localizedDescription)"
                    showingExportError = true
                }
            }
        }
    }
    
    var canStartExport: Bool {
        return !isExporting && exportFolderPath != nil
    }
    
    var exportButtonText: String {
        if isExporting {
            return "Exportando..."
        } else {
            return "Exportar Todos los Datos"
        }
    }
    
    var progressText: String {
        guard let progress = exportProgress else { return "" }
        return "\(progress.currentStepMessage) (\(progress.currentStepNumber)/\(progress.totalSteps))"
    }
    
    var progressPercentage: Double {
        guard let progress = exportProgress else { return 0.0 }
        return Double(progress.currentStepNumber) / Double(progress.totalSteps)
    }
    
    var isExportComplete: Bool {
        return exportProgress?.isComplete == true
    }
}