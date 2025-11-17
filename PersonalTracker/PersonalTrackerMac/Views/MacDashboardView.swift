import SwiftUI
import Charts

// MARK: - MacDashboardView

struct MacDashboardView: View {
    @EnvironmentObject var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(Date().formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { viewModel.refresh() }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)

                // Summary Cards
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 16
                ) {
                    MacSummaryCard(
                        title: "Locations",
                        value: "\(viewModel.locationActivities.count)",
                        icon: "location.fill",
                        color: .blue
                    )

                    MacSummaryCard(
                        title: "Calendar Events",
                        value: "\(viewModel.calendarActivities.count)",
                        icon: "calendar",
                        color: .red
                    )

                    MacSummaryCard(
                        title: "Media Items",
                        value: "\(viewModel.mediaActivities.count)",
                        icon: "photo.fill",
                        color: .purple
                    )

                    MacSummaryCard(
                        title: "Device Snapshots",
                        value: "\(viewModel.deviceActivities.count)",
                        icon: "iphone",
                        color: .gray
                    )
                }
                .padding(.horizontal, 32)

                // Recent Activities
                HStack(spacing: 16) {
                    // Locations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Locations")
                            .font(.headline)

                        if viewModel.locationActivities.isEmpty {
                            EmptyStateCard(
                                icon: "location.slash",
                                message: "No locations tracked"
                            )
                        } else {
                            ForEach(Array(viewModel.locationActivities.prefix(5))) { location in
                                MacLocationRow(activity: location)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(12)

                    // Calendar Events
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Events")
                            .font(.headline)

                        if viewModel.calendarActivities.isEmpty {
                            EmptyStateCard(
                                icon: "calendar.badge.exclamationmark",
                                message: "No calendar events"
                            )
                        } else {
                            ForEach(Array(viewModel.calendarActivities.prefix(5))) { event in
                                MacEventRow(activity: event)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .background(Color(.textBackgroundColor))
    }
}

// MARK: - MacSummaryCard

struct MacSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)

                Spacer()
            }

            Text(value)
                .font(.system(size: 32, weight: .bold))

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - MacLocationRow

struct MacLocationRow: View {
    let activity: LocationActivity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.category.icon)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title ?? "Unknown Location")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let address = activity.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(activity.shortRelativeTimeString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - MacEventRow

struct MacEventRow: View {
    let activity: CalendarActivity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.eventType.icon)
                .foregroundColor(.red)
                .frame(width: 32, height: 32)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title ?? "Untitled Event")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(activity.formattedDuration) • \(activity.calendar)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(activity.shortRelativeTimeString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EmptyStateCard

struct EmptyStateCard: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Preview

struct MacDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MacDashboardView()
            .environmentObject(DashboardViewModel())
            .frame(width: 900, height: 700)
    }
}
