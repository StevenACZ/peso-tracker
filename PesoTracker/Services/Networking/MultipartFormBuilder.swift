import Foundation

class MultipartFormBuilder {
    
    // MARK: - Properties
    private let httpClient: HTTPClient
    
    // MARK: - Initialization
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - Multipart Form Data Building
    func createMultipartBody(
        parameters: [String: String],
        imageData: Data?,
        imageKey: String = "photo",
        boundary: String
    ) -> Data {
        var body = Data()
        
        // Add text parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image data if provided
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    // MARK: - Multipart Upload Method
    func uploadMultipart<T: Codable>(
        endpoint: String,
        parameters: [String: String],
        imageData: Data?,
        imageKey: String = "photo",
        responseType: T.Type,
        authHeaders: [String: String] = [:],
        method: HTTPMethod = .POST
    ) async throws -> T {
        
        
        // Create multipart form data
        let boundary = UUID().uuidString
        let body = createMultipartBody(
            parameters: parameters,
            imageData: imageData,
            imageKey: imageKey,
            boundary: boundary
        )
        
        // Create headers
        var headers = authHeaders
        headers[Constants.API.Headers.contentType] = "multipart/form-data; boundary=\(boundary)"
        
        // Build request
        let request = try httpClient.buildRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            headers: headers
        )
        
        // Execute request
        return try await httpClient.performRequest(request, responseType: responseType)
    }
}