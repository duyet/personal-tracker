import Foundation
import EventKit

// MARK: - CalendarActivity

/// Represents a calendar event or reminder from the user's calendar
struct CalendarActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .calendar
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // Calendar-specific properties
    let eventIdentifier: String?
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let calendar: String
    let attendees: [String]
    let organizer: String?
    let url: URL?
    let eventType: CalendarEventType
    let status: EventStatus
    let recurrenceRule: String?

    private enum CodingKeys: String, CodingKey {
        case id, timestamp, title, notes, tags, isFavorite, privacyLevel, metadata
        case eventIdentifier, startDate, endDate, isAllDay, location, calendar
        case attendees, organizer, url, eventType, status, recurrenceRule
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        eventIdentifier: String? = nil,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        location: String? = nil,
        calendar: String,
        attendees: [String] = [],
        organizer: String? = nil,
        url: URL? = nil,
        eventType: CalendarEventType = .event,
        status: EventStatus = .confirmed,
        recurrenceRule: String? = nil,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.eventIdentifier = eventIdentifier
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.calendar = calendar
        self.attendees = attendees
        self.organizer = organizer
        self.url = url
        self.eventType = eventType
        self.status = status
        self.recurrenceRule = recurrenceRule
        self.title = title
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Duration of the event in seconds
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    /// Formatted duration string
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    /// Check if event is currently happening
    var isHappeningNow: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    /// Check if event is in the future
    var isFuture: Bool {
        startDate > Date()
    }

    /// Check if event is in the past
    var isPast: Bool {
        endDate < Date()
    }

    /// Check if event has attendees
    var hasAttendees: Bool {
        !attendees.isEmpty
    }

    /// Check if event is recurring
    var isRecurring: Bool {
        recurrenceRule != nil
    }
}

// MARK: - CalendarEventType

/// Type of calendar event
enum CalendarEventType: String, Codable, CaseIterable {
    case event
    case reminder
    case birthday
    case meeting
    case appointment
    case task

    var displayName: String {
        switch self {
        case .event: return "Event"
        case .reminder: return "Reminder"
        case .birthday: return "Birthday"
        case .meeting: return "Meeting"
        case .appointment: return "Appointment"
        case .task: return "Task"
        }
    }

    var icon: String {
        switch self {
        case .event: return "calendar"
        case .reminder: return "bell.fill"
        case .birthday: return "gift.fill"
        case .meeting: return "person.3.fill"
        case .appointment: return "checkmark.circle.fill"
        case .task: return "checklist"
        }
    }
}

// MARK: - EventStatus

/// Status of a calendar event
enum EventStatus: String, Codable {
    case confirmed
    case tentative
    case cancelled

    var displayName: String {
        switch self {
        case .confirmed: return "Confirmed"
        case .tentative: return "Tentative"
        case .cancelled: return "Cancelled"
        }
    }
}

// MARK: - CalendarActivity Extension

extension CalendarActivity {
    /// Initialize from EKEvent
    init(from event: EKEvent) {
        self.id = UUID()
        self.timestamp = event.creationDate ?? Date()
        self.eventIdentifier = event.eventIdentifier
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.isAllDay = event.isAllDay
        self.location = event.location
        self.calendar = event.calendar.title
        self.attendees = event.attendees?.compactMap { $0.name } ?? []
        self.organizer = event.organizer?.name
        self.url = event.url
        self.eventType = .event
        self.status = event.status == .confirmed ? .confirmed :
                      event.status == .tentative ? .tentative : .cancelled
        self.recurrenceRule = event.recurrenceRules?.first?.description
        self.title = event.title
        self.notes = event.notes
        self.tags = []
        self.isFavorite = false
        self.privacyLevel = .privateLevel
        self.metadata = [:]
    }
}
