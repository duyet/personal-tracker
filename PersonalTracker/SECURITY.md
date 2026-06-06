# Security Policy

## Our Commitment to Security

Personal Tracker is built with privacy and security as foundational principles. We take the security of our users' personal data seriously and are committed to maintaining the highest standards of security throughout the application.

## Privacy-First Architecture

### Data Storage
- **Local-First**: All data is stored locally on the user's device by default
- **Encryption at Rest**: Sensitive data is encrypted using iOS/macOS data protection APIs
- **No Third-Party Analytics**: We do not collect, transmit, or share user data with third parties
- **Optional CloudKit Sync**: When enabled, data is synced using Apple's end-to-end encrypted CloudKit

### Minimal Permissions
- We only request permissions that are essential for app functionality
- Each permission includes a clear explanation of why it's needed
- Users can selectively enable/disable tracking for different data types
- All permissions can be revoked at any time through system settings

## Supported Versions

We support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security Features

### Authentication
- **Biometric Authentication**: Optional Face ID/Touch ID protection for app access
- **Keychain Integration**: Secure storage of sensitive credentials using iOS/macOS Keychain
- **Session Management**: Automatic app locking after inactivity

### Data Protection
- **File Protection**: Complete file protection using `NSFileProtectionComplete`
- **Keychain Encryption**: All sensitive data stored in Keychain with appropriate access controls
- **Secure Coding Practices**: No force unwrapping, proper error handling, input validation

### Network Security
- **HTTPS Only**: All network communications use HTTPS
- **Certificate Pinning**: CloudKit connections use Apple's certificate pinning
- **No External Dependencies**: Minimal attack surface with no third-party SDKs

### Code Security
- **Memory Safety**: Swift's memory safety features prevent buffer overflows
- **Type Safety**: Strong typing prevents common vulnerabilities
- **Automatic Reference Counting**: No manual memory management reduces memory leaks
- **SwiftLint**: Strict linting rules enforce secure coding patterns

## Reporting a Vulnerability

We appreciate responsible disclosure of security vulnerabilities. If you discover a security issue, please follow these guidelines:

### DO NOT
- ❌ Create a public GitHub issue for security vulnerabilities
- ❌ Disclose the vulnerability publicly before it's been addressed
- ❌ Exploit the vulnerability beyond what's necessary to demonstrate it

### DO
- ✅ Email security details to: **security@personaltracker.app** (or create a private security advisory)
- ✅ Provide detailed steps to reproduce the vulnerability
- ✅ Include the affected version(s)
- ✅ Allow reasonable time for us to address the issue before public disclosure

### What to Include in Your Report

To help us address the issue quickly, please include:

1. **Description**: Clear description of the vulnerability
2. **Impact**: Potential impact and affected users
3. **Steps to Reproduce**: Detailed steps to reproduce the issue
4. **Proof of Concept**: Code or screenshots demonstrating the vulnerability
5. **Suggested Fix**: If you have ideas for how to fix it (optional)
6. **Your Contact Info**: So we can follow up with questions

### Our Response Process

1. **Acknowledgment**: We'll acknowledge receipt within 48 hours
2. **Investigation**: We'll investigate and confirm the vulnerability
3. **Fix Development**: We'll develop and test a fix
4. **Disclosure Timeline**: We'll coordinate with you on disclosure timing (typically 90 days)
5. **Credit**: We'll credit you in the release notes (if desired)

## Security Best Practices for Users

### Protect Your Device
- Use a strong device passcode
- Enable biometric authentication in Personal Tracker
- Keep iOS/macOS up to date with latest security patches
- Don't jailbreak or disable security features

### Data Management
- Regularly review which data types are being tracked
- Use the data export feature to create backups
- Enable CloudKit sync only on trusted iCloud accounts
- Review and revoke unnecessary permissions

### Privacy Controls
- Disable tracking for data types you don't need
- Set appropriate data retention periods
- Use the highest privacy level for sensitive activities
- Regularly audit your tracked data

## Compliance

### Apple Platform Guidelines
- **App Store Guidelines**: Full compliance with Apple's App Store Review Guidelines
- **Privacy Requirements**: Complies with Apple's App Tracking Transparency framework
- **Privacy Manifest**: Includes required Privacy Manifest for sensitive APIs
- **Data Collection Disclosure**: Transparent about all data collection

### Data Protection Regulations
- **GDPR Ready**: Right to access, right to erasure, data portability
- **CCPA Compliant**: California Consumer Privacy Act compliance
- **Data Minimization**: Only collect data necessary for functionality
- **User Consent**: Explicit consent for all data collection

## Security Audits

We conduct regular security audits:
- **Code Reviews**: All code changes undergo security-focused code review
- **Static Analysis**: SwiftLint enforces security best practices
- **Dependency Scanning**: Regular updates to system frameworks
- **Privacy Analysis**: Regular privacy impact assessments

## Third-Party Dependencies

Personal Tracker minimizes external dependencies:
- **Swift Package Manager**: Only official Apple frameworks
- **No Third-Party SDKs**: Zero external tracking or analytics
- **System Frameworks**: CloudKit, CoreLocation, EventKit, PhotoKit, CallKit

## Data Breach Response Plan

In the unlikely event of a data breach:

1. **Immediate Response** (within 24 hours)
   - Identify and contain the breach
   - Assess the scope and impact
   - Preserve evidence for investigation

2. **User Notification** (within 72 hours)
   - Notify affected users via in-app notification
   - Provide clear information about what data was affected
   - Offer guidance on protective actions

3. **Remediation**
   - Fix the vulnerability
   - Release emergency security update
   - Conduct post-mortem analysis

4. **Transparency**
   - Public disclosure of incident details
   - Lessons learned and improvements made
   - Updated security measures

## Security Update Policy

- **Critical Vulnerabilities**: Patched within 24-48 hours
- **High Severity**: Patched within 7 days
- **Medium Severity**: Patched within 30 days
- **Low Severity**: Included in next regular release

## Contact

For security-related questions or concerns:
- **Email**: security@personaltracker.app
- **GitHub Security Advisory**: Use GitHub's private security advisory feature
- **PGP Key**: Available upon request for encrypted communications

## Acknowledgments

We appreciate the security research community and will acknowledge responsible disclosure:
- Security researchers who report vulnerabilities responsibly
- Contributors who improve our security posture
- Users who provide feedback on security features

---

**Last Updated**: 2025-11-17
**Version**: 1.0.0

*This security policy is a living document and may be updated as we improve our security practices.*
