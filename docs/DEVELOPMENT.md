# Port Kill Monitor - Development Guide

This guide provides comprehensive instructions for setting up, building, and contributing to the Port Kill Monitor project.

## 🛠 Development Environment Setup

### Prerequisites

#### Required Software
- **macOS**: 11.0+ (Big Sur or later)
- **Xcode**: 14.0+ with Command Line Tools
- **Zig**: 0.15.0 or later
- **Git**: For version control

#### Installation Commands
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Zig using Homebrew
brew install zig

# Verify installations
xcode-build -version
zig version
git --version
```

### Project Setup

#### 1. Clone Repository
```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
```

#### 2. Project Structure Overview
```
zig-swift-kill_port/
├── swift-frontend/           # Swift/SwiftUI macOS application
│   ├── swift-frontend/       # Main app target
│   │   ├── Views/           # SwiftUI views
│   │   ├── ViewModels/      # MVVM view models
│   │   ├── Services/        # Business logic services
│   │   ├── Models/          # Data models
│   │   └── Managers/        # System integration
│   ├── swift-frontendTests/ # Unit tests
│   └── swift-frontend.xcodeproj/ # Xcode project
├── zig-backend/             # Zig system monitoring backend
│   ├── src/                # Source code
│   ├── lib/                # Library modules
│   ├── test/               # Test files
│   ├── examples/           # Usage examples
│   └── build.zig           # Build configuration
├── docs/                   # Documentation
├── scripts/                # Build and utility scripts
└── README.md               # Project overview
```

## 🔨 Building the Project

### Swift Frontend

#### Using Xcode (Recommended)
```bash
cd swift-frontend
open swift-frontend.xcodeproj
```

Then in Xcode:
1. Select the `swift-frontend` scheme
2. Choose your target (My Mac)
3. Press `⌘+B` to build or `⌘+R` to run

#### Using Command Line
```bash
cd swift-frontend

# Debug build
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Debug \
           build

# Release build
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Release \
           build

# Build and archive
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Release \
           archive \
           -archivePath ./build/swift-frontend.xcarchive
```

### Zig Backend

#### Development Build
```bash
cd zig-backend

# Debug build
zig build

# Release build with optimizations
zig build -Doptimize=ReleaseFast

# Build specific targets
zig build port-kill          # GUI version
zig build port-kill-console  # Console version
```

#### Available Build Targets
```bash
# List all available targets
zig build --help

# Main targets
zig build port-kill          # Main GUI application
zig build port-kill-console  # Console application
zig build test              # Run all tests
zig build test-port         # Test specific port monitoring
zig build install           # Install binaries to system
```

## 🧪 Testing

### Swift Frontend Tests

#### Unit Tests
```bash
cd swift-frontend

# Run all tests
xcodebuild test -project swift-frontend.xcodeproj \
                -scheme swift-frontend \
                -destination 'platform=macOS'

# Run specific test class
xcodebuild test -project swift-frontend.xcodeproj \
                -scheme swift-frontend \
                -destination 'platform=macOS' \
                -only-testing:swift-frontendTests/MenuBarViewModelTests
```

#### UI Tests
```bash
# Run UI tests
xcodebuild test -project swift-frontend.xcodeproj \
                -scheme swift-frontend \
                -destination 'platform=macOS' \
                -only-testing:swift-frontendUITests
```

### Zig Backend Tests

#### Unit Tests
```bash
cd zig-backend

# Run all tests
zig build test

# Run with verbose output
zig build test -- --verbose

# Run specific test
zig test src/lib/process_monitor.zig
```

#### Integration Tests
```bash
# Start test servers for integration testing
./scripts/test_ports.sh

# Run integration tests in another terminal
zig build test-port
```

### Manual Testing

#### Test Scenario Setup
```bash
# Terminal 1: Start test HTTP servers
cd zig-backend
./scripts/test_ports.sh

# Terminal 2: Run the application
cd swift-frontend
# Run from Xcode or use built binary

