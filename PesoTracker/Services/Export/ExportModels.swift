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
        exportFolderName: "Peso Steven",
        totalSteps: 5
    )
}