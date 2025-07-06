#!/bin/bash

# Test 401 Handling in Flutter App
# This script tests that the API returns 401 for invalid tokens

echo "🔐 Testing 401 Unauthorized Handling"
echo "===================================="
echo

# Test 1: Valid login to get a token format
echo "1️⃣  Getting valid token format..."
echo "--------------------------------"
VALID_RESPONSE=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "sysadmin", "password": "Admin123!"}' \
  'https://api-icms.gridtokenx.com/api/v1/auth/login')

echo "Valid login response:"
echo "$VALID_RESPONSE" | python3 -m json.tool
echo

# Test 2: Try with invalid token
echo "2️⃣  Testing with invalid token..."
echo "--------------------------------"
INVALID_TOKEN="invalid.token.here"

echo "Testing projects API with invalid token:"
RESPONSE_CODE=$(curl -s -w "%{http_code}" -o /tmp/401_test_response.json \
  -H "Authorization: Bearer $INVALID_TOKEN" \
  'https://api-icms.gridtokenx.com/api/v1/projects')

echo "HTTP Response Code: $RESPONSE_CODE"
echo "Response Body:"
cat /tmp/401_test_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/401_test_response.json
echo

# Test 3: Try with expired token (using old token format)
echo "3️⃣  Testing with expired token..."
echo "--------------------------------"
EXPIRED_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

echo "Testing with expired token:"
RESPONSE_CODE2=$(curl -s -w "%{http_code}" -o /tmp/401_test_response2.json \
  -H "Authorization: Bearer $EXPIRED_TOKEN" \
  'https://api-icms.gridtokenx.com/api/v1/projects')

echo "HTTP Response Code: $RESPONSE_CODE2"
echo "Response Body:"
cat /tmp/401_test_response2.json | python3 -m json.tool 2>/dev/null || cat /tmp/401_test_response2.json
echo

# Test 4: No token at all
echo "4️⃣  Testing with no token..."
echo "----------------------------"
echo "Testing without any authorization header:"
RESPONSE_CODE3=$(curl -s -w "%{http_code}" -o /tmp/401_test_response3.json \
  'https://api-icms.gridtokenx.com/api/v1/projects')

echo "HTTP Response Code: $RESPONSE_CODE3"
echo "Response Body:"
cat /tmp/401_test_response3.json | python3 -m json.tool 2>/dev/null || cat /tmp/401_test_response3.json
echo

# Summary
echo "📊 Test Summary:"
echo "================"
if [ "$RESPONSE_CODE" = "401" ] || [ "$RESPONSE_CODE2" = "401" ] || [ "$RESPONSE_CODE3" = "401" ]; then
    echo "✅ API correctly returns 401 for unauthorized requests"
    echo "🔥 Your Flutter app should trigger the AuthInterceptor"
    echo "   and automatically log out users with invalid tokens"
else
    echo "⚠️  API responses: $RESPONSE_CODE, $RESPONSE_CODE2, $RESPONSE_CODE3"
    echo "   Check if 401 responses are properly configured"
fi

echo
echo "🚀 Next Steps:"
echo "=============="
echo "1. Run your Flutter app"
echo "2. Login with valid credentials"
echo "3. Manually corrupt the stored token to simulate expiration"
echo "4. Make an API call (navigate in the app)"
echo "5. Verify the app automatically logs out and shows snackbar"

# Cleanup
rm -f /tmp/401_test_response*.json