# Terminal 3: Monitor and verify
cd zig-backend
./zig-out/bin/port-kill-console --verbose
```

## 🐛 Debugging

### Swift Frontend Debugging

#### Xcode Debugger
1. Set breakpoints in Swift code
2. Run with `⌘+R` in debug configuration
3. Use LLDB console for runtime inspection

#### Console Logging
```swift
// Use os_log for structured logging
import os.log

let logger = Logger(subsystem: "com.yourname.portkill", category: "ViewModel")
logger.info("Process scan completed with \(processes.count) processes")
logger.error("Failed to kill process: \(error.localizedDescription)")
```

#### Performance Profiling
```bash
# Profile with Instruments
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Release \
           build
# Then open with Instruments
```

### Zig Backend Debugging

#### Debug Build with Symbols
```bash
# Build with debug symbols
zig build -Doptimize=Debug

# Run with debugger
lldb ./zig-out/bin/port-kill-console
(lldb) run --verbose
```

#### Memory Debugging
```bash
# Check for memory leaks
zig build -Doptimize=Debug -Dcheck-memory

# Run with AddressSanitizer
zig build -Doptimize=Debug -Dsanitize=address
```

#### Verbose Logging
```bash
# Enable verbose output
./zig-out/bin/port-kill-console --verbose

# Custom debug output
zig build -Ddebug-output=true
```

## 🔧 Development Workflow

### Git Workflow

#### Branch Strategy
```bash
# Main branches
main        # Stable release branch
develop     # Development integration branch

# Feature branches
feature/feature-name     # New features
bugfix/issue-description # Bug fixes
hotfix/critical-fix      # Critical fixes
```

#### Typical Workflow
```bash
# 1. Create feature branch
git checkout develop
git pull origin develop
git checkout -b feature/new-monitoring-mode

# 2. Make changes and test
# ... development work ...

# 3. Commit changes
git add .
git commit -m "feat: add new monitoring mode for custom ports"

# 4. Push and create PR
git push origin feature/new-monitoring-mode
# Create PR on GitHub: feature/new-monitoring-mode -> develop
```

#### Commit Message Convention
```bash
# Format: type(scope): description
feat(ui): add settings panel for port configuration
fix(backend): resolve memory leak in process scanner
docs(readme): update installation instructions
test(frontend): add unit tests for MenuBarViewModel
refactor(zig): optimize process monitoring algorithm
```

### Code Style Guidelines

#### Swift Code Style
```swift
// MARK: - Property Declarations
@Published private(set) var processes: [ProcessInfo] = []
@Published private(set) var isScanning: Bool = false

// MARK: - Public Methods
func refreshProcesses() async {
    isScanning = true
    defer { isScanning = false }
    
    do {
        let newProcesses = try await portKillService.scanPorts()
        await MainActor.run {
            self.processes = newProcesses
        }
    } catch {
        logger.error("Failed to refresh processes: \(error)")
    }
}

// MARK: - Private Methods
private func updateStatusInfo() {
    // Implementation
}
```

#### Zig Code Style
```zig
// Function naming: snake_case
pub fn scan_processes(allocator: std.mem.Allocator, config: MonitorConfig) ![]ProcessInfo {
    var processes = std.ArrayList(ProcessInfo).init(allocator);
    defer processes.deinit();
    
    // Implementation
    return processes.toOwnedSlice();
}

// Constants: SCREAMING_SNAKE_CASE
const MAX_PROCESS_COUNT = 1000;
const DEFAULT_SCAN_INTERVAL = 2000;

// Types: PascalCase
const ProcessMonitor = struct {
    allocator: std.mem.Allocator,
    config: MonitorConfig,
    
    pub fn init(allocator: std.mem.Allocator, config: MonitorConfig) ProcessMonitor {
        return ProcessMonitor{
            .allocator = allocator,
            .config = config,
        };
    }
};
```

## 📦 Building Releases

### Creating Release Builds

#### Swift Frontend Release
```bash
cd swift-frontend

