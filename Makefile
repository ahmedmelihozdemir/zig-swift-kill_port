# Port Kill Monitor - Makefile
# Simple commands for common tasks

.PHONY: install build run clean help setup dev

# Default target
help:
	@echo "🚀 Port Kill Monitor - Available Commands:"
	@echo ""
	@echo "  make install    - Full installation (recommended)"
	@echo "  make dev        - Quick development build and run"
	@echo "  make build      - Build both frontend and backend"
	@echo "  make run        - Run the application"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make setup      - Same as install"
	@echo ""
	@echo "📚 For more info, see: README.md or QUICKSTART.md"

# Full installation
install setup:
	@echo "🚀 Starting full installation..."
	./setup.sh

# Development mode - quick build and run
dev:
	@echo "🛠️ Starting development mode..."
	./launch.sh

# Build both components
build:
	@echo "🔨 Building Zig backend..."
	cd zig-backend && zig build
	@echo "🔨 Building Swift frontend..."
	cd swift-frontend && xcodebuild -project swift-kill_port.xcodeproj -scheme swift-frontend -configuration Debug build
	@echo "✅ Build complete!"

# Run the application (assumes it's built)
run:
	@echo "🚀 Launching Port Kill Monitor..."
	@APP_PATH=$$(find ~/Library/Developer/Xcode/DerivedData -name "swift-kill_port.app" -type d | head -1); \
	if [ -n "$$APP_PATH" ] && [ -d "$$APP_PATH" ]; then \
		open "$$APP_PATH"; \
		echo "✅ Application launched!"; \
	else \
		echo "❌ App not found. Run 'make build' first."; \
	fi

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf zig-backend/zig-out 2>/dev/null || true
	@rm -rf swift-frontend/build 2>/dev/null || true
	@rm -rf build 2>/dev/null || true
	@echo "✅ Clean complete!"

# Show project info
info:
	@echo "📊 Project Information:"
	@echo "  Name: Port Kill Monitor"
	@echo "  Backend: Zig $(shell zig version 2>/dev/null || echo 'not installed')"
	@echo "  Frontend: Swift/SwiftUI"
	@echo "  Platform: macOS"
	@echo "  Repository: https://github.com/ahmedmelihozdemir/zig-swift-kill_port"
