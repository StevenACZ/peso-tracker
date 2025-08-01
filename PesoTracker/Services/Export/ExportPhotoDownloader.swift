import Foundation

// MARK: - Export Photo Downloader
class ExportPhotoDownloader {
    private let dataFetcher = ExportDataFetcher()
    
    func downloadPhotosForWeights(
        _ weights: [Weight],
        fileManager: ExportFileManager,
        basePath: String,
        progressCallback: @escaping (String) -> Void
    ) async throws {
        // Sort weights by date (oldest first) to create numbered folders in chronological order
        let sortedWeights = weights.sorted { $0.date < $1.date }
        
        for (index, weight) in sortedWeights.enumerated() {
            let progressText = "Procesando registro \(index + 1) de \(sortedWeights.count)..."
            progressCallback(progressText)
            
            // Create folder for this weight entry
            let weightFolder = try fileManager.createWeightFolder(basePath: basePath, index: index, weight: weight)
            
            // Download photo if this weight has one
            if weight.hasPhoto {
                print("📁 [EXPORT_PHOTO_DOWNLOADER] Weight \(weight.id) has photo flag: true")
                
                // Get photo details
                let photoDetails = try await getPhotoDetails(for: weight)
                
                if let photo = photoDetails {
                    let photoFolder = try fileManager.createPhotoFolder(weightFolder: weightFolder)
                    
                    print("📁 [EXPORT_PHOTO_DOWNLOADER] Attempting to download from URL: \(photo.fullUrl)")
                    
                    if let url = URL(string: photo.fullUrl) {
                        do {
                            let imageData = try await downloadImage(from: url)
                            let success = fileManager.saveImageData(imageData, to: photoFolder)
                            
                            if success {
                                print("✅ [EXPORT_PHOTO_DOWNLOADER] Successfully downloaded photo for weight \(weight.id)")
                            } else {
                                print("❌ [EXPORT_PHOTO_DOWNLOADER] Failed to create file for weight \(weight.id)")
                            }
                        } catch {
                            print("❌ [EXPORT_PHOTO_DOWNLOADER] Failed to download photo for weight \(weight.id): \(error)")
                            // Continue with other photos even if one fails
                        }
                    } else {
                        print("❌ [EXPORT_PHOTO_DOWNLOADER] Invalid photo URL for weight \(weight.id): \(photo.fullUrl)")
                    }
                } else {
                    print("📁 [EXPORT_PHOTO_DOWNLOADER] No photo details available for weight \(weight.id)")
                }
            } else {
                print("📁 [EXPORT_PHOTO_DOWNLOADER] Weight \(weight.id) has no photo")
            }
        }
    }
    
    private func getPhotoDetails(for weight: Weight) async throws -> WeightPhoto? {
        // If we have photo details from paginated response, use them
        if let photo = weight.photo {
            print("📁 [EXPORT_PHOTO_DOWNLOADER] Photo details available from paginated data")
            return photo
        } else {
            print("📁 [EXPORT_PHOTO_DOWNLOADER] Fetching complete photo details for weight \(weight.id)")
            // Fetch complete weight data to get photo details
            do {
                let completeWeight = try await dataFetcher.fetchCompleteWeightData(for: weight.id)
                print("📁 [EXPORT_PHOTO_DOWNLOADER] Fetched complete weight data, photo: \(completeWeight.photo != nil)")
                return completeWeight.photo
            } catch {
                print("❌ [EXPORT_PHOTO_DOWNLOADER] Failed to fetch complete weight data for \(weight.id): \(error)")
                return nil
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
        
        print("📁 [EXPORT_PHOTO_DOWNLOADER] Downloading image from: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📁 [EXPORT_PHOTO_DOWNLOADER] Image download response: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "ExportPhotoDownloader", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error descargando imagen: HTTP \(httpResponse.statusCode)"])
            }
        }
        
        print("📁 [EXPORT_PHOTO_DOWNLOADER] Downloaded \(data.count) bytes")
        return data
    }
}