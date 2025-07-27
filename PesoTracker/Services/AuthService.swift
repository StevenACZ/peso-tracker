import Foundation

// MARK: - Auth Service
class AuthService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthService()
    
    // MARK: - Properties
    private let apiService = APIService.shared
    private let keychainHelper = KeychainHelper.shared
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    // MARK: - Initialization
    private init() {
        print("🔐 [AUTH SERVICE] Initializing authentication service")
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        if let token = keychainHelper.get(key: Constants.Keychain.jwtToken),
           !token.isEmpty {
            print("🔐 [AUTH SERVICE] Valid token found in keychain")
            isAuthenticated = true
            // Load user data if available
            loadCurrentUser()
        } else {
            print("🔐 [AUTH SERVICE] No valid token found")
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    private func loadCurrentUser() {
        if keychainHelper.get(key: Constants.Keychain.userID) != nil {
            // In a real app, you might want to fetch fresh user data from the API
            // For now, we'll just mark as authenticated
            // TODO: Implement user profile fetching if needed
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> User {
        let loginRequest = LoginRequest(email: email, password: password)
        
        print("🔐 [LOGIN] Enviando request:")
        print("   Email: \(email)")
        print("   Password: [HIDDEN]")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.login)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.login,
                body: loginRequest,
                responseType: AuthResponse.self,
                requiresAuth: false
            )
            
            print("✅ [LOGIN] Respuesta recibida:")
            print("   User ID: \(response.user.id)")
            print("   Username: \(response.user.username)")
            print("   Email: \(response.user.email)")
            print("   Token: \(String(response.token.prefix(20)))...")
            print("   Expires: \(response.expiresAt)")
            
            // Save token and user ID to keychain
            let tokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.token)
            let userIDSaved = keychainHelper.save(key: Constants.Keychain.userID, value: response.user.id)
            
            guard tokenSaved && userIDSaved else {
                throw APIError.serverError(500, "Error al guardar credenciales")
            }
            
            // Update authentication state
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = response.user
            }
            
            print("✅ [LOGIN] Login exitoso!")
            return response.user
            
        } catch {
            print("❌ [LOGIN] Error en login:")
            print("   Error: \(error)")
            
            // Ensure we're not authenticated on login failure
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
            throw error
        }
    }
    
    // MARK: - Register
    func register(username: String, email: String, password: String) async throws -> User {
        let registerRequest = RegisterRequest(
            username: username,
            email: email,
            password: password
        )
        
        print("🔐 [REGISTER] Enviando request:")
        print("   Username: \(username)")
        print("   Email: \(email)")
        print("   Password: [HIDDEN]")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.register)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.register,
                body: registerRequest,
                responseType: AuthResponse.self,
                requiresAuth: false
            )
            
            print("✅ [REGISTER] Respuesta recibida:")
            print("   User ID: \(response.user.id)")
            print("   Username: \(response.user.username)")
            print("   Email: \(response.user.email)")
            print("   Token: \(String(response.token.prefix(20)))...")
            print("   Expires: \(response.expiresAt)")
            
            // Save token and user ID to keychain
            let tokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.token)
            let userIDSaved = keychainHelper.save(key: Constants.Keychain.userID, value: response.user.id)
            
            guard tokenSaved && userIDSaved else {
                throw APIError.serverError(500, "Error al guardar credenciales")
            }
            
            // Update authentication state
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = response.user
            }
            
            print("✅ [REGISTER] Registro exitoso!")
            return response.user
            
        } catch {
            print("❌ [REGISTER] Error en registro:")
            print("   Error: \(error)")
            
            // Ensure we're not authenticated on registration failure
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
            throw error
        }
    }
    
    // MARK: - Logout
    func logout() {
        // Clear keychain
        keychainHelper.delete(key: Constants.Keychain.jwtToken)
        keychainHelper.delete(key: Constants.Keychain.userID)
        
        // Update authentication state
        isAuthenticated = false
        currentUser = nil
        
        // Clear any cached data
        clearUserData()
    }
    
    private func clearUserData() {
        // Clear UserDefaults if needed
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.lastSyncDate)
        
        // Clear any other cached data
        // This could include clearing Core Data, cached images, etc.
    }
    
    // MARK: - Token Management
    func getAuthToken() -> String? {
        return keychainHelper.get(key: Constants.Keychain.jwtToken)
    }
    
    func isTokenValid() -> Bool {
        guard let token = getAuthToken(), !token.isEmpty else {
            return false
        }
        
        // Basic token validation - in a real app you might want to decode JWT and check expiration
        // For now, we'll assume the token is valid if it exists
        return true
    }
    
    func refreshAuthenticationStatus() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Validation Helpers
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= Constants.Validation.minPasswordLength &&
               password.count <= Constants.Validation.maxPasswordLength
    }
    
    func validateUsername(_ username: String) -> Bool {
        return username.count >= Constants.Validation.minUsernameLength &&
               username.count <= Constants.Validation.maxUsernameLength &&
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Error Handling
    func handleAuthError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        return "Error de autenticación: \(error.localizedDescription)"
    }
}