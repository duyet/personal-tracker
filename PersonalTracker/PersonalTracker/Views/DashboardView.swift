import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @State private var showingDetailView = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Section
                    SummaryCard(summary: viewModel.getSummary())

                    // Quick Stats
                    QuickStatsView(
                        locationCount: viewModel.locationActivities.count,
                        calendarCount: viewModel.calendarActivities.count,
                        mediaCount: viewModel.mediaActivities.count
                    )

                    // Recent Activities
                    RecentActivitiesSection(
                        locations: Array(viewModel.locationActivities.prefix(5)),
                        events: Array(viewModel.calendarActivities.prefix(5))
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refresh) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primaryAccent)
                    }
                    .accessibilityLabel("Refresh")
                }
            }
            .refreshable {
                viewModel.refresh()
            }
        }
    }
}

// MARK: - SummaryCard

struct SummaryCard: View {
    let summary: DashboardSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Summary")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("\(summary.totalActivities)")
                        .font(.system(size: 36, weight: .bold))
                    Text("Total Activities")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last updated")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(summary.lastUpdateFormatted)
                        .font(.caption)
                        .foregroundColor(.primaryAccent)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - QuickStatsView

struct QuickStatsView: View {
    let locationCount: Int
    let calendarCount: Int
    let mediaCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                StatItem(
                    icon: "location.fill",
                    count: locationCount,
                    label: "Locations",
                    color: .blue
                )

                StatItem(
                    icon: "calendar",
                    count: calendarCount,
                    label: "Events",
                    color: .red
                )

                StatItem(
                    icon: "photo.fill",
                    count: mediaCount,
                    label: "Media",
                    color: .purple
                )
            }
        }
        .cardStyle()
    }
}

// MARK: - StatItem

struct StatItem: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text("\(count)")
                .font(.title3.bold())

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - RecentActivitiesSection

struct RecentActivitiesSection: View {
    let locations: [LocationActivity]
    let events: [CalendarActivity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activities")
                .font(.headline)
                .foregroundColor(.secondary)

            if !locations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Locations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(locations) { location in
                        LocationRow(activity: location)
                    }
                }
            }

            if !events.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming Events")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(events) { event in
                        EventRow(activity: event)
                    }
                }
            }

            if locations.isEmpty && events.isEmpty {
                Text("No recent activities")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .cardStyle()
    }
}

// MARK: - LocationRow

struct LocationRow: View {
    let activity: LocationActivity

    var body: some View {
        HStack {
            Image(systemName: activity.category.icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title ?? "Unknown Location")
                    .font(.subheadline)

                if let address = activity.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(activity.relativeTimeString)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EventRow

struct EventRow: View {
    let activity: CalendarActivity

    var body: some View {
        HStack {
            Image(systemName: activity.eventType.icon)
                .foregroundColor(.red)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title ?? "Untitled Event")
                    .font(.subheadline)

                Text(activity.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(activity.relativeTimeString)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(DashboardViewModel())
    }
}
