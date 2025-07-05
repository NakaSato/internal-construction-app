#!/bin/bash

# =============================================================================
# WebSocket Connection Test Script
# Tests if the WebSocket server is properly configured and running
# =============================================================================

echo "🔌 Testing WebSocket Connection..."
echo "=================================="

# Check if the HTTP server is running first
echo "📡 Testing HTTP connection to localhost:5001..."
if curl -s --connect-timeout 5 http://localhost:5001/api/health > /dev/null 2>&1; then
    echo "✅ HTTP server is running on localhost:5001"
else
    echo "❌ HTTP server is not responding on localhost:5001"
    echo "   Make sure your backend server is running!"
    exit 1
fi

# Check if wscat is available for WebSocket testing
if command -v wscat &> /dev/null; then
    echo "📡 Testing WebSocket connection with wscat..."
    echo "   Attempting to connect to ws://localhost:5001/ws"
    
    # Try to connect with a timeout
    timeout 10s wscat -c ws://localhost:5001/ws --wait 5 2>&1 | head -10
    
    if [ $? -eq 0 ]; then
        echo "✅ WebSocket connection successful!"
    else
        echo "❌ WebSocket connection failed!"
        echo "   This indicates the backend may not support WebSocket upgrades at /ws"
    fi
else
    echo "⚠️  wscat not found. Installing globally..."
    echo "   Run: npm install -g wscat"
    echo "   Then rerun this script"
fi

echo ""
echo "🔍 Checking common WebSocket issues:"
echo "   1. Is the backend server running?"
echo "   2. Does the backend support WebSocket upgrades?"
echo "   3. Is the WebSocket endpoint /ws correct?"
echo "   4. Are there any firewalls or proxies blocking WebSocket upgrades?"

# Test alternative WebSocket paths
echo ""
echo "📡 Testing alternative WebSocket paths..."

for path in "/websocket" "/socket.io" "/signalr/negotiate" "/hub" ""; do
    url="ws://localhost:5001${path}"
    echo "   Testing: $url"
    
    if command -v wscat &> /dev/null; then
        timeout 3s wscat -c "$url" --wait 2 2>&1 | grep -q "connected" && echo "     ✅ Connected!" || echo "     ❌ Failed"
    else
        # Use curl to test HTTP upgrade capability
        response=$(curl -s -w "%{http_code}" -H "Connection: Upgrade" -H "Upgrade: websocket" "http://localhost:5001${path}" 2>/dev/null | tail -1)
        if [ "$response" = "101" ]; then
            echo "     ✅ WebSocket upgrade supported!"
        elif [ "$response" = "200" ] || [ "$response" = "404" ]; then
            echo "     ⚠️  HTTP response ($response) - may not support WebSocket"
        else
            echo "     ❌ Failed (HTTP $response)"
        fi
    fi
done

echo ""
echo "💡 Recommendations:"
echo "   1. Verify your backend implements WebSocket support"
echo "   2. Check if you're using SignalR, Socket.IO, or raw WebSockets"
echo "   3. Ensure the WebSocket endpoint matches your backend configuration"
echo "   4. Test with a WebSocket client like Postman or wscat"
