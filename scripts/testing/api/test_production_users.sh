#!/bin/bash

# Production API User Testing Script
# Tests all registered users and their access levels

API_BASE="https://api-icms.gridtokenx.com"

echo "🔷 Production API User Testing"
echo "=============================="
echo "API: $API_BASE"
echo

# Test Admin Login
echo "1️⃣  Testing Admin Login (sysadmin)"
echo "-----------------------------------"
ADMIN_RESPONSE=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "sysadmin", "password": "Admin123!"}' \
  "$API_BASE/api/v1/auth/login")

ADMIN_TOKEN=$(echo "$ADMIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['token'])" 2>/dev/null)

if [ ! -z "$ADMIN_TOKEN" ]; then
    echo "✅ Admin login successful"
    echo "Token: ${ADMIN_TOKEN:0:50}..."
else
    echo "❌ Admin login failed"
    echo "$ADMIN_RESPONSE"
fi

echo

# Test Manager Login  
echo "2️⃣  Testing Manager Login (projectmanager)"
echo "-------------------------------------------"
MANAGER_RESPONSE=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "projectmanager", "password": "Manager123!"}' \
  "$API_BASE/api/v1/auth/login")

MANAGER_TOKEN=$(echo "$MANAGER_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['token'])" 2>/dev/null)

if [ ! -z "$MANAGER_TOKEN" ]; then
    echo "✅ Manager login successful"
    echo "Token: ${MANAGER_TOKEN:0:50}..."
else
    echo "❌ Manager login failed"
    echo "$MANAGER_RESPONSE"
fi

echo

# Test User Login
echo "3️⃣  Testing User Login (testuser123)"
echo "------------------------------------"
USER_RESPONSE=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "testuser123", "password": "Password123!"}' \
  "$API_BASE/api/v1/auth/login")

USER_TOKEN=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['token'])" 2>/dev/null)

if [ ! -z "$USER_TOKEN" ]; then
    echo "✅ User login successful"
    echo "Token: ${USER_TOKEN:0:50}..."
else
    echo "❌ User login failed"
    echo "$USER_RESPONSE"
fi

echo

# Test API Access with Admin Token
if [ ! -z "$ADMIN_TOKEN" ]; then
    echo "4️⃣  Testing API Access (Admin)"
    echo "------------------------------"
    curl -s -H "Authorization: Bearer $ADMIN_TOKEN" \
         "$API_BASE/api/v1/projects" | python3 -m json.tool | head -20
fi

echo
echo "🎯 Quick Login Commands:"
echo "========================"
echo "Admin:   curl -X POST -H 'Content-Type: application/json' -d '{\"username\":\"sysadmin\",\"password\":\"Admin123!\"}' '$API_BASE/api/v1/auth/login'"
echo "Manager: curl -X POST -H 'Content-Type: application/json' -d '{\"username\":\"projectmanager\",\"password\":\"Manager123!\"}' '$API_BASE/api/v1/auth/login'"
echo "User:    curl -X POST -H 'Content-Type: application/json' -d '{\"username\":\"testuser123\",\"password\":\"Password123!\"}' '$API_BASE/api/v1/auth/login'"
