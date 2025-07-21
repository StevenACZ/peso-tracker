//
//  AchievementStorageService.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation

// MARK: - Achievement Storage Service

class AchievementStorageService {
    
    static let shared = AchievementStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // Storage keys
    private let achievementsKey = "peso_tracker_achievements"
    private let backupKey = "peso_tracker_achievements_backup"
    private let metadataKey = "peso_tracker_achievements_metadata"
    private let migrationVersionKey = "achievements_migration_version"
    
    // File-based storage paths
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var achievementsFileURL: URL {
        return documentsDirectory.appendingPathComponent("achievements.json")
    }
    
    private var backupFileURL: URL {
        return documentsDirectory.appendingPathComponent("achievements_backup.json")
    }
    
    private init() {
        performMigrationIfNeeded()
    }
    
    // MARK: - Main Storage Methods
    
    func saveUserAchievements(_ achievements: UserAchievements) -> Bool {
        let metadata = AchievementMetadata(
            lastUpdated: Date(),
            version: getCurrentVersion(),
            totalPoints: achievements.totalPoints,
            unlockedCount: achievements.unlockedCount
        )
        
        // Save to UserDefaults (primary)
        let userDefaultsSuccess = saveToUserDefaults(achievements, metadata: metadata)
        
        // Save to file system (backup)
        let fileSuccess = saveToFile(achievements, metadata: metadata)
        
        if userDefaultsSuccess || fileSuccess {
            print("💾 AchievementStorageService: Achievements saved successfully")
            return true
        } else {
            print("❌ AchievementStorageService: Failed to save achievements")
            return false
        }
    }
    
    func loadUserAchievements() -> UserAchievements? {
        // Try loading from UserDefaults first
        if let achievements = loadFromUserDefaults() {
            return achievements
        }
        
        // Fallback to file system
        if let achievements = loadFromFile() {
            // Restore to UserDefaults
            _ = saveToUserDefaults(achievements, metadata: nil)
            return achievements
        }
        
        print("📂 AchievementStorageService: No achievements found")
        return nil
    }
    
    // MARK: - UserDefaults Storage
    
    private func saveToUserDefaults(_ achievements: UserAchievements, metadata: AchievementMetadata?) -> Bool {
        do {
            let achievementsData = try JSONEncoder().encode(achievements)
            userDefaults.set(achievementsData, forKey: achievementsKey)
            
            if let metadata = metadata {
                let metadataData = try JSONEncoder().encode(metadata)
                userDefaults.set(metadataData, forKey: metadataKey)
            }
            
            // Create backup in UserDefaults
            userDefaults.set(achievementsData, forKey: backupKey)
            
            return true
        } catch {
            print("❌ AchievementStorageService: UserDefaults save failed: \(error)")
            return false
        }
    }
    
    private func loadFromUserDefaults() -> UserAchievements? {
        guard let data = userDefaults.data(forKey: achievementsKey) else {
            return nil
        }
        
        do {
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            print("📂 AchievementStorageService: Loaded from UserDefaults")
            return achievements
        } catch {
            print("❌ AchievementStorageService: UserDefaults load failed: \(error)")
            
            // Try backup
            return loadBackupFromUserDefaults()
        }
    }
    
    private func loadBackupFromUserDefaults() -> UserAchievements? {
        guard let data = userDefaults.data(forKey: backupKey) else {
            return nil
        }
        
        do {
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            print("📂 AchievementStorageService: Restored from UserDefaults backup")
            
            // Restore main data
            userDefaults.set(data, forKey: achievementsKey)
            
            return achievements
        } catch {
            print("❌ AchievementStorageService: UserDefaults backup load failed: \(error)")
            return nil
        }
    }
    
    // MARK: - File System Storage
    
    private func saveToFile(_ achievements: UserAchievements, metadata: AchievementMetadata?) -> Bool {
        do {
            let data = try JSONEncoder().encode(achievements)
            try data.write(to: achievementsFileURL)
            
            // Create backup file
            try data.write(to: backupFileURL)
            
            // Save metadata if provided
            if let metadata = metadata {
                let metadataURL = documentsDirectory.appendingPathComponent("achievements_metadata.json")
                let metadataData = try JSONEncoder().encode(metadata)
                try metadataData.write(to: metadataURL)
            }
            
            return true
        } catch {
            print("❌ AchievementStorageService: File save failed: \(error)")
            return false
        }
    }
    
