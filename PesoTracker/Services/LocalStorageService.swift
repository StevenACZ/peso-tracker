import Foundation
import AppKit
import SwiftUI

struct ExportProgress {
    let currentStepMessage: String
    let totalSteps: Int
    let currentStepNumber: Int
    let isComplete: Bool
}

class DataExportService: ObservableObject {
    static let shared = DataExportService()
    
    @Published private(set) var isExporting: Bool = false
    @Published private(set) var exportProgress: ExportProgress?
    @Published private(set) var lastExportPath: String?
    
    private let apiService = APIService.shared
    private let dashboardService = DashboardService.shared
    private let weightService = WeightService()
    
    private init() {
        self.lastExportPath = UserDefaults.standard.string(forKey: Constants.UserDefaults.lastExportPath)
    }
    
    func selectExportFolder() -> Bool {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.title = "Seleccionar Carpeta de Exportación"
        panel.message = "Elige donde exportar todos tus datos personales"
        
        if panel.runModal() == .OK {
            if let selectedURL = panel.url {
                let selectedPath = selectedURL.path
                setExportFolder(selectedPath)
                return true
            }
        }
        return false
    }
    
    private func setExportFolder(_ path: String) {
        lastExportPath = path
        UserDefaults.standard.set(path, forKey: Constants.UserDefaults.lastExportPath)
        print("📁 [DATA_EXPORT] Export folder set to: \(path)")
    }
    
    func exportAllUserData() async throws {
        guard let basePath = lastExportPath else {
            throw NSError(domain: "DataExportService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se ha seleccionado carpeta de exportación"])
        }
        
        await MainActor.run {
            isExporting = true
            exportProgress = ExportProgress(currentStepMessage: "Iniciando exportación...", totalSteps: 5, currentStepNumber: 0, isComplete: false)
        }
        
        do {
            // Step 1: Create main export folder
            await updateProgress("Creando estructura de carpetas...", step: 1)
            let exportFolderPath = try createExportFolderStructure(basePath: basePath)
            
            // Step 2: Fetch all weights data
            await updateProgress("Descargando datos de pesos...", step: 2)
            let allWeights = try await fetchAllWeightsData()
            
            // Step 3: Download and organize photos
            await updateProgress("Descargando fotos...", step: 3)
            try await downloadAllPhotos(weights: allWeights, basePath: exportFolderPath)
            
            // Step 4: Create metadata files
            await updateProgress("Creando archivos de información...", step: 4)
            try await createMetadataFiles(weights: allWeights, basePath: exportFolderPath)
            
            // Step 5: Complete export
            await updateProgress("Exportación completada", step: 5, isComplete: true)
            
        } catch {
            await MainActor.run {
                isExporting = false
                exportProgress = nil
            }
            throw error
        }
        
