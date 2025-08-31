# Contributing to Port Monitor

Thank you for your interest in contributing to Port Monitor! This document provides guidelines and instructions for contributing to this project.

## 🤝 How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue templates** provided
3. **Provide detailed information** about the problem
4. **Include system information** (macOS version, app version, etc.)

### Suggesting Features

We welcome feature suggestions! Please:

1. **Check if the feature already exists** or is planned
2. **Create a detailed feature request** using the template
3. **Explain the use case** and benefits
4. **Consider implementation complexity**

### Pull Requests

1. **Fork the repository** and create a feature branch
2. **Make your changes** following our coding standards
3. **Test thoroughly** on different macOS versions
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

## 🛠 Development Setup

### Prerequisites

- **macOS**: 11.0+ (Big Sur or later)
- **Xcode**: 13.0+ with command line tools
- **Zig**: 0.15+ for backend development
- **Git**: For version control

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
   cd zig-swift-kill_port
   ```

2. **Install dependencies**:
   ```bash
   # Install Zig (if not already installed)
   brew install zig
   
   # Verify Xcode installation
   xcode-select --install
   ```

3. **Build the project**:
   ```bash
   # Build backend
   cd zig-backend
   zig build
   
   # Build frontend
   cd ../swift-frontend
   xcodebuild -scheme swift-frontend -configuration Debug build
   ```

### Project Structure

```
├── swift-frontend/           # macOS SwiftUI application
│   ├── swift-frontend/
│   │   ├── Views/           # SwiftUI views
│   │   ├── ViewModels/      # MVVM view models
│   │   ├── Services/        # Business logic services
│   │   ├── Models/          # Data models
│   │   └── Managers/        # System managers
│   ├── swift-frontendTests/ # Unit tests
│   └── swift-frontendUITests/ # UI tests
├── zig-backend/             # Zig backend for system operations
│   ├── src/                # Source code
│   │   ├── main.zig        # Main entry point
│   │   ├── apps/           # Application modules
│   │   └── lib/            # Library modules
│   ├── test/               # Tests
│   └── examples/           # Usage examples
└── docs/                   # Documentation
```

## 📝 Coding Standards

### Swift Code Style

- **Follow Swift conventions**: Use standard Swift naming and formatting
- **Use SwiftUI best practices**: Prefer declarative code, use @State appropriately
- **Add documentation**: Document public APIs and complex logic
- **Handle errors gracefully**: Use proper error handling patterns

Example:
```swift
/// Manages the menu bar interface and user interactions
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var isScanning: Bool = false
    
    /// Refreshes the process list from the backend
    func refreshProcesses() {
        // Implementation
    }
}
```

### Zig Code Style

- **Follow Zig conventions**: Use snake_case for functions and variables
- **Keep functions small**: Break down complex operations
- **Handle errors**: Use Zig's error handling patterns
- **Document public functions**: Add doc comments for exported functions

Example:
```zig
/// Scans for processes using the specified ports
pub fn scanProcesses(allocator: std.mem.Allocator, ports: []const u16) ![]ProcessInfo {
    // Implementation
}
```

### General Guidelines

- **Write self-documenting code**: Use clear variable and function names
- **Keep commits atomic**: One logical change per commit
- **Write good commit messages**: Use conventional commit format
- **Add tests**: Include tests for new functionality

## 🧪 Testing

### Running Tests

```bash
# Swift tests
cd swift-frontend
xcodebuild test -scheme swift-frontend

# Zig tests
cd zig-backend
zig build test
```

### Writing Tests

- **Unit tests**: Test individual functions and classes
- **Integration tests**: Test component interactions
- **UI tests**: Test user interface workflows
- **Performance tests**: Ensure good performance characteristics

### Test Coverage

- Aim for **80%+ code coverage** on new code
- Test **edge cases** and error conditions
- Test on **multiple macOS versions** when possible

## 📚 Documentation

### Code Documentation

- **Swift**: Use standard Swift documentation comments (`///`)
- **Zig**: Use Zig documentation comments (`///`)
- **README files**: Keep project documentation up to date

### User Documentation

- **User Guide**: Update for new features
- **API Documentation**: Document public interfaces
- **Examples**: Provide usage examples

## 🎨 UI/UX Guidelines

### Design Principles

- **Minimalist**: Keep the interface clean and uncluttered
- **Intuitive**: Make functionality discoverable and easy to use
- **Consistent**: Follow macOS Human Interface Guidelines
- **Accessible**: Support accessibility features

### Visual Design

- **Colors**: Use system colors and semantic colors
- **Typography**: Follow macOS typography guidelines
- **Spacing**: Use consistent spacing throughout
- **Animations**: Keep animations smooth and purposeful

## 🔍 Code Review Process

### For Contributors

1. **Self-review** your changes before submitting
2. **Test thoroughly** on your local machine
3. **Check for conflicts** with the main branch
4. **Respond promptly** to review feedback

### For Reviewers

1. **Be constructive** and helpful in feedback
2. **Focus on code quality** and maintainability
3. **Check for security issues** and best practices
4. **Test the changes** when possible

## 🚀 Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **Major**: Breaking changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, backward compatible

### Release Checklist

- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Run full test suite
- [ ] Build and test on multiple macOS versions
- [ ] Create release notes
- [ ] Tag the release
- [ ] Update documentation

## 📞 Getting Help

### Community

- **GitHub Discussions**: For general questions and discussions
- **Issues**: For bug reports and feature requests
- **Pull Requests**: For code review and collaboration

### Maintainers

- **Ahmed Melih Özdemir** - [@ahmedmelihozdemir](https://github.com/ahmedmelihozdemir)

### Response Times

- **Issues**: We aim to respond within 48 hours
- **Pull Requests**: We aim to review within 1 week
- **Security Issues**: We aim to respond within 24 hours

## 🎯 Areas for Contribution

### High Priority

- **Performance optimizations**: Improve scanning speed and memory usage
- **Additional port support**: Add more common development ports
- **Settings persistence**: Better configuration management
- **Error handling**: More robust error recovery

### Medium Priority

- **Localization**: Support for multiple languages
- **Themes**: Dark/light theme improvements
- **Keyboard shortcuts**: More accessibility options
- **CLI improvements**: Enhanced command-line interface

### Low Priority

- **Advanced filtering**: Filter processes by type or user
- **Process details**: More detailed process information
- **Export functionality**: Export process lists
- **Integration**: Integrate with other development tools

## 📋 Commit Message Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: New features
- **fix**: Bug fixes
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```
feat(ui): add new minimalist design for process cards

- Implement modern gradient backgrounds
- Add smooth animations for state changes
- Improve accessibility with better contrast ratios

Closes #123
```

```
fix(backend): resolve memory leak in process scanner

The process scanner was not properly releasing memory after each scan,
causing the application to consume increasing amounts of RAM over time.

Fixes #456
```

## 🏆 Recognition

Contributors will be recognized in:

- **README.md**: Contributors section
- **Release notes**: Major contributions highlighted
- **GitHub**: Contributor graphs and statistics

Thank you for contributing to Port Monitor! 🚀
