#!/bin/bash

# Solar Projects API - Targeted curl Commands
# Copy and paste these commands to test the API manually

echo "🔷 Solar Projects API - curl Test Commands"
echo "=================================================="
echo

API_BASE="https://solar-projects-api.azurewebsites.net"

echo "1️⃣  API Health Check"
echo "curl -s '$API_BASE/health' | python3 -m json.tool"
echo

echo "2️⃣  Test Authentication (Login)"
echo "curl -X POST \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"username\": \"admin@example.com\", \"password\": \"admin123\"}' \\"
echo "  '$API_BASE/api/v1/auth/login' | python3 -m json.tool"
echo

echo "3️⃣  Get Projects (requires authentication)"
echo "# First login to get token, then:"
echo "curl -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \\"
echo "  '$API_BASE/api/v1/projects' | python3 -m json.tool"
echo

echo "4️⃣  Get Projects with Pagination"
echo "curl -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \\"
echo "  '$API_BASE/api/v1/projects?pageNumber=1&pageSize=5' | python3 -m json.tool"
echo

echo "5️⃣  Get Single Project by ID"
echo "curl -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \\"
echo "  '$API_BASE/api/v1/projects/1' | python3 -m json.tool"
echo

echo "6️⃣  Test Projects Endpoint Without Auth (to see error)"
echo "curl -s -w '\\nHTTP Status: %{http_code}\\n' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  '$API_BASE/api/v1/projects'"
echo

echo "🔧 Quick Test Commands:"
echo "=================================================="

echo
echo "📋 Test API Health:"
curl -s "$API_BASE/health" | python3 -m json.tool 2>/dev/null || curl -s "$API_BASE/health"

echo
echo "🔐 Test Authentication (with test credentials):"
AUTH_RESULT=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "test@example.com", "password": "test123"}' \
  "$API_BASE/api/v1/auth/login")

echo "$AUTH_RESULT" | python3 -m json.tool 2>/dev/null || echo "$AUTH_RESULT"

echo
echo "🚫 Test Projects Without Auth (expect 401):"
curl -s -w "\nHTTP Status: %{http_code}\n" \
  -H 'Content-Type: application/json' \
  "$API_BASE/api/v1/projects"

echo
echo "📊 Available Endpoints Based on Flutter Code:"
echo "  GET  /health"
echo "  POST /api/v1/auth/login"
echo "  POST /api/v1/auth/register"  
echo "  GET  /api/v1/projects"
echo "  GET  /api/v1/projects/{id}"
echo "  GET  /api/v1/projects?pageNumber=1&pageSize=10"
echo "  GET  /api/v1/projects?status=Active"

echo
echo "💡 To get a valid token:"
echo "1. Use valid credentials in the login endpoint"
echo "2. Extract the 'token' field from the response"
echo "3. Use it in the Authorization header: 'Bearer <token>'"

echo
echo "🔍 To debug further:"
echo "• Check Flutter app logs for actual working credentials"
echo "• Look at network requests in Flutter DevTools"
echo "• Contact API maintainer for test credentials"
