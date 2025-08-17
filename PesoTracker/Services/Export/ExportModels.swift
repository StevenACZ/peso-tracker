import Foundation

// MARK: - Export Models
struct ExportProgress {
    let currentStepMessage: String
    let totalSteps: Int
    let currentStepNumber: Int
    let isComplete: Bool
}

struct ExportConfiguration {
    let basePath: String
    let exportFolderName: String
    let totalSteps: Int
    
    static let `default` = ExportConfiguration(
        basePath: "",
        exportFolderName: generateExportFolderName(),
        totalSteps: 5
    )
    
    static func generateExportFolderName() -> String {
        // Get username from authenticated user
        if let currentUser = AuthService.shared.currentUser {
            return "Peso \(currentUser.username)"
        }
        
        // Fallback if no user is authenticated
        return "Peso Usuario"
    }
    
    static func create(basePath: String) -> ExportConfiguration {
        return ExportConfiguration(
            basePath: basePath,
            exportFolderName: generateExportFolderName(),
            totalSteps: 5
        )
    }
}