#!/bin/bash

# Test script for project detail fallback mechanism
# This script tests both the failing detail endpoint and the working list endpoint

echo "🧪 Testing Project Detail API Fallback"
echo "======================================"

PROJECT_ID="f8b2602b-9e91-4a68-9646-e20dae3c95ea"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmNjYzY2FjNC1hODU0LTRlNDEtOTRiMC0yOGJiMjdhODljNTIiLCJpZCI6IjA2NjNkYjQ3LTg2MDEtNGRjNi1hZjEyLTFkNzgxNDJmMTkyOSIsImp0aSI6Ijk4ODgyODM1LTFjY2ItNDNiNy05N2FkLTJlY2EyNjAxODYyMiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL25hbWUiOiJhZG1pbiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6ImFkbWluQGV4YW1wbGUuY29tIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE3NTE3ODAzOTQsImlzcyI6IlNvbGFyUHJvamVjdHNBUEkiLCJhdWQiOiJTb2xhclByb2plY3RzQ2xpZW50In0.-cEQVZg_yn6ksPCn3diUXYvSL7NZRXp1kD1YPc98WtM"

echo "📋 Step 1: Testing project detail endpoint (Expected to fail)"
echo "GET /api/v1/projects/$PROJECT_ID"
curl -s -X GET "http://localhost:5001/api/v1/projects/$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.success, .message, .errors'

echo ""
echo "📋 Step 2: Testing projects list endpoint (Expected to work)"
echo "GET /api/v1/projects (searching for project)"
curl -s -X GET "http://localhost:5001/api/v1/projects?pageSize=50" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq --arg id "$PROJECT_ID" '.data.items[] | select(.projectId == $id) | {projectId, projectName, status, startDate}'

echo ""
echo "✅ Test completed!"
echo "Expected behavior: Detail endpoint fails with null reference, but project exists in list"
