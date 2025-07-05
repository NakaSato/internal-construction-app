#!/bin/bash

# =============================================================================
# SignalR Authentication Test Script
# Tests the SignalR endpoint with proper JWT authentication
# =============================================================================

echo "🔌 Testing SignalR Authentication..."
echo "===================================="

# First, let's get a JWT token by logging in
echo "📡 Step 1: Getting JWT token via login..."

# Try multiple credential combinations
echo "   Trying admin@example.com..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin@example.com",
    "password": "Admin123!"
  }')

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "   Trying admin with different password..."
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5001/api/v1/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "username": "admin",
        "password": "Admin123!"
      }')
    
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
    echo "   Trying admin@example.com with admin123..."
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5001/api/v1/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "username": "admin@example.com",
        "password": "admin123"
      }')
    
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
    echo "   Trying testuser@example.com..."
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5001/api/v1/auth/login \
      -H "Content-Type: application/json" \
      -d '{
        "username": "testuser@example.com",
        "password": "Test123!"
      }')
    
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to get JWT token. Login response:"
    echo "$LOGIN_RESPONSE"
    echo ""
    echo "💡 Make sure the backend is running and the login credentials are correct"
    exit 1
fi

echo "✅ Successfully obtained JWT token"
echo "   Token: ${TOKEN:0:50}..."

# Test the SignalR endpoint with authentication
echo ""
echo "📡 Step 2: Testing SignalR endpoint with authentication..."

if command -v wscat &> /dev/null; then
    echo "   Attempting to connect to ws://localhost:5001/notificationHub?token=$TOKEN"
    
    # Try to connect with the token
    timeout 10s wscat -c "ws://localhost:5001/notificationHub?token=$TOKEN" --wait 5 2>&1 | head -10
    
    if [ $? -eq 0 ]; then
        echo "✅ SignalR connection with authentication successful!"
    else
        echo "❌ SignalR connection failed even with authentication"
        echo "   This may indicate a backend configuration issue"
    fi
else
    echo "⚠️  wscat not available. Testing HTTP upgrade headers instead..."
    
    # Test HTTP upgrade request with authentication
    curl -s -v -H "Connection: Upgrade" \
         -H "Upgrade: websocket" \
         -H "Authorization: Bearer $TOKEN" \
         "http://localhost:5001/notificationHub" 2>&1 | grep -E "(HTTP/|upgrade|connection)"
fi

echo ""
echo "📡 Step 3: Testing SignalR-specific endpoints..."

# Test negotiate endpoint (common in SignalR)
echo "   Testing negotiate endpoint..."
NEGOTIATE_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/notificationHub/negotiate" 2>/dev/null)

if echo "$NEGOTIATE_RESPONSE" | grep -q "connectionToken\|connectionId"; then
    echo "✅ SignalR negotiate endpoint working"
else
    echo "❌ SignalR negotiate endpoint not found or not working"
fi

# Test SignalR info endpoint
echo "   Testing info endpoint..."
curl -s -H "Authorization: Bearer $TOKEN" \
  "http://localhost:5001/notificationHub/info" | head -3

echo ""
echo "💡 Recommendations:"
echo "   1. Ensure the backend implements SignalR hubs correctly"
echo "   2. Verify the /notificationHub endpoint is configured"
echo "   3. Check that JWT authentication is properly configured for SignalR"
echo "   4. Consider testing with the SignalR client library instead of raw WebSocket"
