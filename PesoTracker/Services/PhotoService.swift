//
//  PhotoService.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 22/07/25.
//

import Foundation
import AppKit

class PhotoService {
    static let shared = PhotoService()
    private init() {}

    private let baseURL = "http://100.111.122.121:3000"

    func uploadProgressPhoto(image: NSImage, weight: Double, date: String, notes: String?, weight_entry_id: Int?) async throws -> ProgressPhoto {
        print("📸 PhotoService: Starting photo upload - weight: \(weight), date: \(date), weight_entry_id: \(weight_entry_id ?? -1)")
        let url = URL(string: "\(baseURL)/api/progress-photos")!

        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createBody(with: image, weight: weight, date: date, notes: notes, weight_entry_id: weight_entry_id, boundary: boundary)

        print("📸 PhotoService: Making upload request to \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ PhotoService: Invalid response type")
            throw NSError(domain: "PhotoService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to upload photo"])
        }
        
        print("📊 PhotoService: Response status code: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 PhotoService: Response body: \(responseString)")
        }
        
        guard httpResponse.statusCode == 201 else {
            print("❌ PhotoService: Upload failed with status \(httpResponse.statusCode)")
            throw NSError(domain: "PhotoService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to upload photo"])
        }

        let uploadResponse = try JSONDecoder().decode(UploadPhotoResponse.self, from: data)
        return uploadResponse.data
    }

    func getProgressPhotos() async throws -> [ProgressPhoto] {
        let url = URL(string: "\(baseURL)/api/progress-photos")!

        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "PhotoService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get photos"])
        }

        let photosResponse = try JSONDecoder().decode(ProgressPhotosResponse.self, from: data)
        return photosResponse.data
    }

    func deleteProgressPhoto(id: Int) async throws {
        let url = URL(string: "\(baseURL)/api/progress-photos/\(id)")!

        guard let token = try? KeychainService.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw NSError(domain: "PhotoService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete photo"])
        }
    }
    
    private func createBody(with image: NSImage, weight: Double, date: String, notes: String?, weight_entry_id: Int?, boundary: String) -> Data {
        var body = Data()

        // Photo
        if let imageData = image.tiffRepresentation, let imageRep = NSBitmapImageRep(data: imageData) {
            let jpegData = imageRep.representation(using: .jpeg, properties: [:])!
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".utf8))
            body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
            body.append(jpegData)
            body.append(Data("\r\n".utf8))
        }

        // Weight
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"weight\"\r\n\r\n".utf8))
        body.append(Data("\(weight)".utf8))
        body.append(Data("\r\n".utf8))

        // Date
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"date\"\r\n\r\n".utf8))
        body.append(Data(date.utf8))
        body.append(Data("\r\n".utf8))

        // Notes
        if let notes = notes {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"notes\"\r\n\r\n".utf8))
            body.append(Data(notes.utf8))
            body.append(Data("\r\n".utf8))
        }

        // Weight Entry ID
        if let weight_entry_id = weight_entry_id {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"weight_entry_id\"\r\n\r\n".utf8))
            body.append(Data("\(weight_entry_id)".utf8))
            body.append(Data("\r\n".utf8))
        }

        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}