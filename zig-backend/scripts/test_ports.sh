#!/bin/bash

# Test script for Zig port-kill application
# This script starts some test servers on ports within the 2000-6000 range

echo "🧪 Starting test servers for Zig port-kill application..."

# Start a simple HTTP server on port 3000
python3 -m http.server 3000 &
echo "✅ Started HTTP server on port 3000 (PID: $!)"

# Start another server on port 4000
python3 -m http.server 4000 &
echo "✅ Started HTTP server on port 4000 (PID: $!)"

# Start a server on port 5000
python3 -m http.server 5000 &
echo "✅ Started HTTP server on port 5000 (PID: $!)"

# Start a Node.js server on port 3001 (if node is available)
if command -v node &> /dev/null; then
    node -e "const http = require('http'); const server = http.createServer((req, res) => { res.writeHead(200); res.end('Node.js server running'); }); server.listen(3001, () => console.log('Node.js server on port 3001'));" &
    echo "✅ Started Node.js server on port 3001 (PID: $!)"
fi

echo ""
echo "🎯 Test servers started. You can now run the Zig port-kill application:"
echo "   ./run.sh                    # GUI mode"
echo "   ./run.sh --console          # Console mode"
echo "   ./run.sh --verbose          # With verbose logging"
echo ""
echo "🛑 To stop the test servers, run: pkill -f 'python3 -m http.server'"
