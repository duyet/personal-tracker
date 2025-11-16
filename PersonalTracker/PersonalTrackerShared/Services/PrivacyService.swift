import Foundation
import Combine

#if canImport(CoreLocation)
import CoreLocation
#endif

#if canImport(EventKit)
import EventKit
#endif

#if canImport(Photos)
import Photos
#endif

// MARK: - PrivacyService

/// Centralized service for managing privacy permissions and settings
@available(iOS 14.0, macOS 11.0, *)
final class PrivacyService: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var permissions: PermissionStatus = PermissionStatus()
    @Published private(set) var privacySettings: PrivacySettings = PrivacySettings()

    // MARK: - Public Methods

    /// Check all permission statuses
    func checkAllPermissions() {
        #if canImport(CoreLocation)
        permissions.location = getLocationPermissionStatus()
        #endif

        #if canImport(EventKit)
        permissions.calendar = getCalendarPermissionStatus()
        #endif

        #if canImport(Photos)
        permissions.photos = getPhotosPermissionStatus()
        #endif
    }

    /// Request location permission
    func requestLocationPermission() {
        #if canImport(CoreLocation)
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        #endif
    }

    /// Request calendar permission
    func requestCalendarPermission() async throws {
        #if canImport(EventKit)
        let store = EKEventStore()
        if #available(iOS 17.0, macOS 14.0, *) {
            _ = try await store.requestFullAccessToEvents()
        } else {
            _ = try await store.requestAccess(to: .event)
        }
        checkAllPermissions()
        #endif
    }

    /// Request photos permission
    func requestPhotosPermission() async {
        #if canImport(Photos)
        if #available(iOS 14, *) {
            _ = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        } else {
            PHPhotoLibrary.requestAuthorization { _ in }
        }
        checkAllPermissions()
        #endif
    }

    /// Update privacy settings
    func updateSettings(_ settings: PrivacySettings) {
        privacySettings = settings
        saveSettings()
    }

    /// Get privacy recommendation
    func getPrivacyRecommendation() -> PrivacyRecommendation {
        var issues: [PrivacyIssue] = []
        var score = 100.0

        // Check if too many permissions are granted
        if permissions.location == .authorized {
            issues.append(.locationAlwaysOn)
            score -= 10
        }

        if !privacySettings.requireAuthentication {
            issues.append(.noAuthenticationRequired)
            score -= 20
        }

        if !privacySettings.encryptSensitiveData {
            issues.append(.sensitiveDataNotEncrypted)
            score -= 30
        }

        if privacySettings.cloudSyncEnabled && !privacySettings.encryptSensitiveData {
            issues.append(.cloudSyncWithoutEncryption)
            score -= 20
        }

        return PrivacyRecommendation(
            score: max(0, score),
            issues: issues,
            level: PrivacyLevel.from(score: score)
        )
    }

    // MARK: - Private Methods

    #if canImport(CoreLocation)
    private func getLocationPermissionStatus() -> PermissionState {
        let status = CLLocationManager().authorizationStatus
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorizedAlways, .authorizedWhenInUse: return .authorized
        @unknown default: return .notDetermined
        }
    }
    #endif

    #if canImport(EventKit)
    private func getCalendarPermissionStatus() -> PermissionState {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, macOS 14.0, *) {
            switch status {
            case .notDetermined: return .notDetermined
            case .restricted: return .restricted
            case .denied: return .denied
            case .fullAccess, .writeOnly: return .authorized
            @unknown default: return .notDetermined
            }
        } else {
            switch status {
            case .notDetermined: return .notDetermined
            case .restricted: return .restricted
            case .denied: return .denied
            case .authorized: return .authorized
            @unknown default: return .notDetermined
            }
        }
    }
    #endif

    #if canImport(Photos)
    private func getPhotosPermissionStatus() -> PermissionState {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }

        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        case .limited: return .limited
        @unknown default: return .notDetermined
        }
    }
    #endif

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(privacySettings) {
            UserDefaults.standard.set(encoded, forKey: "PrivacySettings")
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "PrivacySettings"),
           let settings = try? JSONDecoder().decode(PrivacySettings.self, from: data) {
            privacySettings = settings
        }
    }
}

