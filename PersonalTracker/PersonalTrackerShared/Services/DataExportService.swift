import Foundation

// MARK: - DataExportService

/// Service for exporting activity data in various formats
@available(iOS 14.0, macOS 11.0, *)
final class DataExportService {
    // MARK: - Export Format

    enum ExportFormat {
        case json
        case csv
        case xml
    }

    // MARK: - Public Methods

    /// Export activities to JSON format
    func exportToJSON<T: Encodable>(_ activities: [T], prettyPrint: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if prettyPrint {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }

        return try encoder.encode(activities)
    }

    /// Export activities to CSV format
    func exportToCSV(_ activities: [any ActivityRecord]) throws -> Data {
        var csv = "ID,Timestamp,Type,Title,Notes,Tags,Favorite,Privacy Level\n"

        for activity in activities {
            let row = [
                activity.id.uuidString,
                ISO8601DateFormatter().string(from: activity.timestamp),
                activity.activityType.rawValue,
                escapeCSVField(activity.title ?? ""),
                escapeCSVField(activity.notes ?? ""),
                escapeCSVField(activity.tags.joined(separator: "; ")),
                activity.isFavorite ? "true" : "false",
                activity.privacyLevel.rawValue
            ].joined(separator: ",")

            csv += row + "\n"
        }

        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }

        return data
    }

    /// Export location activities to CSV with location-specific fields
    func exportLocationActivitiesToCSV(_ activities: [LocationActivity]) throws -> Data {
        var csv = "ID,Timestamp,Title,Latitude,Longitude,Altitude,Accuracy,Address,Place Name,Category\n"

        for activity in activities {
            let row = [
                activity.id.uuidString,
                ISO8601DateFormatter().string(from: activity.timestamp),
                escapeCSVField(activity.title ?? ""),
                String(activity.latitude),
                String(activity.longitude),
                activity.altitude.map { String($0) } ?? "",
                String(activity.horizontalAccuracy),
                escapeCSVField(activity.address ?? ""),
                escapeCSVField(activity.placeName ?? ""),
                activity.category.rawValue
            ].joined(separator: ",")

            csv += row + "\n"
        }

        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }

        return data
    }

    /// Export to file and return URL
    func exportToFile<T: Encodable>(
        _ activities: [T],
        format: ExportFormat,
        fileName: String? = nil
    ) throws -> URL {
        let data: Data

        switch format {
        case .json:
            data = try exportToJSON(activities)
        case .csv:
            if let activityRecords = activities as? [any ActivityRecord] {
                data = try exportToCSV(activityRecords)
            } else {
                throw ExportError.unsupportedType
            }
        case .xml:
            throw ExportError.unsupportedFormat
        }

        let fileExtension: String
        switch format {
        case .json: fileExtension = "json"
        case .csv: fileExtension = "csv"
        case .xml: fileExtension = "xml"
        }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let defaultFileName = "personal-tracker-export-\(timestamp).\(fileExtension)"
        let finalFileName = fileName ?? defaultFileName

        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let fileURL = documentsURL.appendingPathComponent(finalFileName)

        try data.write(to: fileURL)

        return fileURL
    }

    /// Import activities from JSON file
    func importFromJSON<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    /// Get export summary
    func getExportSummary<T: Encodable>(for activities: [T], format: ExportFormat) -> ExportSummary {
        let itemCount = activities.count
        let estimatedSize: Int

        do {
            let data: Data
            switch format {
            case .json:
                data = try exportToJSON(activities)
            case .csv:
                if let activityRecords = activities as? [any ActivityRecord] {
                    data = try exportToCSV(activityRecords)
                } else {
                    data = Data()
                }
            case .xml:
                data = Data()
            }
            estimatedSize = data.count
        } catch {
            estimatedSize = 0
        }

        return ExportSummary(
            itemCount: itemCount,
            format: format,
            estimatedSize: estimatedSize
        )
    }

    // MARK: - Private Methods

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}

// MARK: - ExportError

enum ExportError: LocalizedError {
    case encodingFailed
    case unsupportedFormat
    case unsupportedType
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data for export."
        case .unsupportedFormat:
            return "The selected export format is not supported."
        case .unsupportedType:
            return "The data type cannot be exported in this format."
        case .writeFailed:
            return "Failed to write export file."
        }
    }
}

// MARK: - ExportSummary

struct ExportSummary {
    let itemCount: Int
    let format: DataExportService.ExportFormat
    let estimatedSize: Int

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(estimatedSize), countStyle: .file)
    }

    var formatName: String {
        switch format {
        case .json: return "JSON"
        case .csv: return "CSV"
        case .xml: return "XML"
        }
    }
}
