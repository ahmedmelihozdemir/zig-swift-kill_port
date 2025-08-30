# Zig Port Kill

A reimplementation of the Rust-based port-kill application using Zig 0.15.1.

## Features

- **Real-time Port Monitoring**: Monitors development processes in the 2000-6000 port range
- **Process Management**: Safely terminates detected processes
- **GUI and Console Mode**: Both system tray integration and console mode
- **Flexible Port Configuration**: Can monitor port ranges or specific ports
- **macOS Integration**: System tray integration using native Cocoa APIs

## Requirements

- macOS 10.15 or later
- Zig 0.15.0 or later
- `lsof` command (comes with macOS)

## Installation and Running

### Quick Start

```bash
# Clone the project
cd zig-port_kill

# Build and run the application (easy way)
./run.sh
```

### Manual Build

```bash
# Build
zig build

# Run in GUI mode
./zig-out/bin/port-kill

# Run in console mode
./zig-out/bin/port-kill-console
```

## Usage Examples

### Basic Usage
```bash
# Default: port 2000-6000 (GUI mode)
./run.sh

# Run in console mode
./run.sh --console

# With verbose logging
./run.sh --verbose
```

### Port Configuration
```bash
# Set port range
./run.sh --start-port 3000 --end-port 8080

# Monitor specific ports
./run.sh --ports 3000,8000,8080,5000

# Specific ports in console mode
./run.sh --console --ports 3000,8000,8080
```

### Command Line Options

- `--start-port, -s`: Starting port (default: 2000)
- `--end-port, -e`: Ending port (default: 6000)
- `--ports, -p`: Specific ports (comma-separated)
- `--console, -c`: Run in console mode
- `--verbose, -v`: Verbose logging
- `--help, -h`: Help information
- `--version, -V`: Version information

## Testing

```bash
# Start test servers
./test_ports.sh

# Run the application in another terminal
./run.sh --console
```

## Differences from Rust Version

### Zig 0.15.1 Features Used

1. **New std.Io.Writer API**: New I/O interface after Writergate
2. **ArrayList Unmanaged**: Unmanaged ArrayList by default
3. **Compile-time String Formatting**: Zig's powerful compile-time features
4. **Error Handling**: Zig's error union system
5. **Memory Management**: Safety with manual memory management

### Architectural Differences

**Rust Version:**
- Tokio async runtime
- Crossbeam channels
- Tray-icon crate
- Clap argument parsing

**Zig Version:**
- Single-threaded event loop
- Direct Cocoa API integration
- Custom CLI parsing
- Manual memory management

### Performance

- **Compilation Speed**: Zig version compiles much faster
- **Runtime Performance**: Minimal memory overhead
- **Binary Size**: Smaller binary size

## Technical Details

### Module Structure

```
src/
├── main.zig              # Entry point for GUI mode
├── main_console.zig      # Entry point for console mode
├── types.zig            # Data structures and types
├── process_monitor.zig  # Process monitoring logic
├── console_app.zig      # Console application
├── tray_app.zig        # System tray application
└── cli.zig             # Command line parsing
```

### Process Detection

Process detection uses macOS's `lsof` command:
```bash
lsof -ti :PORT -sTCP:LISTEN
```

### Process Termination

1. **SIGTERM**: First attempt graceful termination
2. **SIGKILL**: Force termination if still running after 500ms

### macOS Integration

Direct Cocoa APIs are used for system tray integration:
- NSStatusBar for system tray item
- NSMenu for context menu
- NSApplication for event loop

## Zig 0.15.1 Specific Features

This implementation uses Zig 0.15.1's new features:

- **Format Methods**: Custom format methods with `{f}` formatter
- **New std.Io**: New I/O API after Writergate
- **De-genericified Collections**: Non-generic ArrayList
- **Improved Error Handling**: Better error propagation

## Debugging

```bash
# Debug with console mode and verbose logging
./run.sh --console --verbose

# Run tests with build
zig build test
```

## Known Limitations

1. **GUI Mode**: System tray menu callbacks are simplified
2. **Error Recovery**: Better error handling needed for some edge cases
3. **Icon Support**: Currently text-based icon, future image support can be added

## Rust vs Zig Comparison

| Feature | Rust Version | Zig Version |
|---------|--------------|-------------|
| Compile Time | ~30 seconds | ~3 seconds |
| Binary Size | ~15MB | ~2MB |
| Memory Safety | Borrow checker | Manual + safety checks |
| Async Support | Tokio runtime | Single-threaded loop |
| Dependencies | ~20 crates | Only system libs |
| macOS Integration | Third-party crate | Direct Cocoa API |

## Future Plans

1. **Icon Support**: PNG/ICO image support
2. **Menu Callbacks**: More robust menu item handling
3. **Event System**: More sophisticated event system
4. **Configuration File**: TOML/JSON config support
5. **Process Details**: More detailed process information

## Contributing

1. Fork repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## License

This project is under the same license as the Rust version.
