import SwiftUI

// MARK: - MacActivityListView

struct MacActivityListView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @State private var selectedFilter: ActivityType?
    @State private var searchText = ""
    @State private var selectedActivity: (any ActivityRecord)?
    @State private var sortOrder: SortOrder = .newest

    var body: some View {
        HSplitView {
            // Activity List
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Text("Activities")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Menu {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Button(action: { selectedFilter = selectedFilter == type ? nil : type }) {
                                Label(type.displayName, systemImage: type.icon)
                                if selectedFilter == type {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }

                        Divider()

                        Button("Clear Filter") {
                            selectedFilter = nil
                        }
                        .disabled(selectedFilter == nil)
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }

                    Menu {
                        Button(action: { sortOrder = .newest }) {
                            Label("Newest First", systemImage: sortOrder == .newest ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .oldest }) {
                            Label("Oldest First", systemImage: sortOrder == .oldest ? "checkmark" : "")
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor))

                Divider()

                // Activity List
                if filteredActivities.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("No Activities")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Activities will appear here when you start tracking")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List(selection: $selectedActivity) {
                        ForEach(filteredActivities.indices, id: \.self) { index in
                            MacActivityListRow(activity: filteredActivities[index])
                                .tag(filteredActivities[index].id as AnyHashable)
                        }
                    }
                }
            }
            .frame(minWidth: 350)

            // Detail View
            if let activity = selectedActivity {
                MacActivityDetailView(activity: activity)
                    .frame(minWidth: 400)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("Select an Activity")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.textBackgroundColor))
            }
        }
    }

    private var filteredActivities: [any ActivityRecord] {
        var activities: [any ActivityRecord] = []

        if selectedFilter == nil || selectedFilter == .location {
            activities.append(contentsOf: viewModel.locationActivities)
        }
        if selectedFilter == nil || selectedFilter == .calendar {
            activities.append(contentsOf: viewModel.calendarActivities)
        }
        if selectedFilter == nil || selectedFilter == .media {
            activities.append(contentsOf: viewModel.mediaActivities)
        }
        if selectedFilter == nil || selectedFilter == .device {
            activities.append(contentsOf: viewModel.deviceActivities)
        }

        // Sort
        activities.sort {
            sortOrder == .newest ? $0.timestamp > $1.timestamp : $0.timestamp < $1.timestamp
        }

        // Filter by search
        if !searchText.isEmpty {
            activities = activities.filter { activity in
                if let title = activity.title {
                    return title.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }

        return activities
    }
}

// MARK: - MacActivityListRow

struct MacActivityListRow: View {
    let activity: any ActivityRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.activityType.icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title ?? "Untitled")
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(activity.activityType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(iconColor.opacity(0.2))
                        .foregroundColor(iconColor)
                        .cornerRadius(4)

                    Text(activity.relativeTimeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if activity.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 8)
    }

    private var iconColor: Color {
        switch activity.activityType {
        case .location: return .blue
        case .calendar: return .red
        case .media: return .purple
        case .url: return .orange
        case .call: return .green
        case .device: return .gray
        case .adTracking: return .pink
        case .custom: return .indigo
        }
    }
}

// MARK: - MacActivityDetailView

struct MacActivityDetailView: View {
    let activity: any ActivityRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: activity.activityType.icon)
                        .font(.largeTitle)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.title ?? "Untitled")
                            .font(.title)
                            .fontWeight(.bold)

                        Text(activity.activityType.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if activity.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    }
                }

                Divider()

                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Timestamp", value: activity.formattedTimestamp)
                    DetailRow(label: "Privacy Level", value: activity.privacyLevel.displayName)

                    if !activity.tags.isEmpty {
                        DetailRow(label: "Tags", value: activity.tags.joined(separator: ", "))
                    }

                    if let notes = activity.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)

                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(32)
        }
        .background(Color(.textBackgroundColor))
    }
}

// MARK: - DetailRow

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - SortOrder

enum SortOrder {
    case newest
    case oldest
}

// MARK: - Preview

struct MacActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        MacActivityListView()
            .environmentObject(DashboardViewModel())
            .frame(width: 1000, height: 700)
    }
}
