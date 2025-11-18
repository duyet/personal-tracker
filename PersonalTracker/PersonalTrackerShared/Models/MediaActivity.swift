import Foundation
import Photos
import CoreLocation

// MARK: - MediaActivity

/// Represents a photo or video captured or saved by the user
struct MediaActivity: ActivityRecord {
    let id: UUID
    let timestamp: Date
    let activityType: ActivityType = .media
    var title: String?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    var privacyLevel: PrivacyLevel
    var metadata: [String: String]

    // Media-specific properties
    let assetIdentifier: String?
    let mediaType: MediaType
    let fileName: String?
    let fileSize: Int64?
    let width: Int?
    let height: Int?
    let duration: TimeInterval?
    let location: CLLocationCoordinate2D?
    let creationDate: Date
    let modificationDate: Date?
    let albumName: String?
    let isFavoriteInPhotos: Bool
    let isHidden: Bool
    let source: MediaSource

    private enum CodingKeys: String, CodingKey {
        case id, timestamp, title, notes, tags, isFavorite, privacyLevel, metadata
        case assetIdentifier, mediaType, fileName, fileSize, width, height, duration
        case creationDate, modificationDate, albumName, isFavoriteInPhotos, isHidden, source
        // Note: CLLocationCoordinate2D is not Codable, so location is excluded
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        assetIdentifier: String? = nil,
        mediaType: MediaType,
        fileName: String? = nil,
        fileSize: Int64? = nil,
        width: Int? = nil,
        height: Int? = nil,
        duration: TimeInterval? = nil,
        location: CLLocationCoordinate2D? = nil,
        creationDate: Date,
        modificationDate: Date? = nil,
        albumName: String? = nil,
        isFavoriteInPhotos: Bool = false,
        isHidden: Bool = false,
        source: MediaSource = .camera,
        title: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        privacyLevel: PrivacyLevel = .privateLevel,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.assetIdentifier = assetIdentifier
        self.mediaType = mediaType
        self.fileName = fileName
        self.fileSize = fileSize
        self.width = width
        self.height = height
        self.duration = duration
        self.location = location
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.albumName = albumName
        self.isFavoriteInPhotos = isFavoriteInPhotos
        self.isHidden = isHidden
        self.source = source
        self.title = title
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.privacyLevel = privacyLevel
        self.metadata = metadata
    }

    /// Formatted file size string
    var formattedFileSize: String? {
        guard let fileSize = fileSize else { return nil }
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    /// Resolution string (e.g., "1920x1080")
    var resolution: String? {
        guard let width = width, let height = height else { return nil }
        return "\(width)×\(height)"
    }

    /// Aspect ratio
    var aspectRatio: Double? {
        guard let width = width, let height = height, height > 0 else { return nil }
        return Double(width) / Double(height)
    }

    /// Check if media has location data
    var hasLocation: Bool {
        location != nil
    }

    /// Formatted duration for videos
    var formattedDuration: String? {
        guard let duration = duration else { return nil }

        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - MediaType

/// Type of media content
enum MediaType: String, Codable, CaseIterable {
    case photo
    case video
    case livePhoto
    case panorama
    case burst
    case timelapse
    case slowMotion
    case screenshot
    case screenRecording

    var displayName: String {
        switch self {
        case .photo: return "Photo"
        case .video: return "Video"
        case .livePhoto: return "Live Photo"
        case .panorama: return "Panorama"
        case .burst: return "Burst"
        case .timelapse: return "Time-lapse"
        case .slowMotion: return "Slow Motion"
        case .screenshot: return "Screenshot"
        case .screenRecording: return "Screen Recording"
        }
    }

    var icon: String {
        switch self {
        case .photo: return "photo.fill"
        case .video: return "video.fill"
        case .livePhoto: return "livephoto"
        case .panorama: return "panorama.fill"
        case .burst: return "square.stack.3d.up.fill"
        case .timelapse: return "timelapse"
        case .slowMotion: return "slowmo"
        case .screenshot: return "camera.viewfinder"
        case .screenRecording: return "record.circle.fill"
        }
    }

    var isVideo: Bool {
        switch self {
        case .video, .timelapse, .slowMotion, .screenRecording:
            return true
        default:
            return false
        }
    }

    var isPhoto: Bool {
        !isVideo
    }
}

// MARK: - MediaSource

/// Source where media was created or imported from
enum MediaSource: String, Codable, CaseIterable {
    case camera
    case download
    case airdrop
    case screenshot
    case imported
    case other

    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .download: return "Download"
        case .airdrop: return "AirDrop"
        case .screenshot: return "Screenshot"
        case .imported: return "Import"
        case .other: return "Other"
        }
    }
}

// MARK: - MediaActivity Extension

extension MediaActivity {
    /// Initialize from PHAsset
    init(from asset: PHAsset) {
        self.id = UUID()
        self.timestamp = asset.creationDate ?? Date()
        self.assetIdentifier = asset.localIdentifier

        // Determine media type
        if asset.mediaType == .video {
            if asset.mediaSubtypes.contains(.videoTimelapse) {
                self.mediaType = .timelapse
            } else if asset.mediaSubtypes.contains(.videoHighFrameRate) {
                self.mediaType = .slowMotion
            } else if asset.mediaSubtypes.contains(.videoStreamed) {
                self.mediaType = .screenRecording
            } else {
                self.mediaType = .video
            }
        } else {
            if asset.mediaSubtypes.contains(.photoLive) {
                self.mediaType = .livePhoto
            } else if asset.mediaSubtypes.contains(.photoPanorama) {
                self.mediaType = .panorama
            } else if asset.mediaSubtypes.contains(.photoScreenshot) {
                self.mediaType = .screenshot
            } else {
                self.mediaType = .photo
            }
        }

        self.fileName = asset.value(forKey: "filename") as? String
        self.fileSize = nil // Need to fetch separately
        self.width = asset.pixelWidth
        self.height = asset.pixelHeight
        self.duration = asset.mediaType == .video ? asset.duration : nil
        self.location = asset.location?.coordinate
        self.creationDate = asset.creationDate ?? Date()
        self.modificationDate = asset.modificationDate
        self.albumName = nil // Need to fetch separately
        self.isFavoriteInPhotos = asset.isFavorite
        self.isHidden = asset.isHidden
        self.source = asset.mediaSubtypes.contains(.photoScreenshot) ? .screenshot : .camera
        self.title = nil
        self.notes = nil
        self.tags = []
        self.isFavorite = false
        self.privacyLevel = .privateLevel
        self.metadata = [:]
    }
}
