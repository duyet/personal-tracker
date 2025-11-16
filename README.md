# Personal Tracker

[![CI](https://github.com/yourusername/personal-tracker/workflows/CI/badge.svg)](https://github.com/yourusername/personal-tracker/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B%20%7C%20macOS%2014.0%2B-lightgrey.svg)](https://developer.apple.com)

A privacy-first, beautifully crafted iOS and macOS application that gives you complete visibility and control over your digital footprint. Track locations, calendar events, photos, device usage, and more—all while keeping your data secure and private.

## ✨ Features

### Core Tracking
- 📍 **Location Tracking** - Track your visited places with beautiful visualizations
- 📅 **Calendar Integration** - Analyze your time allocation and events
- 📸 **Media Tracking** - Understand your photo and video creation habits
- 🌐 **URL Tracking** - Monitor your browsing patterns (coming soon)
- 📱 **Device Metrics** - Battery, storage, and system information
- 🛡️ **Ad Tracking Transparency** - Monitor and control ad tracking

### Privacy & Security
- 🔒 **Privacy First** - All data stored locally by default
- 🔐 **Encryption** - Sensitive data encrypted at rest
- ✋ **Granular Controls** - Fine-grained privacy settings
- 📊 **Privacy Score** - Real-time privacy recommendations
- 🚫 **No Third-Party Tracking** - Zero analytics or data collection
- ☁️ **Optional CloudKit Sync** - End-to-end encrypted cloud backup

### Data & Insights
- 📈 **Statistics** - Comprehensive analytics and visualizations
- 📤 **Data Export** - JSON and CSV export capabilities
- 🔍 **Search & Filter** - Powerful search across all activities
- ⭐ **Favorites** - Mark important activities
- 🏷️ **Tags** - Organize with custom tags
- 🌓 **Dark Mode** - Beautiful dark theme support

### Platform Features
- 📱 **iOS & macOS** - Native apps for iPhone, iPad, and Mac
- ♿ **Accessibility** - Full VoiceOver and Dynamic Type support
- 🌍 **Localization** - Multi-language support
- 🎨 **Widgets** - iOS home screen widgets
- ⌨️ **Shortcuts** - Siri Shortcuts integration
- 🔔 **Notifications** - Smart privacy alerts

## 🎯 Philosophy

**Privacy is not optional. It's fundamental.**

Personal Tracker is built on the belief that your personal data belongs to you—and only you. Every design decision prioritizes your privacy and security:

- Data stays on your device by default
- No telemetry, no analytics, no tracking
- Transparent permission requests with clear explanations
- User control over every data point collected
- Open source and auditable

Read our full philosophy in [CLAUDE.md](CLAUDE.md).

## 📱 Screenshots

| Dashboard | Privacy | Activities |
|-----------|---------|------------|
| _Coming Soon_ | _Coming Soon_ | _Coming Soon_ |

## 🚀 Getting Started

### Requirements

- **iOS**: iOS 17.0 or later
- **macOS**: macOS 14.0 (Sonoma) or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later

### Installation

#### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/personal-tracker.git
   cd personal-tracker
   ```

2. Open in Xcode:
   ```bash
   open PersonalTracker/PersonalTracker.xcodeproj
   ```

3. Select your target device/simulator

4. Build and run (`Cmd + R`)

#### App Store

_Coming Soon_

### First Launch

On first launch, Personal Tracker will:

1. Show an onboarding flow explaining privacy principles
2. Request necessary permissions (you control what to enable)
3. Set up local data storage with encryption
4. Present the dashboard

## 🏗️ Architecture

Personal Tracker follows a clean MVVM architecture with a focus on testability and maintainability:

```
┌─────────────────┐
│     Views       │  SwiftUI views, minimal logic
├─────────────────┤
│   ViewModels    │  ObservableObject, state management
├─────────────────┤
│    Services     │  Business logic, data fetching
├─────────────────┤
│     Models      │  Data structures, Codable
└─────────────────┘
```

### Project Structure

```
PersonalTracker/
├── PersonalTracker/              # iOS App Target
│   ├── App/                      # App lifecycle & entry point
│   ├── Views/                    # SwiftUI views
│   └── Resources/                # Assets, localizations
├── PersonalTrackerMac/           # macOS App Target
├── PersonalTrackerShared/        # Shared Framework
│   ├── Models/                   # Data models
│   │   ├── ActivityRecord.swift
│   │   ├── LocationActivity.swift
│   │   ├── CalendarActivity.swift
│   │   └── ...
│   ├── Services/                 # Business logic
│   │   ├── LocationTrackingService.swift
│   │   ├── CalendarService.swift
│   │   ├── PrivacyService.swift
│   │   └── ...
│   ├── ViewModels/              # MVVM ViewModels
│   │   ├── DashboardViewModel.swift
│   │   └── SettingsViewModel.swift
│   └── Utilities/               # Helpers & extensions
├── PersonalTrackerTests/        # Unit tests
└── PersonalTrackerUITests/      # UI tests
```

## 🛠️ Development

### Setup

1. Install development tools:
   ```bash
   brew install swiftlint swiftformat
   ```

2. Read the project guidelines:
   - [CLAUDE.md](CLAUDE.md) - Project philosophy and architecture
   - [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme PersonalTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run with code coverage
xcodebuild test -scheme PersonalTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES
```

### Code Quality

```bash
# Lint code
swiftlint lint

# Auto-format code
swiftformat .

# Check formatting
swiftformat --lint .
```

## 📊 Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Reactive**: Combine
- **Persistence**: CoreData with CloudKit
- **Testing**: XCTest
- **Dependencies**: Swift Package Manager
- **CI/CD**: GitHub Actions
- **Code Quality**: SwiftLint + SwiftFormat

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linters
5. Commit with clear messages (`git commit -m '[Feature] Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 🔒 Privacy & Security

### Data Storage

- All data stored locally using CoreData
- Sensitive fields encrypted with AES-256
- Optional CloudKit sync with end-to-end encryption
- Keychain for sensitive credentials

### Permissions

Personal Tracker requests these permissions (all optional):

- **Location**: Track visited places
- **Calendar**: Analyze time allocation
- **Photos**: Track media creation
- **Contacts**: Enrich communication data (optional)

Each permission includes a clear explanation of why it's needed and how data is used.

### Security Features

- Face ID/Touch ID authentication
- Secure enclave for encryption keys
- No third-party SDKs or analytics
- Regular security audits
- Open source for transparency

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ by the Personal Tracker community
- Inspired by the need for privacy-first personal analytics
- Thanks to all contributors and supporters

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/personal-tracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/personal-tracker/discussions)
- **Email**: support@personaltracker.app (if available)

## 🗺️ Roadmap

### Version 1.0 (Current)
- [x] Core tracking features
- [x] Privacy dashboard
- [x] Data export
- [x] iOS and macOS apps

### Version 1.1 (Planned)
- [ ] Advanced visualizations
- [ ] Timeline view
- [ ] Search improvements
- [ ] Batch operations

### Version 2.0 (Future)
- [ ] watchOS companion app
- [ ] visionOS support
- [ ] Machine learning insights
- [ ] Automation rules

## ⭐ Show Your Support

If you find Personal Tracker useful, please consider:

- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 📢 Sharing with others
- 🤝 Contributing code

---

**Built with privacy, powered by community.**

Made with 💙 for people who value their privacy.
