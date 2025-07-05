#!/bin/bash

# =============================================================================
# SignalR Connection Diagnostic Script
# =============================================================================

echo "🔍 Testing SignalR Connection to localhost:5001"
echo "=================================================="

# Test 1: Basic HTTP connectivity
echo "📡 Test 1: Basic HTTP connectivity"
curl -f -s -o /dev/null -w "%{http_code}" http://localhost:5001/ && echo " ✅ HTTP connection successful" || echo " ❌ HTTP connection failed"

# Test 2: API health check
echo "📡 Test 2: API health check"
curl -f -s -o /dev/null -w "%{http_code}" http://localhost:5001/health && echo " ✅ API health check successful" || echo " ❌ API health check failed"

# Test 3: SignalR negotiate endpoint
echo "📡 Test 3: SignalR negotiate endpoint"
curl -f -s -o /dev/null -w "%{http_code}" http://localhost:5001/notificationHub/negotiate && echo " ✅ SignalR negotiate successful" || echo " ❌ SignalR negotiate failed"

# Test 4: Check if WebSocket upgrade headers are supported
echo "📡 Test 4: WebSocket upgrade test"
curl -s -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" http://localhost:5001/notificationHub

echo ""
echo "🔍 If any tests fail, the backend SignalR configuration may need adjustment"
echo "💡 Common issues:"
echo "   - CORS policy not allowing WebSocket connections"
echo "   - SignalR not properly configured in the backend"
echo "   - Backend server not running on localhost:5001"
echo ""
