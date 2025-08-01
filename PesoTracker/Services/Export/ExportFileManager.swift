import Foundation
import AppKit

// MARK: - Export File Manager
class ExportFileManager {
    
    func selectExportFolder() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.title = "Seleccionar Carpeta de Exportación"
        panel.message = "Elige donde exportar todos tus datos personales"
        
        if panel.runModal() == .OK {
            if let selectedURL = panel.url {
                return selectedURL.path
            }
        }
        return nil
    }
    
    func createExportFolderStructure(basePath: String, folderName: String) throws -> String {
        let exportFolderPath = "\(basePath)/\(folderName)"
        
        try FileManager.default.createDirectory(
            atPath: exportFolderPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        print("📁 [EXPORT_FILE_MANAGER] Created export folder: \(exportFolderPath)")
        return exportFolderPath
    }
    
    func createWeightFolder(basePath: String, index: Int, weight: Weight) throws -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd MMMM yyyy"
        
        let dateString = formatter.string(from: weight.date)
        let weightFolder = "\(basePath)/\(index + 1) - \(dateString) (\(String(format: "%.1f", weight.weight)))"
        
        try FileManager.default.createDirectory(
            atPath: weightFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        print("📁 [EXPORT_FILE_MANAGER] Created folder: \(index + 1) - \(dateString) (\(weight.weight))")
        return weightFolder
    }
    
    func createPhotoFolder(weightFolder: String) throws -> String {
        let photoFolder = "\(weightFolder)/Foto"
        try FileManager.default.createDirectory(
            atPath: photoFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return photoFolder
    }
    
    func saveImageData(_ data: Data, to folder: String, fileName: String = "IMG_0001.jpg") -> Bool {
        let filePath = "\(folder)/\(fileName)"
        return FileManager.default.createFile(
            atPath: filePath,
            contents: data,
            attributes: nil
        )
    }
    
    func getDisplayName(for path: String) -> String {
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