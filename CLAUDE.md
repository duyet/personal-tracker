# Personal Tracker - Project Philosophy & Architecture

## Vision

**Personal Tracker** is a privacy-first, beautifully crafted iOS and macOS application that gives users complete visibility and control over their digital footprint. We believe that personal data belongs to individuals, and they should have the tools to track, understand, and manage their digital activities.

## Core Principles

### 1. Privacy First
- All data is stored locally on the user's device by default
- Optional CloudKit sync with end-to-end encryption
- No third-party analytics or tracking
- Transparent permission requests with clear explanations
- User controls for every data point collected
- Easy data export and deletion

### 2. Craftsmanship Over Convention
- Every line of code should be intentional and elegant
- SwiftUI for modern, declarative UI
- MVVM architecture for clear separation of concerns
- Protocol-oriented design for testability and flexibility
- Async/await for clean asynchronous code
- Combine for reactive data flows

### 3. Native Excellence
- Platform-specific optimizations for iOS and macOS
- Deep integration with Apple ecosystem (CloudKit, HealthKit, Shortcuts)
- Follows Apple Human Interface Guidelines
- Accessibility as a first-class feature
- Dark Mode support throughout
- Responsive to Dynamic Type settings

### 4. Performance Matters
- Background processing for tracking services
- Efficient CoreData queries with proper indexing
- Lazy loading for large datasets
- Memory-conscious image handling
- Battery efficiency considerations
- Instruments profiling for optimization

### 5. Security by Design
- Keychain for sensitive data storage
- Data encryption at rest
- Secure coding practices (no force unwraps in production)
- Input validation and sanitization
- Regular security audits
- Minimal permission requests

## Architecture

### Technology Stack

```
Language:        Swift 5.9+
UI Framework:    SwiftUI
Reactive:        Combine
Persistence:     CoreData + CloudKit
Testing:         XCTest
Dependencies:    Swift Package Manager
CI/CD:           GitHub Actions
Code Quality:    SwiftLint + SwiftFormat
```

### Project Structure

```
PersonalTracker/
├── PersonalTracker/              # iOS App Target
│   ├── App/                      # App lifecycle
│   ├── Views/                    # iOS-specific views
│   ├── Resources/                # Assets, localizations
│   └── Info.plist
├── PersonalTrackerMac/           # macOS App Target
│   ├── App/
│   ├── Views/                    # macOS-specific views
│   ├── Resources/
│   └── Info.plist
├── PersonalTrackerShared/        # Shared Framework
│   ├── Models/                   # Data models
│   ├── Services/                 # Business logic
│   ├── ViewModels/               # View state management
│   ├── Utilities/                # Helpers and extensions
│   └── Resources/                # Shared assets
├── PersonalTrackerTests/         # Unit tests
├── PersonalTrackerUITests/       # UI tests
├── Widgets/                      # iOS Widgets
└── Shortcuts/                    # Shortcuts Support
```

### Core Modules

#### Models
- `ActivityRecord` - Base protocol for all tracked activities
- `LocationActivity` - GPS location tracking
- `CalendarActivity` - Calendar events integration
- `MediaActivity` - Photos and videos tracking
- `URLActivity` - Web browsing history
- `CallActivity` - Phone call logs (iOS only)
- `DeviceActivity` - Device metadata and usage
- `AdTrackingActivity` - Ad tracking transparency info

#### Services
- `LocationTrackingService` - CoreLocation wrapper with privacy controls
- `CalendarService` - EventKit integration
- `MediaTrackingService` - PhotoKit integration
- `URLTrackingService` - Browser history (via Safari extensions)
- `CallTrackingService` - CallKit integration (iOS)
- `DeviceInfoService` - System information collector
- `DataExportService` - JSON/CSV export
- `CloudSyncService` - CloudKit synchronization
- `PrivacyService` - Permission management and user controls

#### ViewModels
All ViewModels follow MVVM pattern:
- ObservableObject for state management
- Published properties for reactive updates
- Clear input/output separation
- Dependency injection for testability
- No direct UIKit/AppKit dependencies

## Development Guidelines

### Code Style

1. **Naming Conventions**
   - Clear, descriptive names over brevity
   - Use Swift naming conventions (lowerCamelCase, UpperCamelCase)
   - Protocol names should describe capability (`Trackable`, `Exportable`)
   - Avoid abbreviations unless universally understood