// MARK: - PermissionStatus

struct PermissionStatus {
    var location: PermissionState = .notDetermined
    var calendar: PermissionState = .notDetermined
    var photos: PermissionState = .notDetermined
    var contacts: PermissionState = .notDetermined

    var allGranted: Bool {
        location == .authorized &&
        calendar == .authorized &&
        photos == .authorized
    }

    var anyDenied: Bool {
        location == .denied ||
        calendar == .denied ||
        photos == .denied
    }
}

// MARK: - PermissionState

enum PermissionState {
    case notDetermined
    case restricted
    case denied
    case authorized
    case limited

    var displayName: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .limited: return "Limited"
        }
    }

    var isGranted: Bool {
        self == .authorized || self == .limited
    }
}

// MARK: - PrivacySettings

struct PrivacySettings: Codable {
    var trackLocation: Bool = false
    var trackCalendar: Bool = false
    var trackMedia: Bool = false
    var trackURLs: Bool = false
    var trackCalls: Bool = false
    var trackDevice: Bool = false

    var requireAuthentication: Bool = true
    var encryptSensitiveData: Bool = true
    var cloudSyncEnabled: Bool = false
    var autoDeleteAfterDays: Int?

    var dataRetentionDays: Int = 365
    var allowAnalytics: Bool = false
}

// MARK: - PrivacyRecommendation

struct PrivacyRecommendation {
    let score: Double
    let issues: [PrivacyIssue]
    let level: PrivacyProtectionLevel

    var scoreFormatted: String {
        String(format: "%.0f", score)
    }

    var summary: String {
        if score >= 80 {
            return "Your privacy settings are excellent!"
        } else if score >= 60 {
            return "Your privacy settings are good, but can be improved."
        } else {
            return "Consider reviewing your privacy settings."
        }
    }
}

// MARK: - PrivacyIssue

enum PrivacyIssue {
    case locationAlwaysOn
    case noAuthenticationRequired
    case sensitiveDataNotEncrypted
    case cloudSyncWithoutEncryption
    case dataRetentionTooLong

    var title: String {
        switch self {
        case .locationAlwaysOn:
            return "Location Always On"
        case .noAuthenticationRequired:
            return "No Authentication Required"
        case .sensitiveDataNotEncrypted:
            return "Sensitive Data Not Encrypted"
        case .cloudSyncWithoutEncryption:
            return "Cloud Sync Without Encryption"
        case .dataRetentionTooLong:
            return "Data Retained Too Long"
        }
    }

    var description: String {
        switch self {
        case .locationAlwaysOn:
            return "Consider using 'While Using' instead of 'Always' for location access."
        case .noAuthenticationRequired:
            return "Enable authentication to protect your personal data."
        case .sensitiveDataNotEncrypted:
            return "Encrypt sensitive data for better security."
        case .cloudSyncWithoutEncryption:
            return "Enable encryption before using cloud sync."
        case .dataRetentionTooLong:
            return "Consider reducing data retention period."
        }
    }

    var severity: String {
        switch self {
        case .noAuthenticationRequired, .sensitiveDataNotEncrypted:
            return "high"
        case .cloudSyncWithoutEncryption:
            return "medium"
        case .locationAlwaysOn, .dataRetentionTooLong:
            return "low"
        }
    }
}

// MARK: - PrivacyProtectionLevel Extension

extension PrivacyProtectionLevel {
    static func from(score: Double) -> PrivacyProtectionLevel {
        if score >= 80 {
            return .high
        } else if score >= 60 {
            return .medium
        } else {
            return .low
        }
    }
}
