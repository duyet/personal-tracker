import Foundation

// MARK: - CallActivity

/// Represents a phone call activity (iOS only)
struct CallActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .call
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // Call-specific properties
    let callType: CallType
    let direction: CallDirection
    let phoneNumber: String?
    let contactName: String?
    let duration: TimeInterval
    let wasAnswered: Bool
    let wasBlocked: Bool
    let carrierName: String?
    let callIdentifier: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        callType: CallType,
        direction: CallDirection,
        phoneNumber: String? = nil,
        contactName: String? = nil,
        duration: TimeInterval,
        wasAnswered: Bool = true,
        wasBlocked: Bool = false,
        carrierName: String? = nil,
        callIdentifier: String? = nil,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.callType = callType
        self.direction = direction
        self.phoneNumber = phoneNumber
        self.contactName = contactName
        self.duration = duration
        self.wasAnswered = wasAnswered
        self.wasBlocked = wasBlocked
        self.carrierName = carrierName
        self.callIdentifier = callIdentifier
        self.title = title ?? contactName ?? phoneNumber
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Display name for the call (contact name or phone number)
    var displayName: String {
        contactName ?? phoneNumber ?? "Unknown"
    }

    /// Formatted phone number
    var formattedPhoneNumber: String? {
        guard let phoneNumber = phoneNumber else { return nil }

        // Simple formatting for US numbers
        let cleaned = phoneNumber.filter { $0.isNumber }
        if cleaned.count == 10 {
            let areaCode = cleaned.prefix(3)
            let prefix = cleaned.dropFirst(3).prefix(3)
            let suffix = cleaned.dropFirst(6)
            return "(\(areaCode)) \(prefix)-\(suffix)"
        } else if cleaned.count == 11 && cleaned.first == "1" {
            let areaCode = cleaned.dropFirst().prefix(3)
            let prefix = cleaned.dropFirst(4).prefix(3)
            let suffix = cleaned.dropFirst(7)
            return "+1 (\(areaCode)) \(prefix)-\(suffix)"
        }

        return phoneNumber
    }

    /// Formatted duration string
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return "\(seconds)s"
        }
    }

    /// Check if call was missed
    var wasMissed: Bool {
        direction == .incoming && !wasAnswered
    }

    /// Check if call was voicemail
    var wasVoicemail: Bool {
        callType == .voicemail
    }

    /// Check if call lasted less than 10 seconds
    var wasShortCall: Bool {
        duration < 10
    }

    /// Check if call was long (more than 10 minutes)
    var wasLongCall: Bool {
        duration > 600
    }
}

// MARK: - CallType

/// Type of call
enum CallType: String, Codable, CaseIterable {
    case voice
    case video
    case voicemail
    case facetime
    case voip

    var displayName: String {
        switch self {
        case .voice: return "Voice Call"
        case .video: return "Video Call"
        case .voicemail: return "Voicemail"
        case .facetime: return "FaceTime"
        case .voip: return "VoIP Call"
        }
    }

    var icon: String {
        switch self {
        case .voice: return "phone.fill"
        case .video: return "video.fill"
        case .voicemail: return "voicemail.fill"
        case .facetime: return "video.fill"
        case .voip: return "phone.connection.fill"
        }
    }
}

// MARK: - CallDirection

/// Direction of the call
enum CallDirection: String, Codable {
    case incoming
    case outgoing

    var displayName: String {
        switch self {
        case .incoming: return "Incoming"
        case .outgoing: return "Outgoing"
        }
    }

    var icon: String {
        switch self {
        case .incoming: return "arrow.down.left"
        case .outgoing: return "arrow.up.right"
        }
    }
}

// MARK: - CallStatistics

/// Statistics for call activities
struct CallStatistics {
    let totalCalls: Int
    let incomingCalls: Int
    let outgoingCalls: Int
    let missedCalls: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let longestCall: CallActivity?
    let mostFrequentContact: String?

    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var missedCallRate: Double {
        guard totalCalls > 0 else { return 0 }
        return Double(missedCalls) / Double(totalCalls)
    }

    static func calculate(from calls: [CallActivity]) -> CallStatistics {
        let totalCalls = calls.count
        let incomingCalls = calls.filter { $0.direction == .incoming }.count
        let outgoingCalls = calls.filter { $0.direction == .outgoing }.count
        let missedCalls = calls.filter { $0.wasMissed }.count
        let totalDuration = calls.reduce(0) { $0 + $1.duration }
        let averageDuration = totalCalls > 0 ? totalDuration / Double(totalCalls) : 0
        let longestCall = calls.max { $0.duration < $1.duration }

        // Find most frequent contact
        let contactCounts = Dictionary(
            grouping: calls.compactMap { $0.contactName },
            by: { $0 }
        ).mapValues { $0.count }

        let mostFrequentContact = contactCounts.max { $0.value < $1.value }?.key

        return CallStatistics(
            totalCalls: totalCalls,
            incomingCalls: incomingCalls,
            outgoingCalls: outgoingCalls,
            missedCalls: missedCalls,
            totalDuration: totalDuration,
            averageDuration: averageDuration,
            longestCall: longestCall,
            mostFrequentContact: mostFrequentContact
        )
    }
}
