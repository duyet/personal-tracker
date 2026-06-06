import SwiftUI

// MARK: - MacPrivacyView

struct MacPrivacyView: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Privacy & Permissions")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Control your data and privacy settings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button("Check Permissions") {
                        viewModel.checkPermissions()
                    }
                    .buttonStyle(.bordered)
                }

                // Privacy Score
                if let recommendation = viewModel.privacyRecommendation {
                    MacPrivacyScoreCard(recommendation: recommendation)
                }

                Divider()

                // Permissions Grid
                Text("Permissions")
                    .font(.title2)
                    .fontWeight(.semibold)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    MacPermissionCard(
                        icon: "location.fill",
                        title: "Location",
                        description: "Track your visited places",
                        status: viewModel.permissionStatus.location,
                        action: {
                            viewModel.requestLocationPermission()
                        }
                    )

                    MacPermissionCard(
                        icon: "calendar",
                        title: "Calendar",
                        description: "Analyze your time allocation",
                        status: viewModel.permissionStatus.calendar,
                        action: {
                            Task {
                                await viewModel.requestCalendarPermission()
                            }
                        }
                    )

                    MacPermissionCard(
                        icon: "photo.fill",
                        title: "Photos",
                        description: "Track your media creation",
                        status: viewModel.permissionStatus.photos,
                        action: {
                            Task {
                                await viewModel.requestPhotosPermission()
                            }
                        }
                    )

                    MacPermissionCard(
                        icon: "person.crop.circle",
                        title: "Contacts",
                        description: "Enrich communication data",
                        status: viewModel.permissionStatus.contacts,
                        action: {}
                    )
                }

                Divider()

                // Privacy Settings
                Text("Privacy Settings")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 16) {
                    MacToggleRow(
                        title: "Require Authentication",
                        description: "Protect your data with Face ID or password",
                        isOn: binding(for: \.requireAuthentication)
                    )

                    MacToggleRow(
                        title: "Encrypt Sensitive Data",
                        description: "Enable encryption for sensitive information",
                        isOn: binding(for: \.encryptSensitiveData)
                    )

                    MacToggleRow(
                        title: "Enable Cloud Sync",
                        description: "Sync your data across devices with CloudKit",
                        isOn: binding(for: \.cloudSyncEnabled)
                    )
                }

                // Privacy Recommendations
                if let recommendation = viewModel.privacyRecommendation,
                   !recommendation.issues.isEmpty {
                    Divider()

                    Text("Privacy Recommendations")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(recommendation.issues, id: \.title) { issue in
                            MacPrivacyIssueCard(issue: issue)
                        }
                    }
                }

                Spacer()
            }
            .padding(32)
        }
        .background(Color(.textBackgroundColor))
    }

    private func binding(for keyPath: WritableKeyPath<PrivacySettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { viewModel.privacySettings[keyPath: keyPath] },
            set: { _ in viewModel.toggleSetting(keyPath) }
        )
    }
}

// MARK: - MacPrivacyScoreCard

struct MacPrivacyScoreCard: View {
    let recommendation: PrivacyRecommendation

    var body: some View {
        HStack(spacing: 32) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: recommendation.score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text(recommendation.scoreFormatted)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(scoreColor)

                    Text("Privacy Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: recommendation.level.icon)
                    Text(recommendation.level.displayName)
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(scoreColor)

                Text(recommendation.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }

    private var scoreColor: Color {
        switch recommendation.level {
        case .high: return .green
        case .medium: return .yellow
        case .low: return .red
        }
    }
}

// MARK: - MacPermissionCard

struct MacPermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionState
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

                Spacer()

                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
            }

            Text(title)
                .font(.headline)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: action) {
                Text(status.isGranted ? "Granted" : "Grant Access")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(statusColor)
            .disabled(status.isGranted)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch status {
        case .authorized, .limited: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        }
    }

    private var statusIcon: String {
        switch status {
        case .authorized, .limited: return "checkmark.circle.fill"
        case .denied, .restricted: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle.fill"
        }
    }
}

// MARK: - MacToggleRow

struct MacToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - MacPrivacyIssueCard

struct MacPrivacyIssueCard: View {
    let issue: PrivacyIssue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(severityColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.title)
                    .font(.headline)

                Text(issue.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(severityColor.opacity(0.1))
        .cornerRadius(8)
    }

    private var severityColor: Color {
        switch issue.severity {
        case "high": return .red
        case "medium": return .orange
        case "low": return .yellow
        default: return .gray
        }
    }
}

// MARK: - Preview

struct MacPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        MacPrivacyView()
            .environmentObject(SettingsViewModel())
            .frame(width: 900, height: 700)
    }
}
