import Foundation

// MARK: - Localization

/// Type-safe localization helper
enum L10n {
    // MARK: - General
    
    enum App {
        static let name = NSLocalizedString("app.name", comment: "App name")
        static let tagline = NSLocalizedString("app.tagline", comment: "App tagline")
    }
    
    // MARK: - Dashboard
    
    enum Dashboard {
        static let title = NSLocalizedString("dashboard.title", comment: "Dashboard title")
        static let welcome = NSLocalizedString("dashboard.welcome", comment: "Welcome message")
        static let noActivities = NSLocalizedString("dashboard.no_activities", comment: "No activities message")
        static let loading = NSLocalizedString("dashboard.loading", comment: "Loading message")
    }
    
    // MARK: - Activity Types
    
    enum Activity {
        static let location = NSLocalizedString("activity.location", comment: "Location activity")
        static let calendar = NSLocalizedString("activity.calendar", comment: "Calendar activity")
        static let media = NSLocalizedString("activity.media", comment: "Media activity")
        static let url = NSLocalizedString("activity.url", comment: "URL activity")
        static let call = NSLocalizedString("activity.call", comment: "Call activity")
        static let device = NSLocalizedString("activity.device", comment: "Device activity")
        static let adTracking = NSLocalizedString("activity.ad_tracking", comment: "Ad tracking activity")
    }
    
    // MARK: - Privacy
    
    enum Privacy {
        static let title = NSLocalizedString("privacy.title", comment: "Privacy title")
        static let settings = NSLocalizedString("privacy.settings", comment: "Privacy settings")
        
        enum Level {
            static let publicLevel = NSLocalizedString("privacy.level.public", comment: "Public privacy level")
            static let privateLevel = NSLocalizedString("privacy.level.private", comment: "Private privacy level")
            static let sensitive = NSLocalizedString("privacy.level.sensitive", comment: "Sensitive privacy level")
        }
    }
    
    // MARK: - Permissions
    
    enum Permission {
        static let location = NSLocalizedString("permission.location", comment: "Location permission")
        static let locationDescription = NSLocalizedString("permission.location.description", comment: "Location permission description")
        static let calendar = NSLocalizedString("permission.calendar", comment: "Calendar permission")
        static let calendarDescription = NSLocalizedString("permission.calendar.description", comment: "Calendar permission description")
        static let photos = NSLocalizedString("permission.photos", comment: "Photos permission")
        static let photosDescription = NSLocalizedString("permission.photos.description", comment: "Photos permission description")
        static let contacts = NSLocalizedString("permission.contacts", comment: "Contacts permission")
        static let contactsDescription = NSLocalizedString("permission.contacts.description", comment: "Contacts permission description")
        static let required = NSLocalizedString("permission.required", comment: "Permission required")
        static let denied = NSLocalizedString("permission.denied", comment: "Permission denied")
        static let granted = NSLocalizedString("permission.granted", comment: "Permission granted")
    }
    
    // MARK: - Settings
    
    enum Settings {
        static let title = NSLocalizedString("settings.title", comment: "Settings title")
        static let general = NSLocalizedString("settings.general", comment: "General settings")
        static let tracking = NSLocalizedString("settings.tracking", comment: "Tracking settings")
        static let security = NSLocalizedString("settings.security", comment: "Security settings")
        static let data = NSLocalizedString("settings.data", comment: "Data management")
        static let about = NSLocalizedString("settings.about", comment: "About")
    }
    
    // MARK: - Tracking
    
    enum Tracking {
        static let location = NSLocalizedString("tracking.location", comment: "Track location")
        static let calendar = NSLocalizedString("tracking.calendar", comment: "Track calendar")
        static let media = NSLocalizedString("tracking.media", comment: "Track media")
        static let urls = NSLocalizedString("tracking.urls", comment: "Track URLs")
        static let calls = NSLocalizedString("tracking.calls", comment: "Track calls")
        static let device = NSLocalizedString("tracking.device", comment: "Track device")
        static let adTracking = NSLocalizedString("tracking.ad_tracking", comment: "Track ad transparency")
    }
    
    // MARK: - Security
    
    enum Security {
        static let authentication = NSLocalizedString("security.authentication", comment: "Authentication")
        static let encryption = NSLocalizedString("security.encryption", comment: "Encryption")
        static let faceID = NSLocalizedString("security.face_id", comment: "Face ID")
        static let touchID = NSLocalizedString("security.touch_id", comment: "Touch ID")
        static let passcode = NSLocalizedString("security.passcode", comment: "Passcode")
    }
    
