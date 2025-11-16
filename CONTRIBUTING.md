# Contributing to Personal Tracker

Thank you for your interest in contributing to Personal Tracker! We welcome contributions from the community and are grateful for your support.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** if applicable
- **Environment details** (iOS version, device, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Rationale** for the enhancement
- **Use cases** and examples
- **Mockups or wireframes** if applicable

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding guidelines** (see below)
3. **Write clear commit messages** following our conventions
4. **Add tests** for new functionality
5. **Update documentation** as needed
6. **Ensure all tests pass** and there are no linting errors
7. **Submit your pull request**

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/personal-tracker.git
   cd personal-tracker
   ```

2. Open the project in Xcode:
   ```bash
   open PersonalTracker/PersonalTracker.xcodeproj
   ```

3. Install development tools:
   ```bash
   brew install swiftlint swiftformat
   ```

4. Read the project philosophy in [CLAUDE.md](CLAUDE.md)

## Coding Guidelines

### Swift Style Guide

We follow Apple's Swift API Design Guidelines with some additions:

- **Naming**: Use clear, descriptive names
- **Indentation**: 4 spaces, no tabs
- **Line Length**: Maximum 120 characters
- **Documentation**: Document all public APIs
- **SwiftLint**: All code must pass SwiftLint validation
- **SwiftFormat**: Use SwiftFormat for consistent formatting

### Code Quality Standards

- **No Force Unwrapping**: Avoid `!` except in tests
- **Proper Error Handling**: Use `do-catch` or `Result` types
- **No Print Statements**: Use the `AppLogger` for logging
- **Accessibility**: All UI must support VoiceOver
- **Testability**: Write testable code with dependency injection

### Testing Requirements

- **Unit Tests**: All business logic must have unit tests
- **Code Coverage**: Aim for 80%+ coverage
- **UI Tests**: Critical user flows need UI tests
- **Test Naming**: Use descriptive test names (`test_methodName_whenCondition_shouldExpectation`)

## Commit Message Format

```
[Type] Brief description (50 chars or less)

More detailed explanatory text, if necessary. Wrap it to about 72
characters. Explain the problem that this commit is solving, why
this approach was taken, and any relevant context.

- Bullet points are okay
- Use present tense ("Add feature" not "Added feature")
- Reference issues and pull requests

Closes #123
```

### Types

- **[Feature]** - New feature or functionality
- **[Fix]** - Bug fix
- **[Refactor]** - Code refactoring
- **[Test]** - Adding or updating tests
- **[Docs]** - Documentation changes
- **[Chore]** - Maintenance tasks
- **[Perf]** - Performance improvements
- **[Style]** - Code style/formatting changes

## Project Structure

```
PersonalTracker/
├── PersonalTracker/           # iOS App
├── PersonalTrackerMac/        # macOS App
├── PersonalTrackerShared/     # Shared code
│   ├── Models/               # Data models
│   ├── Services/             # Business logic
│   ├── ViewModels/           # MVVM view models
│   └── Utilities/            # Helper functions
├── PersonalTrackerTests/      # Unit tests
└── PersonalTrackerUITests/    # UI tests
```

## Architecture

We follow MVVM (Model-View-ViewModel) architecture:

- **Models**: Pure data structures, Codable, Hashable
- **Services**: Business logic, API calls, data persistence
- **ViewModels**: State management, view logic
- **Views**: SwiftUI views, minimal logic

## Privacy First

This app is privacy-focused. When contributing:

- **Never add analytics** without explicit user consent
- **Keep data local** by default
- **Encrypt sensitive data** at rest
- **Clear privacy descriptions** for all permissions
- **User control** over all data collection

## Documentation

- Document all public APIs with `///` comments
- Include examples for complex functionality
- Update README.md for user-facing changes
- Update CLAUDE.md for architecture changes

## Running Tests

```bash
# Run all tests
xcodebuild test -scheme PersonalTracker -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test
xcodebuild test -scheme PersonalTracker -destination 'platform=iOS Simulator,name=iPhone 15 Pro' -only-testing:PersonalTrackerTests/ServiceTests

# Run SwiftLint
swiftlint lint

# Run SwiftFormat
swiftformat --lint .
```

## Code Review Process

1. **Automated checks** must pass (CI/CD pipeline)
2. **At least one approving review** from a maintainer
3. **All conversations resolved**
4. **No merge conflicts**
5. **Up to date with main branch**

## Questions?

- Check the [README](README.md)
- Read the [CLAUDE.md](CLAUDE.md) for project philosophy
- Open a GitHub issue for questions
- Join our discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

Thank you for contributing to Personal Tracker! 🎉
