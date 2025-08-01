import Foundation

// MARK: - Export Metadata Generator
class ExportMetadataGenerator {
    
    func createMetadataFiles(weights: [Weight], basePath: String) throws {
        // Sort weights the same way as in photo downloader
        let sortedWeights = weights.sorted { $0.date < $1.date }
        let photosCount = sortedWeights.filter { $0.hasPhoto }.count
        
        try createSummaryJSON(weights: sortedWeights, photosCount: photosCount, basePath: basePath)
        try createReadmeFile(weights: sortedWeights, photosCount: photosCount, basePath: basePath)
    }
    
    private func createSummaryJSON(weights: [Weight], photosCount: Int, basePath: String) throws {
        let summaryData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "totalEntries": weights.count,
            "totalPhotos": photosCount,
            "weights": weights.enumerated().map { (index, weight) -> [String: Any] in
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
        
        print("📁 [EXPORT_METADATA_GENERATOR] Created summary JSON at: \(summaryPath)")
    }
    
    private func createReadmeFile(weights: [Weight], photosCount: Int, basePath: String) throws {
        let readmeContent = """
        EXPORTACIÓN DE DATOS PERSONALES - PESO TRACKER
        ==============================================
        
        Fecha de exportación: \(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .short))
        Total de registros: \(weights.count)
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
        
        print("📁 [EXPORT_METADATA_GENERATOR] Created README at: \(readmePath)")
    }
}