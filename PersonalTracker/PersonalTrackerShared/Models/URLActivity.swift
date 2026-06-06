import Foundation

// MARK: - URLActivity

/// Represents a URL visit or browsing activity
struct URLActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .url
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // URL-specific properties
    let url: URL
    let pageTitle: String?
    let domain: String
    let scheme: String?
    let visitCount: Int
    let lastVisitDate: Date
    let isBookmarked: Bool
    let source: BrowserSource
    let referrer: URL?
    let duration: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case id, timestamp, title, notes, tags, isFavorite, privacyLevel, metadata
        case url, pageTitle, domain, scheme, visitCount, lastVisitDate
        case isBookmarked, source, referrer, duration
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        url: URL,
        pageTitle: String? = nil,
        domain: String,
        scheme: String? = nil,
        visitCount: Int = 1,
        lastVisitDate: Date = Date(),
        isBookmarked: Bool = false,
        source: BrowserSource = .safari,
        referrer: URL? = nil,
        duration: TimeInterval? = nil,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.url = url
        self.pageTitle = pageTitle
        self.domain = domain
        self.scheme = scheme
        self.visitCount = visitCount
        self.lastVisitDate = lastVisitDate
        self.isBookmarked = isBookmarked
        self.source = source
        self.referrer = referrer
        self.duration = duration
        self.title = title ?? pageTitle ?? domain
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Convenience initializer with URL string
    init?(
        urlString: String,
        pageTitle: String? = nil,
        visitCount: Int = 1,
        isBookmarked: Bool = false,
        source: BrowserSource = .safari
    ) {
        guard let url = URL(string: urlString) else { return nil }
        guard let domain = url.host else { return nil }

        self.init(
            url: url,
            pageTitle: pageTitle,
            domain: domain,
            scheme: url.scheme,
            visitCount: visitCount,
            isBookmarked: isBookmarked,
            source: source
        )
    }

    /// Full URL string
    var urlString: String {
        url.absoluteString
    }

    /// Display URL (without scheme)
    var displayURL: String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = nil
        return components?.string?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) ?? urlString
    }

    /// Check if URL is secure (HTTPS)
    var isSecure: Bool {
        scheme?.lowercased() == "https"
    }

    /// Check if URL was visited recently (within last hour)
    var isRecentlyVisited: Bool {
        guard let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) else {
            return false
        }
        return lastVisitDate >= hourAgo
    }

    /// Check if this is a frequently visited URL
    var isFrequentlyVisited: Bool {
        visitCount >= 5
    }

    /// Formatted duration string
    var formattedDuration: String? {
        guard let duration = duration else { return nil }

        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    /// Returns favicon URL for the domain
    var faviconURL: URL? {
        guard let scheme = scheme else { return nil }
        return URL(string: "\(scheme)://\(domain)/favicon.ico")
    }
}

// MARK: - BrowserSource

/// Source browser or application
enum BrowserSource: String, Codable, CaseIterable {
    case safari
    case chrome
    case firefox
    case edge
    case brave
    case other

    var displayName: String {
        switch self {
        case .safari: return "Safari"
        case .chrome: return "Chrome"
        case .firefox: return "Firefox"
        case .edge: return "Edge"
        case .brave: return "Brave"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .safari: return "safari.fill"
        case .chrome: return "globe"
        case .firefox: return "globe"
        case .edge: return "globe"
        case .brave: return "globe"
        case .other: return "globe"
        }
    }
}

// MARK: - URLCategory

/// Categorization for different types of URLs
enum URLCategory: String, Codable, CaseIterable {
    case social
    case news
    case shopping
    case entertainment
    case productivity
    case education
    case development
    case finance
    case health
    case travel
    case other

    var displayName: String {
        switch self {
        case .social: return "Social Media"
        case .news: return "News"
        case .shopping: return "Shopping"
        case .entertainment: return "Entertainment"
        case .productivity: return "Productivity"
        case .education: return "Education"
        case .development: return "Development"
        case .finance: return "Finance"
        case .health: return "Health"
        case .travel: return "Travel"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .social: return "person.3.fill"
        case .news: return "newspaper.fill"
        case .shopping: return "cart.fill"
        case .entertainment: return "play.circle.fill"
        case .productivity: return "folder.fill"
        case .education: return "book.fill"
        case .development: return "chevron.left.forwardslash.chevron.right"
        case .finance: return "dollarsign.circle.fill"
        case .health: return "heart.fill"
        case .travel: return "airplane"
        case .other: return "globe"
        }
    }

    /// Categorize URL based on domain
    static func categorize(domain: String) -> URLCategory {
        let lowercased = domain.lowercased()

        if lowercased.contains("facebook") || lowercased.contains("twitter") ||
            lowercased.contains("instagram") || lowercased.contains("linkedin") {
            return .social
        } else if lowercased.contains("news") || lowercased.contains("cnn") ||
                    lowercased.contains("bbc") {
            return .news
        } else if lowercased.contains("amazon") || lowercased.contains("shop") ||
                    lowercased.contains("store") {
            return .shopping
        } else if lowercased.contains("github") || lowercased.contains("stack") {
            return .development
        } else if lowercased.contains("youtube") || lowercased.contains("netflix") {
            return .entertainment
        }

        return .other
    }
}
