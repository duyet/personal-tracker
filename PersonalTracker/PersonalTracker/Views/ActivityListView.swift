import SwiftUI

// MARK: - ActivityListView

struct ActivityListView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @State private var selectedFilter: ActivityType?
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.displayName,
                                icon: type.icon,
                                isSelected: selectedFilter == type,
                                action: {
                                    selectedFilter = selectedFilter == type ? nil : type
                                }
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))

                Divider()

                // Activity List
                if filteredActivities.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredActivities.indices, id: \.self) { index in
                            ActivityRowView(activity: filteredActivities[index])
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Activities")
            .searchable(text: $searchText, prompt: "Search activities")
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

        // Sort by timestamp
        activities.sort { $0.timestamp > $1.timestamp }

        // Filter by search text
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

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryAccent : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - ActivityRowView

struct ActivityRowView: View {
    let activity: any ActivityRecord

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: activity.activityType.icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .cornerRadius(8)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title ?? "Untitled")
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(activity.activityType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
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

            // Favorite indicator
            if activity.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
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

// MARK: - EmptyStateView

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Activities Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start tracking to see your activities here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
            .environmentObject(DashboardViewModel())
    }
}
