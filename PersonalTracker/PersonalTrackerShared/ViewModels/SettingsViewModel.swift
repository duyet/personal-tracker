import Foundation
import Combine
import SwiftUI

// MARK: - SettingsViewModel

/// ViewModel for app settings and preferences
@available(iOS 14.0, macOS 11.0, *)
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var privacySettings: PrivacySettings
    @Published var permissionStatus: PermissionStatus
    @Published var privacyRecommendation: PrivacyRecommendation?
    @Published var isExporting = false
    @Published var exportProgress: Double = 0
    @Published var showingExportSuccess = false
    @Published var error: Error?

    // MARK: - Services

    private let privacyService: PrivacyService
    private let exportService: DataExportService

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let logger = AppLogger.ui

    // MARK: - Initialization

    init(
        privacyService: PrivacyService = PrivacyService(),
        exportService: DataExportService = DataExportService()
    ) {
        self.privacyService = privacyService
        self.exportService = exportService
        self.privacySettings = privacyService.privacySettings
        self.permissionStatus = privacyService.permissions

        setupObservers()
        checkPermissions()
        updatePrivacyRecommendation()
    }

    // MARK: - Public Methods

    /// Request location permission
    func requestLocationPermission() {
        logger.info("Requesting location permission")
        privacyService.requestLocationPermission()
    }

    /// Request calendar permission
    func requestCalendarPermission() async {
        logger.info("Requesting calendar permission")
        do {
            try await privacyService.requestCalendarPermission()
        } catch {
            logger.error("Failed to request calendar permission", error: error)
            self.error = error
        }
    }

    /// Request photos permission
    func requestPhotosPermission() async {
        logger.info("Requesting photos permission")
        await privacyService.requestPhotosPermission()
    }

    /// Update privacy settings
    func updatePrivacySettings(_ settings: PrivacySettings) {
        logger.info("Updating privacy settings")
        privacySettings = settings
        privacyService.updateSettings(settings)
        updatePrivacyRecommendation()
    }

    /// Toggle specific privacy setting
    func toggleSetting(_ keyPath: WritableKeyPath<PrivacySettings, Bool>) {
        privacySettings[keyPath: keyPath].toggle()
        updatePrivacySettings(privacySettings)
    }

    /// Export data
    func exportData(
        activities: [any ActivityRecord],
        format: DataExportService.ExportFormat
    ) async throws -> URL {
        logger.info("Exporting data in \(format) format")
        isExporting = true
        exportProgress = 0

        defer {
            isExporting = false
            exportProgress = 0
        }

        // Simulate progress
        for progress in stride(from: 0.0, through: 0.9, by: 0.1) {
            exportProgress = progress
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }

        let url = try exportService.exportToFile(
            activities,
            format: format
        )

        exportProgress = 1.0
        showingExportSuccess = true

        logger.info("Export successful: \(url.path)")
        return url
    }

    /// Get export summary
    func getExportSummary(
        for activities: [any ActivityRecord],
        format: DataExportService.ExportFormat
    ) -> ExportSummary {
        exportService.getExportSummary(for: activities, format: format)
    }

    /// Clear all data
    func clearAllData() {
        logger.warning("Clearing all app data")
        // This would clear all stored data
        // Implementation would depend on your data persistence strategy
    }

    /// Check all permissions
    func checkPermissions() {
        logger.debug("Checking all permissions")
        privacyService.checkAllPermissions()
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe privacy service changes
        privacyService.$privacySettings
            .receive(on: DispatchQueue.main)
            .assign(to: &$privacySettings)

        privacyService.$permissions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] permissions in
                self?.permissionStatus = permissions
                self?.updatePrivacyRecommendation()
            }
            .store(in: &cancellables)
    }

    private func updatePrivacyRecommendation() {
        privacyRecommendation = privacyService.getPrivacyRecommendation()
    }
}

// MARK: - SettingsSection

enum SettingsSection: String, CaseIterable {
    case privacy = "Privacy"
    case tracking = "Tracking"
    case dataExport = "Data & Export"
    case security = "Security"
    case about = "About"

    var icon: String {
        switch self {
        case .privacy: return "hand.raised.fill"
        case .tracking: return "location.fill"
        case .dataExport: return "square.and.arrow.up.fill"
        case .security: return "lock.shield.fill"
        case .about: return "info.circle.fill"
        }
    }
}
