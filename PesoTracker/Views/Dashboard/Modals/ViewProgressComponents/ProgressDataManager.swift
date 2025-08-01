import SwiftUI

// MARK: - Progress State Management
enum ProgressViewState {
    case loading
    case error(String)
    case empty
    case content([ProgressResponse])
}

// MARK: - Progress Data Manager
struct ProgressDataManager {
    static func loadProgressData() async -> Result<[ProgressResponse], Error> {
        do {
            let data = try await DashboardService.shared.loadProgressData()
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}