    // MARK: - Data
    
    enum Data {
        static let export = NSLocalizedString("data.export", comment: "Export data")
        static let exportAll = NSLocalizedString("data.export.all", comment: "Export all data")
        static let exportFormat = NSLocalizedString("data.export.format", comment: "Export format")
        static let json = NSLocalizedString("data.export.json", comment: "JSON format")
        static let csv = NSLocalizedString("data.export.csv", comment: "CSV format")
        static let clear = NSLocalizedString("data.clear", comment: "Clear data")
        static let clearConfirm = NSLocalizedString("data.clear.confirm", comment: "Clear confirmation")
        static let retention = NSLocalizedString("data.retention", comment: "Data retention")
        
        enum Retention {
            static let thirtyDays = NSLocalizedString("data.retention.30days", comment: "30 days")
            static let ninetyDays = NSLocalizedString("data.retention.90days", comment: "90 days")
            static let oneYear = NSLocalizedString("data.retention.1year", comment: "1 year")
            static let forever = NSLocalizedString("data.retention.forever", comment: "Forever")
        }
    }
    
    // MARK: - Export
    
    enum Export {
        static let title = NSLocalizedString("export.title", comment: "Export title")
        static let items = NSLocalizedString("export.items", comment: "Items")
        static let size = NSLocalizedString("export.size", comment: "Size")
        static let exporting = NSLocalizedString("export.exporting", comment: "Exporting")
        static let success = NSLocalizedString("export.success", comment: "Export success")
        static let error = NSLocalizedString("export.error", comment: "Export error")
    }
    
    // MARK: - Statistics
    
    enum Stats {
        static let total = NSLocalizedString("stats.total", comment: "Total")
        static let today = NSLocalizedString("stats.today", comment: "Today")
        static let thisWeek = NSLocalizedString("stats.this_week", comment: "This week")
        static let thisMonth = NSLocalizedString("stats.this_month", comment: "This month")
        static let allTime = NSLocalizedString("stats.all_time", comment: "All time")
    }
    
    // MARK: - Errors
    
    enum Error {
        static let unknown = NSLocalizedString("error.unknown", comment: "Unknown error")
        static let permissionDenied = NSLocalizedString("error.permission_denied", comment: "Permission denied")
        static let exportFailed = NSLocalizedString("error.export_failed", comment: "Export failed")
        static let importFailed = NSLocalizedString("error.import_failed", comment: "Import failed")
        static let network = NSLocalizedString("error.network", comment: "Network error")
    }
    
    // MARK: - Buttons
    
    enum Button {
        static let ok = NSLocalizedString("button.ok", comment: "OK")
        static let cancel = NSLocalizedString("button.cancel", comment: "Cancel")
        static let delete = NSLocalizedString("button.delete", comment: "Delete")
        static let save = NSLocalizedString("button.save", comment: "Save")
        static let export = NSLocalizedString("button.export", comment: "Export")
        static let importButton = NSLocalizedString("button.import", comment: "Import")
        static let done = NSLocalizedString("button.done", comment: "Done")
        static let close = NSLocalizedString("button.close", comment: "Close")
        static let settings = NSLocalizedString("button.settings", comment: "Settings")
        static let enable = NSLocalizedString("button.enable", comment: "Enable")
        static let disable = NSLocalizedString("button.disable", comment: "Disable")
    }
    
    // MARK: - Time
    
    enum Time {
        static let now = NSLocalizedString("time.now", comment: "Now")
        static let today = NSLocalizedString("time.today", comment: "Today")
        static let yesterday = NSLocalizedString("time.yesterday", comment: "Yesterday")
        static let thisWeek = NSLocalizedString("time.this_week", comment: "This week")
        static let lastWeek = NSLocalizedString("time.last_week", comment: "Last week")
        static let thisMonth = NSLocalizedString("time.this_month", comment: "This month")
        static let lastMonth = NSLocalizedString("time.last_month", comment: "Last month")
    }
    
    // MARK: - About
    
    enum About {
        static let version = NSLocalizedString("about.version", comment: "Version")
        static let build = NSLocalizedString("about.build", comment: "Build")
        static let github = NSLocalizedString("about.github", comment: "GitHub")
        static let license = NSLocalizedString("about.license", comment: "License")
        static let reportIssue = NSLocalizedString("about.report_issue", comment: "Report issue")
        static let privacyPolicy = NSLocalizedString("about.privacy_policy", comment: "Privacy policy")
    }
}

// MARK: - String Extension

extension String {
    /// Localize a string using NSLocalizedString
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Localize a string with arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
