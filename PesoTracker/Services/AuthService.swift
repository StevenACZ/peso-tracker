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
            print("🔐 [AUTH SERVICE] Token found in keychain - validating with server...")
            
            // Validate token with server
            Task {
                let isValid = await validateTokenWithServer()
                await MainActor.run {
                    if isValid {
                        print("🔐 [AUTH SERVICE] Token validation successful")
                        self.isAuthenticated = true
                        // Load user data if available
                        self.loadCurrentUser()
                    } else {
                        print("🔐 [AUTH SERVICE] Token validation failed - performing auto-logout")
                        self.performAutoLogout()
                    }
                }
            }
        } else {
            print("🔐 [AUTH SERVICE] No valid token found")
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    private func loadCurrentUser() {
        if let userID = keychainHelper.get(key: Constants.Keychain.userID) {
            // Try to load user data from UserDefaults
            currentUser = loadUserDataLocally()
            print("🔐 [AUTH SERVICE] Loaded cached user data for ID: \(userID)")
        }
    }
    
    // MARK: - Token Validation
    private func validateTokenWithServer() async -> Bool {
        do {
            // Make a lightweight API call to validate the token
            // Use a simple endpoint that requires auth but returns minimal data
            let _ = try await apiService.get(
                endpoint: "/weights/paginated?page=1&limit=1",
                responseType: PaginatedResponse<Weight>.self,
                requiresAuth: true
            )
            return true
        } catch {
            print("🔐 [AUTH SERVICE] Token validation failed: \(error)")
            return false
        }
    }
    
    // MARK: - Auto Logout
    private func performAutoLogout() {
        print("🔐 [AUTH SERVICE] Performing automatic logout due to invalid token")
        
        // Clear keychain
        keychainHelper.delete(key: Constants.Keychain.jwtToken)
        keychainHelper.delete(key: Constants.Keychain.userID)
        
        // Update authentication state
        isAuthenticated = false
        currentUser = nil
        
        // Clear any cached data
        clearUserData()
        
        // Clear cache service
        CacheService.shared.clearCache()
        
        print("🔐 [AUTH SERVICE] Auto-logout completed - redirecting to login")
    }
    
    // MARK: - Public Auto Logout (for external services)
    @MainActor
    func forceLogoutDueToExpiredToken() {
        print("🔐 [AUTH SERVICE] Force logout triggered by expired token from API")
        performAutoLogout()
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
            print("   📧 Email: \(response.user.email)")
            print("   👤 Nombre: \(response.user.username)")
            print("   🔑 Token: \(response.token)")
            print("   User ID: \(response.user.id)")
            print("   Expires: \(response.expiresAt)")
            
            // Save token and user ID to keychain
            let tokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.token)
            let userIDSaved = keychainHelper.save(key: Constants.Keychain.userID, value: response.user.id)
            
            guard tokenSaved && userIDSaved else {
                throw APIError.serverError(500, "Error al guardar credenciales")
            }
            
            // Save user data locally in UserDefaults
            saveUserDataLocally(user: response.user)
            
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
            print("   📧 Email: \(response.user.email)")
            print("   👤 Nombre: \(response.user.username)")
            print("   🔑 Token: \(response.token)")
            print("   User ID: \(response.user.id)")
            print("   Expires: \(response.expiresAt)")
            
            // Save token and user ID to keychain
            let tokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.token)
            let userIDSaved = keychainHelper.save(key: Constants.Keychain.userID, value: response.user.id)
            
            guard tokenSaved && userIDSaved else {
                throw APIError.serverError(500, "Error al guardar credenciales")
            }
            
            // Save user data locally in UserDefaults
            saveUserDataLocally(user: response.user)
            
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
        
        // Clear cached user data
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUserData)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUsername)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUserEmail)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUserId)
        
        // Clear any other cached data
        // This could include clearing Core Data, cached images, etc.
    }
    
    // MARK: - Local User Data Management
    private func saveUserDataLocally(user: User) {
        print("💾 [AUTH SERVICE] Saving user data locally")
        
        // Save individual fields
        UserDefaults.standard.set(user.id, forKey: Constants.UserDefaults.cachedUserId)
        UserDefaults.standard.set(user.username, forKey: Constants.UserDefaults.cachedUsername)
        UserDefaults.standard.set(user.email, forKey: Constants.UserDefaults.cachedUserEmail)
        
        // Save complete user object as JSON
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            UserDefaults.standard.set(userData, forKey: Constants.UserDefaults.cachedUserData)
            print("✅ [AUTH SERVICE] User data saved successfully")
        } catch {
            print("❌ [AUTH SERVICE] Error saving user data: \(error)")
        }
    }
    
    private func loadUserDataLocally() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: Constants.UserDefaults.cachedUserData) else {
            print("⚠️ [AUTH SERVICE] No cached user data found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constants.DateFormats.api
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let user = try decoder.decode(User.self, from: userData)
            print("✅ [AUTH SERVICE] Cached user data loaded successfully")
            return user
        } catch {
            print("❌ [AUTH SERVICE] Error loading cached user data: \(error)")
            return nil
        }
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