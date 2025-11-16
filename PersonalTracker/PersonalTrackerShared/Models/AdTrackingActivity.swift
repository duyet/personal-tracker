import Foundation

#if canImport(AdSupport)
import AdSupport
#endif

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

// MARK: - AdTrackingActivity

/// Represents ad tracking and transparency information
struct AdTrackingActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .adTracking
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // Ad tracking-specific properties
    let trackingStatus: TrackingStatus
    let advertisingIdentifier: String?
    let isLimitAdTrackingEnabled: Bool
    let trackingDomains: [String]
    let blockedTrackers: Int
    let allowedTrackers: Int

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        trackingStatus: TrackingStatus,
        advertisingIdentifier: String? = nil,
        isLimitAdTrackingEnabled: Bool = true,
        trackingDomains: [String] = [],
        blockedTrackers: Int = 0,
        allowedTrackers: Int = 0,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .sensitive,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.trackingStatus = trackingStatus
        self.advertisingIdentifier = advertisingIdentifier
        self.isLimitAdTrackingEnabled = isLimitAdTrackingEnabled
        self.trackingDomains = trackingDomains
        self.blockedTrackers = blockedTrackers
        self.allowedTrackers = allowedTrackers
        self.title = title ?? "Ad Tracking Status"
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Total number of trackers detected
    var totalTrackers: Int {
        blockedTrackers + allowedTrackers
    }

    /// Percentage of blocked trackers
    var blockedPercentage: Double {
        guard totalTrackers > 0 else { return 0 }
        return Double(blockedTrackers) / Double(totalTrackers)
    }

    /// Formatted blocked percentage
    var formattedBlockedPercentage: String {
        String(format: "%.1f%%", blockedPercentage * 100)
    }

    /// Check if tracking is authorized
    var isTrackingAuthorized: Bool {
        trackingStatus == .authorized
    }

    /// Check if tracking is restricted
    var isTrackingRestricted: Bool {
        trackingStatus == .restricted
    }

    /// Privacy protection level
    var privacyProtectionLevel: PrivacyProtectionLevel {
        if !isTrackingAuthorized && blockedTrackers > allowedTrackers {
            return .high
        } else if !isTrackingAuthorized || blockedTrackers >= allowedTrackers {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - TrackingStatus

/// App Tracking Transparency status
enum TrackingStatus: String, Codable {
    case notDetermined
    case restricted
    case denied
    case authorized

    var displayName: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        }
    }

    var description: String {
        switch self {
        case .notDetermined:
            return "User has not yet been asked for tracking permission"
        case .restricted:
            return "Tracking authorization restricted by parental controls or device management"
        case .denied:
            return "User has explicitly denied tracking authorization"
        case .authorized:
            return "User has authorized tracking for this app"
        }
    }

    var icon: String {
        switch self {
        case .notDetermined: return "questionmark.circle.fill"
        case .restricted: return "lock.fill"
        case .denied: return "hand.raised.fill"
        case .authorized: return "checkmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .notDetermined: return "gray"
        case .restricted: return "orange"
        case .denied: return "green"
        case .authorized: return "red"
        }
    }

    #if canImport(AppTrackingTransparency)
    /// Convert from ATTrackingManager.AuthorizationStatus
    @available(iOS 14.0, *)
    static func from(_ status: ATTrackingManager.AuthorizationStatus) -> TrackingStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .authorized
        @unknown default: return .notDetermined
        }
    }
    #endif
}

// MARK: - PrivacyProtectionLevel

/// Overall privacy protection level
enum PrivacyProtectionLevel: String, Codable {
    case high
    case medium
    case low

    var displayName: String {
        switch self {
        case .high: return "High Protection"
        case .medium: return "Medium Protection"
        case .low: return "Low Protection"
        }
    }

    var description: String {
        switch self {
        case .high:
            return "Excellent privacy settings. Most trackers are blocked."
        case .medium:
            return "Moderate privacy settings. Some trackers are blocked."
        case .low:
            return "Limited privacy protection. Consider reviewing settings."
        }
    }

    var icon: String {
        switch self {
        case .high: return "shield.fill"
        case .medium: return "shield.lefthalf.filled"
        case .low: return "shield.slash.fill"
        }
    }

    var color: String {
        switch self {
        case .high: return "green"
        case .medium: return "yellow"
        case .low: return "red"
        }
    }
}

// MARK: - TrackerDomain

/// Information about a tracking domain
struct TrackerDomain: Identifiable, Codable {
    let id: UUID
    let domain: String
    let category: TrackerCategory
    let isBlocked: Bool
    let detectionCount: Int
    let lastDetected: Date

    init(
        id: UUID = UUID(),
        domain: String,
        category: TrackerCategory = .advertising,
        isBlocked: Bool = false,
        detectionCount: Int = 1,
        lastDetected: Date = Date()
    ) {
        self.id = id
        self.domain = domain
        self.category = category
        self.isBlocked = isBlocked
        self.detectionCount = detectionCount
        self.lastDetected = lastDetected
    }
}

// MARK: - TrackerCategory

/// Categories of tracking domains
enum TrackerCategory: String, Codable, CaseIterable {
    case advertising
    case analytics
    case social
    case fingerprinting
    case cryptomining
    case other

    var displayName: String {
        switch self {
        case .advertising: return "Advertising"
        case .analytics: return "Analytics"
        case .social: return "Social Media"
        case .fingerprinting: return "Fingerprinting"
        case .cryptomining: return "Cryptomining"
        case .other: return "Other"
        }
    }

    var description: String {
        switch self {
        case .advertising:
            return "Tracks you to show targeted advertisements"
        case .analytics:
            return "Collects data about your browsing behavior"
        case .social:
            return "Social media tracking and sharing widgets"
        case .fingerprinting:
            return "Creates unique identifier based on device characteristics"
        case .cryptomining:
            return "Uses your device to mine cryptocurrency"
        case .other:
            return "Other tracking purposes"
        }
    }

    var icon: String {
        switch self {
        case .advertising: return "megaphone.fill"
        case .analytics: return "chart.bar.fill"
        case .social: return "person.3.fill"
        case .fingerprinting: return "hand.point.up.left.fill"
        case .cryptomining: return "bitcoinsign.circle.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

// MARK: - AdTrackingActivity Extension

extension AdTrackingActivity {
    /// Create a snapshot of current ad tracking status
    static func currentSnapshot() -> AdTrackingActivity {
        #if canImport(AppTrackingTransparency) && canImport(AdSupport)
        if #available(iOS 14, *) {
            let status = TrackingStatus.from(ATTrackingManager.trackingAuthorizationStatus)
            let adIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            let isLimited = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled

            return AdTrackingActivity(
                trackingStatus: status,
                advertisingIdentifier: status == .authorized ? adIdentifier : nil,
                isLimitAdTrackingEnabled: isLimited
            )
        }
        #endif

        return AdTrackingActivity(
            trackingStatus: .notDetermined,
            isLimitAdTrackingEnabled: true
        )
    }
}