        await MainActor.run {
            isExporting = false
        }
    }
    
    private func createExportFolderStructure(basePath: String) throws -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd MMMM yyyy"
        let dateString = formatter.string(from: Date())
        
        let exportFolderName = "Peso Steven"
        let exportFolderPath = "\(basePath)/\(exportFolderName)"
        
        // Create main folder
        try FileManager.default.createDirectory(
            atPath: exportFolderPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        print("📁 [DATA_EXPORT] Created export folder: \(exportFolderPath)")
        return exportFolderPath
    }
    
    private func fetchAllWeightsData() async throws -> [Weight] {
        var allWeights: [Weight] = []
        var currentPage = 1
        var hasMorePages = true
        
        while hasMorePages {
            await updateProgress("Obteniendo datos... (página \(currentPage))", step: 2)
            
            // Load table data for current page
            await dashboardService.loadTableData(page: currentPage)
            
            guard let tableData = dashboardService.tableData else {
                throw NSError(domain: "DataExportService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No se pudieron obtener los datos de pesos"])
            }
            
            // Add weights from current page
            allWeights.append(contentsOf: tableData.data)
            
            // Check if there are more pages
            hasMorePages = currentPage < tableData.pagination.totalPages
            currentPage += 1
            
            print("📁 [DATA_EXPORT] Fetched page \(currentPage - 1): \(tableData.data.count) weights, hasMore: \(hasMorePages)")
        }
        
        print("📁 [DATA_EXPORT] Total weights fetched: \(allWeights.count)")
        return allWeights
    }
    
    private func downloadAllPhotos(weights: [Weight], basePath: String) async throws {
        // Sort weights by date (oldest first) to create numbered folders in chronological order
        let sortedWeights = weights.sorted { $0.date < $1.date }
        
        for (index, weight) in sortedWeights.enumerated() {
            let progressText = "Procesando registro \(index + 1) de \(sortedWeights.count)..."
            await updateProgress(progressText, step: 3)
            
            // Create folder for this weight entry
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateFormat = "dd MMMM yyyy"
            
            let weightDate = weight.date
            let dateString = formatter.string(from: weightDate)
            let weightFolder = "\(basePath)/\(index + 1) - \(dateString) (\(String(format: "%.1f", weight.weight)))"
            
            try FileManager.default.createDirectory(
                atPath: weightFolder,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            print("📁 [DATA_EXPORT] Created folder: \(index + 1) - \(dateString) (\(weight.weight))")
            
            // Download photo if this weight has one
            if weight.hasPhoto {
                print("📁 [DATA_EXPORT] Weight \(weight.id) has photo flag: true")
                
                // If we don't have photo details from paginated response, fetch them
                let photoDetails: WeightPhoto?
                if let photo = weight.photo {
                    photoDetails = photo
                    print("📁 [DATA_EXPORT] Photo details available from paginated data")
                } else {
                    print("📁 [DATA_EXPORT] Fetching complete photo details for weight \(weight.id)")
                    // Fetch complete weight data to get photo details
                    do {
                        let completeWeight = try await weightService.getWeight(id: weight.id)
                        photoDetails = completeWeight.photo
                        print("📁 [DATA_EXPORT] Fetched complete weight data, photo: \(photoDetails != nil)")
                    } catch {
                        print("❌ [DATA_EXPORT] Failed to fetch complete weight data for \(weight.id): \(error)")
                        photoDetails = nil
                    }
                }
                
                if let photo = photoDetails {
                    let photoFolder = "\(weightFolder)/Foto"
                    try FileManager.default.createDirectory(
                        atPath: photoFolder,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    
                    print("📁 [DATA_EXPORT] Attempting to download from URL: \(photo.fullUrl)")
                    
                    if let url = URL(string: photo.fullUrl) {
                        do {
                            let imageData = try await downloadImage(from: url)
                            let fileName = "IMG_0001.jpg"
                            let filePath = "\(photoFolder)/\(fileName)"
                            
                            let success = FileManager.default.createFile(
                                atPath: filePath,
                                contents: imageData,
                                attributes: nil
                            )
                            
                            if success {
                                print("✅ [DATA_EXPORT] Successfully downloaded photo for weight \(weight.id) to \(filePath)")
                            } else {
                                print("❌ [DATA_EXPORT] Failed to create file for weight \(weight.id)")
                            }
                        } catch {
                            print("❌ [DATA_EXPORT] Failed to download photo for weight \(weight.id): \(error)")
                            // Continue with other photos even if one fails
                        }
                    } else {
                        print("❌ [DATA_EXPORT] Invalid photo URL for weight \(weight.id): \(photo.fullUrl)")
                    }
                } else {
                    print("📁 [DATA_EXPORT] No photo details available for weight \(weight.id)")
                }
            } else {
                print("📁 [DATA_EXPORT] Weight \(weight.id) has no photo")
            }
        }
    }
    
    private func downloadImage(from url: URL) async throws -> Data {
        // Create request with authentication headers if needed
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if we have a token
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("📁 [DATA_EXPORT] Downloading image from: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📁 [DATA_EXPORT] Image download response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "DataExportService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error descargando imagen: HTTP \(httpResponse.statusCode)"])
            }
        }
        
        print("📁 [DATA_EXPORT] Downloaded \(data.count) bytes")
        return data
    }
    
    private func createMetadataFiles(weights: [Weight], basePath: String) async throws {
        // Sort weights the same way as in downloadAllPhotos
        let sortedWeights = weights.sorted { $0.date < $1.date }
        let photosCount = sortedWeights.filter { $0.hasPhoto }.count
        
        // Create a summary JSON file with all weight data
        let summaryData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "totalEntries": sortedWeights.count,
            "totalPhotos": photosCount,
            "weights": sortedWeights.enumerated().map { (index, weight) -> [String: Any] in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "es_ES")
                formatter.dateFormat = "dd MMMM yyyy"
                let dateString = formatter.string(from: weight.date)
                
                return [
                    "folderNumber": index + 1,
                    "folderName": "\(index + 1) - \(dateString) (\(String(format: "%.1f", weight.weight)))",
                    "id": weight.id,
                    "weight": weight.weight,
                    "date": ISO8601DateFormatter().string(from: weight.date),
                    "formattedDate": dateString,
                    "notes": weight.notes ?? "",
                    "hasPhotos": weight.hasPhoto,
                    "photoCount": weight.hasPhoto ? 1 : 0
                ]
            }
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: summaryData, options: .prettyPrinted)
        let summaryPath = "\(basePath)/resumen_datos.json"
        FileManager.default.createFile(atPath: summaryPath, contents: jsonData, attributes: nil)
        
        // Create a README file
        let readmeContent = """
        EXPORTACIÓN DE DATOS PERSONALES - PESO TRACKER
        ==============================================
        
        Fecha de exportación: \(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .short))
        Total de registros: \(sortedWeights.count)
        Total de fotos: \(photosCount)
        
        ESTRUCTURA DE CARPETAS:
        - Cada carpeta representa un registro de peso ordenado cronológicamente
        - Formato: "Número - Fecha (Peso en kg)"
        - Las fotos están en la subcarpeta "Foto" de cada registro
        - Los registros sin foto solo tienen la carpeta principal
        
        ARCHIVOS:
        - resumen_datos.json: Información completa en formato JSON con metadata
        - README.txt: Este archivo explicativo
        
        CONTENIDO:
        Esta exportación contiene TODOS tus datos personales de PesoTracker:
        - Todos los registros de peso históricos
        - Todas las fotos asociadas en calidad completa
        - Todas las notas y observaciones
        - Metadata completa de fechas y seguimiento
        
        Los datos están organizados cronológicamente del más antiguo al más reciente.
        """
        
        let readmePath = "\(basePath)/README.txt"
        try readmeContent.write(toFile: readmePath, atomically: true, encoding: .utf8)
    }
    
    
    private func updateProgress(_ message: String, step: Int, isComplete: Bool = false) async {
        await MainActor.run {
            exportProgress = ExportProgress(
                currentStepMessage: message,
                totalSteps: 5,
                currentStepNumber: step,
                isComplete: isComplete
            )
        }
    }
    
    func getLastExportFolderDisplayName() -> String {
        guard let path = lastExportPath else {
            return "No seleccionada"
        }
        
        let url = URL(fileURLWithPath: path)
        let components = url.pathComponents
        
        if components.count >= 2 {
            let lastTwo = components.suffix(2).joined(separator: "/")
            return ".../" + lastTwo
        } else {
            return url.lastPathComponent
        }
    }
}