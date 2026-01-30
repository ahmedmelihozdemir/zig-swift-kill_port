# Quick Start Guide

Get Port Kill Monitor up and running in just a few minutes. This guide covers the fastest ways to install and start using the application.

## Installation Options

Choose the method that works best for you:

### Option 1: One-Command Installation

The fastest way to get started. This single command downloads, builds, and installs everything:

```bash
curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/setup.sh | bash
```

This approach is perfect if you want to get up and running immediately without any manual steps.

### Option 2: Clone and Install

If you prefer to review the code first or want to keep a local copy:

```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
./setup.sh
```

### Option 3: Development Mode

For developers who want to run the app without installing it to Applications:

```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
./launch.sh
```

This builds and launches the app directly from the project directory.

## What Happens During Installation

The setup script automates the entire installation process:

1. Checks your macOS version for compatibility
2. Verifies that Xcode Command Line Tools are installed
3. Installs Zig via Homebrew if it's not already present
4. Builds the high-performance Zig backend
5. Compiles the Swift frontend application
6. Integrates the backend with the frontend
7. Installs the complete app to your Applications folder
8. Sets up command-line tools for terminal use
9. Launches the application

The entire process typically takes 2-3 minutes, depending on your system and whether dependencies need to be installed.

## First Launch

After installation completes:

1. **Find the app:** Open your Applications folder (press ⌘+Space and type "Applications")
2. **Launch it:** Double-click "Port Kill Monitor" to start the app
3. **Locate the menu bar icon:** Look for a lightning bolt icon in the top-right area of your screen
4. **Open the panel:** Click the lightning bolt icon to view the monitoring interface
5. **Start managing ports:** You'll see all processes currently running on monitored ports
6. **Kill processes:** Click any process in the list to terminate it immediately

**Important:** Port Kill Monitor is a menu bar application. It won't appear in your Dock, so always look for the icon in your menu bar.

## Daily Usage

Once installed, here's how to use the app efficiently:

**Launching the app:**

- Use Spotlight: Press ⌘+Space, then type "Port Kill Monitor"
- Or find it in your Applications folder

**Accessing the interface:**

- Click the lightning bolt icon in your menu bar anytime
- The app runs quietly in the background until you need it

**Auto-start on login:**

- Go to System Settings → General → Login Items
- Add Port Kill Monitor to start automatically when you log in

**Remember:** The app lives in your menu bar, not your Dock. If you don't see it in the Dock, that's normal.

## Command-Line Tools

After installation, you can also use these terminal commands:

```bash
# Show all available options
port-kill --help

# Scan and display processes on monitored ports
port-kill --scan

# Kill a specific process by port number
port-kill --kill 3000

# Terminate all processes on monitored ports
port-kill --kill-all
```

These commands are useful for automation scripts or when you're already working in the terminal.

## Common Issues

**Permission denied when running setup:**

```bash
sudo xcode-select --install
```

**Homebrew not installed:**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**App won't open after installation:**

- Right-click the app in Applications and select "Open" (this bypasses macOS Gatekeeper on first launch)
- Check System Settings → Privacy & Security for any security blocks

**CLI commands not working:**
If the `port-kill` command isn't found, you may need to manually create the symlink:

```bash
sudo ln -s "/Applications/Port Kill Monitor.app/Contents/Resources/kill-port" /usr/local/bin/port-kill
```

## Next Steps

You're all set! The app is now monitoring your development ports and ready to help you manage processes.

For more detailed information about features, troubleshooting, and development, check the main [README.md](README.md) file.

## Questions or Issues?

If you encounter any problems or have questions:

- Check the [README.md](README.md) for detailed documentation
- Open an issue on the GitHub repository
- Review the troubleshooting section above
