# 🚀 Quick Start Guide

Get Port Kill Monitor running in **under 2 minutes**!

## Super Quick Installation

### Option 1: One Command Installation ⚡
```bash
curl -fsSL https://raw.githubusercontent.com/ahmedmelihozdemir/zig-swift-kill_port/main/setup.sh | bash
```

### Option 2: Git Clone Method 📦
```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
./setup.sh
```

### Option 3: Development Mode 🛠️
```bash
git clone https://github.com/ahmedmelihozdemir/zig-swift-kill_port.git
cd zig-swift-kill_port
./launch.sh
```

## What Happens During Installation?

✅ **Checks macOS compatibility**  
✅ **Installs Zig (via Homebrew if needed)**  
✅ **Builds high-performance backend**  
✅ **Builds beautiful Swift frontend**  
✅ **Installs to Applications folder**  
✅ **Sets up CLI tools**  
✅ **Launches the app**  

## First Use

1. Look for **⚡** icon in your menu bar
2. Click to open the monitoring panel
3. See all processes running on development ports
4. Click any process to kill it instantly!

## CLI Commands

After installation, use these commands:

```bash
port-kill --scan          # Show all monitored processes
port-kill --kill 3000     # Kill process on port 3000  
port-kill --kill-all      # Kill all monitored processes
port-kill --help          # Show all options
```

## Troubleshooting

**Permission denied?**
```bash
sudo xcode-select --install
```

**Homebrew not found?**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**App not launching?**
- Right-click app → "Open" (bypasses Gatekeeper)
- Check System Settings → Privacy & Security

## That's it! 🎉

You now have a beautiful port monitoring app in your menu bar.

**Questions?** Check the main [README.md](README.md) for detailed documentation.
