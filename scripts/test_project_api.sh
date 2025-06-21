#!/bin/bash

# Solar Projects API Testing Script
# This script tests the project management API endpoints

# Configuration
API_BASE_URL="https://solar-projects-api.azurewebsites.net"
CONTENT_TYPE="Content-Type: application/json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Solar Projects API Test Suite ===${NC}"
echo "Base URL: $API_BASE_URL"
echo ""

# Function to print test headers
print_test() {
    echo -e "${YELLOW}📋 $1${NC}"
    echo "----------------------------------------"
}

# Function to print results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        echo -e "${RED}❌ Failed (Exit code: $1)${NC}"
    fi
    echo ""
}

# Test 1: Health Check / API Status
print_test "Test 1: API Health Check"
curl -s -w "HTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/health" || \
curl -s -w "HTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/"
print_result $?

# Test 2: Get All Projects (without authentication)
print_test "Test 2: Get All Projects (No Auth)"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api/v1/projects" | jq '.' 2>/dev/null || echo "Response received (jq not available for formatting)"
print_result $?

# Test 3: Get Projects with Pagination
print_test "Test 3: Get Projects with Pagination"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api/v1/projects?pageNumber=1&pageSize=5" | jq '.' 2>/dev/null || echo "Response received"
print_result $?

# Test 4: Get Projects with Filtering
print_test "Test 4: Get Projects with Status Filter"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api/v1/projects?status=Active" | jq '.' 2>/dev/null || echo "Response received"
print_result $?

# Test 5: Get Single Project (try common ID)
print_test "Test 5: Get Single Project by ID"
echo "Trying project ID: 1"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api/v1/projects/1" | jq '.' 2>/dev/null || echo "Response received"
print_result $?

# Test 6: Authentication Endpoint Test
print_test "Test 6: Authentication Endpoint"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -X POST \
    -H "$CONTENT_TYPE" \
    -d '{
        "username": "test@example.com",
        "password": "testpassword"
    }' \
    "$API_BASE_URL/api/v1/auth/login" | jq '.' 2>/dev/null || echo "Response received"
print_result $?

# Test 7: Test with Authentication (if we get a token)
print_test "Test 7: Test Authentication Flow and Protected Endpoint"
echo "Step 1: Login attempt..."
AUTH_RESPONSE=$(curl -s -X POST \
    -H "$CONTENT_TYPE" \
    -d '{
        "username": "admin@example.com",
        "password": "admin123"
    }' \
    "$API_BASE_URL/api/v1/auth/login")

echo "Auth response: $AUTH_RESPONSE"

# Extract token if available (assuming JSON response with token field)
TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.data.token // .token // empty' 2>/dev/null)

if [ ! -z "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo "Token obtained: ${TOKEN:0:20}..."
    echo "Step 2: Testing authenticated projects endpoint..."
    curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
        -H "$CONTENT_TYPE" \
        -H "Authorization: Bearer $TOKEN" \
        "$API_BASE_URL/api/v1/projects" | jq '.' 2>/dev/null || echo "Response received"
else
    echo "No token obtained - testing without authentication"
    curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
        -H "$CONTENT_TYPE" \
        "$API_BASE_URL/api/v1/projects"
fi
print_result $?

# Test 8: API Documentation/Swagger
print_test "Test 8: API Documentation"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    "$API_BASE_URL/swagger" || \
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    "$API_BASE_URL/api/docs"
print_result $?

# Test 9: CORS Preflight
print_test "Test 9: CORS Preflight Check"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -X OPTIONS \
    -H "Origin: http://localhost:3000" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: Content-Type,Authorization" \
    "$API_BASE_URL/api/v1/projects"
print_result $?

# Test 10: API Version Check
print_test "Test 10: API Version/Info"
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api/v1" || \
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api/version" || \
curl -s -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
    -H "$CONTENT_TYPE" \
    "$API_BASE_URL/api"
print_result $?

echo -e "${BLUE}=== Test Suite Complete ===${NC}"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "• Install jq for better JSON formatting: brew install jq"
echo "• Check API documentation at: $API_BASE_URL/swagger"
echo "• Monitor network requests in Flutter app for actual working endpoints"
echo "• Use Flutter logs to see what requests are being made"
echo ""
echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
echo "• HTTP 401: Authentication required"
echo "• HTTP 404: Endpoint not found"
echo "• HTTP 500: Server error"
echo "• Connection errors: Check URL and network"