    private func loadFromFile() -> UserAchievements? {
        guard fileManager.fileExists(atPath: achievementsFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: achievementsFileURL)
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            print("📂 AchievementStorageService: Loaded from file")
            return achievements
        } catch {
            print("❌ AchievementStorageService: File load failed: \(error)")
            
            // Try backup file
            return loadBackupFromFile()
        }
    }
    
    private func loadBackupFromFile() -> UserAchievements? {
        guard fileManager.fileExists(atPath: backupFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: backupFileURL)
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            print("📂 AchievementStorageService: Restored from file backup")
            
            // Restore main file
            try data.write(to: achievementsFileURL)
            
            return achievements
        } catch {
            print("❌ AchievementStorageService: File backup load failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Metadata Management
    
    func getMetadata() -> AchievementMetadata? {
        guard let data = userDefaults.data(forKey: metadataKey) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(AchievementMetadata.self, from: data)
        } catch {
            print("❌ AchievementStorageService: Metadata load failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Data Management
    
    func clearAllAchievements() {
        // Clear UserDefaults
        userDefaults.removeObject(forKey: achievementsKey)
        userDefaults.removeObject(forKey: backupKey)
        userDefaults.removeObject(forKey: metadataKey)
        
        // Clear files
        try? fileManager.removeItem(at: achievementsFileURL)
        try? fileManager.removeItem(at: backupFileURL)
        
        let metadataURL = documentsDirectory.appendingPathComponent("achievements_metadata.json")
        try? fileManager.removeItem(at: metadataURL)
        
        print("🗑️ AchievementStorageService: All data cleared")
    }
    
    func exportAchievements() -> Data? {
        // Try UserDefaults first
        if let data = userDefaults.data(forKey: achievementsKey) {
            return data
        }
        
        // Try file system
        if fileManager.fileExists(atPath: achievementsFileURL.path) {
            return try? Data(contentsOf: achievementsFileURL)
        }
        
        return nil
    }
    
    func importAchievements(from data: Data) -> Bool {
        do {
            // Validate data
            let achievements = try JSONDecoder().decode(UserAchievements.self, from: data)
            
            // Save using normal save method
            return saveUserAchievements(achievements)
        } catch {
            print("❌ AchievementStorageService: Import failed: \(error)")
            return false
        }
    }
    
    // MARK: - Storage Statistics
    
    func getStorageInfo() -> StorageInfo {
        let userDefaultsSize = userDefaults.data(forKey: achievementsKey)?.count ?? 0
        let fileSize = (try? achievementsFileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
        let backupSize = (try? backupFileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
        
        let lastModified = getMetadata()?.lastUpdated ?? Date.distantPast
        
        return StorageInfo(
            userDefaultsSize: userDefaultsSize,
            fileSize: fileSize,
            backupSize: backupSize,
            lastModified: lastModified,
            hasUserDefaultsData: userDefaults.data(forKey: achievementsKey) != nil,
            hasFileData: fileManager.fileExists(atPath: achievementsFileURL.path),
            hasBackupData: fileManager.fileExists(atPath: backupFileURL.path)
        )
    }
    
    // MARK: - Migration
    
    private func performMigrationIfNeeded() {
        let currentVersion = getCurrentVersion()
        let savedVersion = userDefaults.integer(forKey: migrationVersionKey)
        
        if savedVersion < currentVersion {
            print("🔄 AchievementStorageService: Performing migration from v\(savedVersion) to v\(currentVersion)")
            
            // Perform migration steps
            migrateTo(version: currentVersion)
            
            // Update version
            userDefaults.set(currentVersion, forKey: migrationVersionKey)
            
            print("✅ AchievementStorageService: Migration completed")
        }
    }
    
    private func migrateTo(version: Int) {
        switch version {
        case 1:
            // Initial version - no migration needed
            break
        case 2:
            // Future migration logic
            break
        default:
            break
        }
    }
    
    private func getCurrentVersion() -> Int {
        return 1 // Current version
    }
}

// MARK: - Supporting Data Structures

struct AchievementMetadata: Codable {
    let lastUpdated: Date
    let version: Int
    let totalPoints: Int
    let unlockedCount: Int
    
    var formattedLastUpdated: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdated)
    }
}

struct StorageInfo {
    let userDefaultsSize: Int
    let fileSize: Int
    let backupSize: Int
    let lastModified: Date
    let hasUserDefaultsData: Bool
    let hasFileData: Bool
    let hasBackupData: Bool
    
    var totalSize: Int {
        return userDefaultsSize + fileSize + backupSize
    }
    
    var formattedTotalSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }
    
    var isHealthy: Bool {
        return hasUserDefaultsData || hasFileData
    }
    
    var hasBackup: Bool {
        return hasBackupData || UserDefaults.standard.data(forKey: "peso_tracker_achievements_backup") != nil
    }
}

// MARK: - Storage Extensions

extension AchievementStorageService {
    
    /// Create a full backup of all achievement data
    func createFullBackup() -> AchievementBackup? {
        guard let achievements = loadUserAchievements() else {
            return nil
        }
        
        let metadata = getMetadata() ?? AchievementMetadata(
            lastUpdated: Date(),
            version: getCurrentVersion(),
            totalPoints: achievements.totalPoints,
            unlockedCount: achievements.unlockedCount
        )
        
        return AchievementBackup(
            achievements: achievements,
            metadata: metadata,
            createdAt: Date()
        )
    }
    
    /// Restore from a full backup
    func restoreFromBackup(_ backup: AchievementBackup) -> Bool {
        return saveUserAchievements(backup.achievements)
    }
}

struct AchievementBackup: Codable {
    let achievements: UserAchievements
    let metadata: AchievementMetadata
    let createdAt: Date
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter.string(from: createdAt)
    }
}