2. **Structure**
   - One type per file (with exceptions for small private types)
   - Group related functionality with `// MARK: -`
   - Extensions in separate files for organization
   - Maximum file length: ~400 lines (refactor if larger)

3. **Safety**
   - Prefer optionals over force unwrapping
   - Guard statements for early returns
   - Proper error handling (no swallowed errors)
   - Compile with warnings as errors

4. **SwiftUI Best Practices**
   - Small, composable views
   - Extract subviews when body gets complex (>3 levels)
   - Use `@StateObject`, `@ObservedObject`, `@EnvironmentObject` appropriately
   - Minimize state, derive when possible
   - Preview providers for all views

### Testing Strategy

1. **Unit Tests**
   - Test business logic thoroughly
   - Mock external dependencies (services, network)
   - Aim for 80%+ code coverage
   - Fast tests (< 0.1s per test)
   - Independent tests (no shared state)

2. **UI Tests**
   - Critical user flows only
   - Test accessibility identifiers
   - Keep tests maintainable
   - Use Page Object pattern

3. **Integration Tests**
   - Test service interactions
   - CoreData stack testing
   - CloudKit sync scenarios

### Git Workflow

1. **Commit Messages**
   - Format: `[Type] Brief description`
   - Types: Feature, Fix, Refactor, Test, Docs, Chore
   - Example: `[Feature] Add location tracking service`
   - Include why, not just what

2. **Branching**
   - `main` - Production ready
   - `claude/*` - Feature branches
   - Keep branches focused and short-lived

3. **Pull Requests**
   - Clear description of changes
   - Link to issues if applicable
   - All tests passing
   - SwiftLint passing
   - Screenshots for UI changes

### CI/CD Pipeline

GitHub Actions workflow includes:
- Build verification (iOS + macOS)
- Unit test execution
- SwiftLint validation
- SwiftFormat validation
- Code coverage reporting
- Build artifacts archiving

## Features Roadmap

### Phase 1: Foundation (Current)
- [x] Project setup
- [ ] Core data models
- [ ] Basic UI framework
- [ ] Location tracking
- [ ] Calendar integration
- [ ] Basic settings

### Phase 2: Rich Functionality
- [ ] Media tracking
- [ ] URL tracking
- [ ] Call logs (iOS)
- [ ] Device info
- [ ] Data export
- [ ] CloudKit sync

### Phase 3: Polish
- [ ] Widgets
- [ ] Shortcuts support
- [ ] Advanced privacy controls
- [ ] Data visualization
- [ ] Search and filtering
- [ ] Notifications

### Phase 4: Excellence
- [ ] watchOS companion
- [ ] visionOS support
- [ ] Machine learning insights
- [ ] Timeline visualization
- [ ] Advanced export formats
- [ ] Automation rules

## Privacy Manifest

All permission requests include clear, user-friendly explanations:

- **Location** - "Track your visited locations to build a personal map of your journeys"
- **Calendar** - "View and analyze your calendar events and time allocation"
- **Photos** - "Track your photo and video creation to understand your media habits"
- **Contacts** - "Analyze communication patterns (optional)"

## Accessibility Commitment

- Full VoiceOver support with meaningful labels
- Dynamic Type support in all views
- High contrast mode compatibility
- Keyboard navigation (macOS)
- Reduce Motion support
- Minimum touch targets: 44x44pt

## Performance Targets

- App launch: < 1 second
- View transitions: 60fps
- Background tracking: < 5% battery impact
- Memory usage: < 100MB baseline
- Database queries: < 100ms for common operations

## Security Checklist

- [ ] No hardcoded credentials
- [ ] Keychain for sensitive data
- [ ] Input validation on all user inputs
- [ ] Secure network communications (HTTPS only)
- [ ] Data encryption at rest
- [ ] Regular dependency updates
- [ ] OWASP Mobile Top 10 compliance

## Questions to Ask

Before implementing any feature:
1. Does this respect user privacy?
2. Is this the simplest solution that could work?
3. Is this accessible to all users?
4. Does this follow Apple's guidelines?
5. Can this be tested effectively?
6. Will this scale with data growth?
7. Is this secure by default?

## The Standard

We're not building just another app. We're crafting a tool that users will trust with their most personal data. Every decision should honor that trust.

**Code is read 10x more than it's written. Make it beautiful.**

---

*Last updated: 2025-11-16*
