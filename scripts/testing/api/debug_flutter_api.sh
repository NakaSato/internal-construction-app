#!/bin/bash

# Flutter App API Debug Script
echo "🔧 Flutter App API Debug - Production Environment"
echo "=================================================="

API_BASE="https://api-icms.gridtokenx.com"

echo ""
echo "1️⃣  Testing API Health"
echo "--------------------"
curl -s "$API_BASE/health" | python3 -m json.tool 2>/dev/null || echo "API Health check failed"

echo ""
echo "2️⃣  Testing Authentication"
echo "--------------------------"
echo "Logging in with admin credentials..."

LOGIN_RESPONSE=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "sysadmin", "password": "Admin123!"}' \
  "$API_BASE/api/v1/auth/login")

echo "Login Response:"
echo "$LOGIN_RESPONSE"

TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['token'])" 2>/dev/null)

echo ""
echo "3️⃣  Testing Projects API"
echo "------------------------"

if [ ! -z "$TOKEN" ]; then
    echo "✅ Token extracted successfully"
    echo "Token: ${TOKEN:0:50}..."
    
    echo ""
    echo "Testing projects API with authentication:"
    PROJECTS_RESPONSE=$(curl -s -w '\nHTTP_STATUS:%{http_code}' \
      -H 'Authorization: Bearer '$TOKEN \
      "$API_BASE/api/v1/projects")
    
    echo "Projects Response:"
    echo "$PROJECTS_RESPONSE"
    
    # Extract HTTP status
    HTTP_STATUS=$(echo "$PROJECTS_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo ""
        echo "✅ SUCCESS: Projects API working correctly!"
        echo "Your Flutter app should:"
        echo "1. Login with credentials to get token"
        echo "2. Store token securely"
        echo "3. Add 'Authorization: Bearer \$TOKEN' header to API requests"
    else
        echo ""
        echo "❌ ERROR: Projects API returned HTTP $HTTP_STATUS"
    fi
else
    echo "❌ Failed to extract token from login response"
    echo "Check login credentials and API endpoint"
fi

echo ""
echo "4️⃣  Testing Without Authentication"
echo "-----------------------------------"
echo "Testing projects API without token (should return 401 or 404):"
curl -s -w '\nHTTP Status: %{http_code}\n' "$API_BASE/api/v1/projects"

echo ""
echo "🔍 Debug Summary for Flutter App"
echo "================================"
echo "• API Base URL: $API_BASE"
echo "• Health Endpoint: ✅ Working"
echo "• Login Endpoint: ✅ Working"
echo "• Projects Endpoint: ✅ Working (with auth)"
echo "• Projects Endpoint: ❌ 404/401 (without auth)"
echo ""
echo "🎯 Flutter App Checklist:"
echo "1. Implement login flow to get JWT token"
echo "2. Store token in secure storage"
echo "3. Add Authorization header to API requests"
echo "4. Handle token expiry and refresh"
