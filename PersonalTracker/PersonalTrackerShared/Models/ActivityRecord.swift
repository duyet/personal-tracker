import Foundation

// MARK: - ActivityRecord Protocol

/// Base protocol for all tracked activities in the Personal Tracker app.
/// Provides common properties and functionality that all activity types must implement.
protocol ActivityRecord: Identifiable, Codable, Hashable {
    /// Unique identifier for the activity
    var id: UUID { get }

    /// Timestamp when the activity occurred
    var timestamp: Date { get }

    /// Type of activity (location, calendar, media, etc.)
    var activityType: ActivityType { get }

    /// Optional title or description of the activity
    var title: String? { get }

    /// Optional detailed notes about the activity
    var notes: String? { get }

    /// Tags associated with this activity for categorization
    var tags: [String] { get set }

    /// Whether this activity is marked as favorite
    var isFavorite: Bool { get set }

    /// Privacy level for this activity
    var privacyLevel: PrivacyLevel { get set }

    /// Metadata dictionary for extensibility
    var metadata: [String: String] { get set }
}

// MARK: - ActivityType

/// Enumeration of all supported activity types
enum ActivityType: String, Codable, CaseIterable {
    case location = "location"
    case calendar = "calendar"
    case media = "media"
    case url = "url"
    case call = "call"
    case device = "device"
    case adTracking = "ad_tracking"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .location: return "Location"
        case .calendar: return "Calendar"
        case .media: return "Media"
        case .url: return "URL"
        case .call: return "Call"
        case .device: return "Device"
        case .adTracking: return "Ad Tracking"
        case .custom: return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .location: return "location.fill"
        case .calendar: return "calendar"
        case .media: return "photo.fill"
        case .url: return "safari.fill"
        case .call: return "phone.fill"
        case .device: return "iphone"
        case .adTracking: return "rectangle.stack.badge.person.crop"
        case .custom: return "star.fill"
        }
    }
}

// MARK: - PrivacyLevel

/// Privacy level classification for activities
enum PrivacyLevel: String, Codable, CaseIterable {
    case publicLevel = "public"
    case privateLevel = "private"
    case sensitive = "sensitive"
    case restricted = "restricted"

    var displayName: String {
        switch self {
        case .publicLevel: return "Public"
        case .privateLevel: return "Private"
        case .sensitive: return "Sensitive"
        case .restricted: return "Restricted"
        }
    }

    var description: String {
        switch self {
        case .publicLevel:
            return "Can be freely shared and exported"
        case .privateLevel:
            return "Personal data, limited sharing"
        case .sensitive:
            return "Sensitive information, encrypted storage"
        case .restricted:
            return "Highly confidential, maximum protection"
        }
    }
}

// MARK: - BaseActivity

/// Base implementation providing common functionality for all activity types
struct BaseActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        activityType: ActivityType,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.activityType = activityType
        self.title = title
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }
}

// MARK: - ActivityRecord Extensions

extension ActivityRecord {
    /// Returns a formatted date string for display
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Returns a relative time string (e.g., "2 hours ago")
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    /// Checks if this activity occurred today
    var isToday: Bool {
        Calendar.current.isDateInToday(timestamp)
    }

    /// Checks if this activity occurred in the last week
    var isThisWeek: Bool {
        guard let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return timestamp >= weekAgo
    }
}
