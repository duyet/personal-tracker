import Foundation
import Photos
import Combine

// MARK: - MediaTrackingService

/// Service for tracking photos and videos from the user's library
@available(iOS 14.0, macOS 11.0, *)
final class MediaTrackingService: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published private(set) var activities: [MediaActivity] = []
    @Published private(set) var error: MediaError?
    @Published private(set) var isLoading = false

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let imageManager = PHCachingImageManager()

    // MARK: - Initialization

    override init() {
        super.init()
        checkAuthorizationStatus()
        observePhotoLibraryChanges()
    }

    // MARK: - Public Methods

    /// Request photo library access permission
    func requestPermission() async {
        if #available(iOS 14, *) {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.authorizationStatus = status
                }
            }
        }
    }

    /// Fetch all media from the library
    func fetchAllMedia(limit: Int? = nil) {
        guard isAuthorized else {
            error = .permissionDenied
            return
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            if let limit = limit {
                fetchOptions.fetchLimit = limit
            }

            let assets = PHAsset.fetchAssets(with: fetchOptions)
            var mediaActivities: [MediaActivity] = []

            assets.enumerateObjects { asset, _, _ in
                let activity = MediaActivity(from: asset)
                mediaActivities.append(activity)
            }

            DispatchQueue.main.async {
                self.activities = mediaActivities
                self.isLoading = false
            }
        }
    }

    /// Fetch recent media
    func fetchRecentMedia(days: Int = 7, limit: Int = 100) {
        guard isAuthorized else {
            error = .permissionDenied
            return
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let calendar = Calendar.current
            guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else { return }

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(
                format: "creationDate >= %@",
                startDate as NSDate
            )
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = limit

            let assets = PHAsset.fetchAssets(with: fetchOptions)
            var mediaActivities: [MediaActivity] = []

            assets.enumerateObjects { asset, _, _ in
                let activity = MediaActivity(from: asset)
                mediaActivities.append(activity)
            }

            DispatchQueue.main.async {
                self.activities = mediaActivities
                self.isLoading = false
            }
        }
    }

    /// Fetch photos only
    func fetchPhotos(limit: Int? = nil) {
        fetchMediaByType(.image, limit: limit)
    }

    /// Fetch videos only
    func fetchVideos(limit: Int? = nil) {
        fetchMediaByType(.video, limit: limit)
    }

    /// Fetch media from a specific album
    func fetchMediaFromAlbum(_ albumName: String) {
        guard isAuthorized else {
            error = .permissionDenied
            return
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title == %@", albumName)

            let collections = PHAssetCollection.fetchAssetCollections(
                with: .album,
                subtype: .any,
                options: fetchOptions
            )

            guard let collection = collections.firstObject else {
                DispatchQueue.main.async {
                    self.error = .albumNotFound
                    self.isLoading = false
                }
                return
            }

            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            var mediaActivities: [MediaActivity] = []

            assets.enumerateObjects { asset, _, _ in
                let activity = MediaActivity(from: asset)
                mediaActivities.append(activity)
            }

            DispatchQueue.main.async {
                self.activities = mediaActivities
                self.isLoading = false
            }
        }
    }

    /// Get media statistics
    func getStatistics(for activities: [MediaActivity]) -> MediaStatistics {
        MediaStatistics.calculate(from: activities)
    }

    /// Clear all cached activities
    func clearActivities() {
        activities.removeAll()
    }

    // MARK: - Private Methods

    private func checkAuthorizationStatus() {
        if #available(iOS 14, *) {
            authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            authorizationStatus = PHPhotoLibrary.authorizationStatus()
        }
    }

    private var isAuthorized: Bool {
        if #available(iOS 14, *) {
            return authorizationStatus == .authorized || authorizationStatus == .limited
        } else {
            return authorizationStatus == .authorized
        }
    }

    private func fetchMediaByType(_ mediaType: PHAssetMediaType, limit: Int?) {
        guard isAuthorized else {
            error = .permissionDenied
            return
        }

        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", mediaType.rawValue)
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            if let limit = limit {
                fetchOptions.fetchLimit = limit
            }

            let assets = PHAsset.fetchAssets(with: fetchOptions)
            var mediaActivities: [MediaActivity] = []

            assets.enumerateObjects { asset, _, _ in
                let activity = MediaActivity(from: asset)
                mediaActivities.append(activity)
            }

            DispatchQueue.main.async {
                self.activities = mediaActivities
                self.isLoading = false
            }
        }
    }

    private func observePhotoLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

@available(iOS 14.0, macOS 11.0, *)
extension MediaTrackingService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Handle photo library changes if needed
        // Can refresh activities when new photos are added
    }
}

// MARK: - MediaError

/// Errors that can occur with media access
enum MediaError: LocalizedError {
    case permissionDenied
    case albumNotFound
    case fetchFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo library permission denied. Please enable in Settings."
        case .albumNotFound:
            return "The specified album was not found."
        case .fetchFailed:
            return "Failed to fetch media from library."
        case .unknown(let message):
            return "Media error: \(message)"
        }
    }
}

// MARK: - MediaStatistics

/// Statistics for media activities
struct MediaStatistics {
    let totalMedia: Int
    let totalPhotos: Int
    let totalVideos: Int
    let totalSize: Int64
    let averageSize: Int64
    let oldestMedia: MediaActivity?
    let newestMedia: MediaActivity?
    let mediaByType: [MediaType: Int]
    let mediaBySource: [MediaSource: Int]
    let mediaWithLocation: Int
    let totalVideoDuration: TimeInterval

    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    var formattedAverageSize: String {
        ByteCountFormatter.string(fromByteCount: averageSize, countStyle: .file)
    }

    var locationPercentage: Double {
        guard totalMedia > 0 else { return 0 }
        return Double(mediaWithLocation) / Double(totalMedia)
    }

    static func calculate(from activities: [MediaActivity]) -> MediaStatistics {
        let totalMedia = activities.count
        let totalPhotos = activities.filter { $0.mediaType.isPhoto }.count
        let totalVideos = activities.filter { $0.mediaType.isVideo }.count

        let totalSize = activities.compactMap { $0.fileSize }.reduce(0, +)
        let averageSize = totalMedia > 0 ? totalSize / Int64(totalMedia) : 0

        let oldestMedia = activities.min { $0.creationDate < $1.creationDate }
        let newestMedia = activities.max { $0.creationDate < $1.creationDate }

        let mediaByType = Dictionary(grouping: activities, by: { $0.mediaType })
            .mapValues { $0.count }

        let mediaBySource = Dictionary(grouping: activities, by: { $0.source })
            .mapValues { $0.count }

        let mediaWithLocation = activities.filter { $0.hasLocation }.count

        let totalVideoDuration = activities
            .compactMap { $0.duration }
            .reduce(0, +)

        return MediaStatistics(
            totalMedia: totalMedia,
            totalPhotos: totalPhotos,
            totalVideos: totalVideos,
            totalSize: totalSize,
            averageSize: averageSize,
            oldestMedia: oldestMedia,
            newestMedia: newestMedia,
            mediaByType: mediaByType,
            mediaBySource: mediaBySource,
            mediaWithLocation: mediaWithLocation,
            totalVideoDuration: totalVideoDuration
        )
    }
}