# Create release archive
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Release \
           -archivePath ./build/PortKillMonitor.xcarchive \
           archive

# Export app bundle
xcodebuild -exportArchive \
           -archivePath ./build/PortKillMonitor.xcarchive \
           -exportPath ./build/Release \
           -exportOptionsPlist exportOptions.plist
```

#### Zig Backend Release
```bash
cd zig-backend

# Build optimized release
zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos,x86_64-macos

# Create distribution package
./scripts/package-release.sh
```

### Universal Binaries

#### Swift Universal Build
```bash
# Build for both architectures
xcodebuild -project swift-frontend.xcodeproj \
           -scheme swift-frontend \
           -configuration Release \
           -arch arm64 -arch x86_64 \
           build
```

#### Zig Universal Build
```bash
# Build for multiple targets
zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-macos

# Combine using lipo
lipo -create \
     zig-out/bin/port-kill-aarch64 \
     zig-out/bin/port-kill-x86_64 \
     -output zig-out/bin/port-kill-universal
```

## 🚀 Deployment and Distribution

### Local Installation
```bash
# Run the installer script
./install.sh

# Manual installation
cp -r build/Release/PortKillMonitor.app /Applications/
cp zig-backend/zig-out/bin/* /usr/local/bin/
```

### Code Signing
```bash
# Sign the application (requires Apple Developer account)
codesign --force --sign "Developer ID Application: Your Name" \
         --entitlements swift-frontend/swift-frontend/swift_frontend.entitlements \
         /path/to/PortKillMonitor.app

# Verify signature
codesign --verify --verbose /path/to/PortKillMonitor.app
```

### Creating Distribution Package
```bash
# Create DMG for distribution
hdiutil create -volname "Port Kill Monitor" \
               -srcfolder /path/to/PortKillMonitor.app \
               -ov -format UDZO \
               PortKillMonitor.dmg
```

## 🔍 Performance Optimization

### Profiling Tools

#### Swift Performance
```bash
# Profile memory usage
leaks -atExit -- /path/to/PortKillMonitor.app

# Profile with Instruments
open -a Instruments
# Select "Time Profiler" or "Allocations" template
```

#### Zig Performance
```bash
# Build with performance monitoring
zig build -Doptimize=ReleaseFast -Denable-profiling

# Profile with system tools
sample ./zig-out/bin/port-kill-console 10 -f profile.txt
```

### Optimization Guidelines

#### Swift Optimizations
- Use `@MainActor` for UI updates
- Implement proper async/await patterns
- Minimize retain cycles with weak references
- Use lazy initialization for expensive operations

#### Zig Optimizations
- Prefer stack allocation over heap allocation
- Use comptime for compile-time computations
- Implement efficient algorithms for process scanning
- Minimize system call overhead

## 🤝 Contributing Guidelines

### Before Contributing
1. Read the [Contributing Guidelines](../CONTRIBUTING.md)
2. Check existing [Issues](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/issues)
3. Discuss new features in [Discussions](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/discussions)

### Pull Request Process
1. Fork the repository
2. Create a feature branch from `develop`
3. Make your changes with tests
4. Ensure all tests pass
5. Update documentation if needed
6. Submit a pull request

### Code Review Checklist
- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes without justification
- [ ] Performance impact is considered

## 📚 Additional Resources

### Documentation
- [Architecture Guide](ARCHITECTURE.md)
- [User Guide](USER_GUIDE.md)
- [API Documentation](API.md) (coming soon)

### External Resources
- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Zig Language Reference](https://ziglang.org/documentation/master/)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

### Community
- [GitHub Issues](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/issues)
- [GitHub Discussions](https://github.com/ahmedmelihozdemir/zig-swift-kill_port/discussions)

---

Happy coding! 🚀 If you have any questions or need help, don't hesitate to open an issue or start a discussion.
