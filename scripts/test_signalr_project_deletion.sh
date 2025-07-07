#!/bin/bash
# Test script for SignalR project deletion real-time updates

# Text formatting
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

echo "${BOLD}${BLUE}SignalR Project Deletion Test Utility${NORMAL}"
echo "============================================="
echo "${YELLOW}This utility helps diagnose real-time updates for project deletions${NORMAL}"
echo

# Ask for project ID
read -p "Enter project ID to simulate deletion for: " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
  echo "${RED}Error: No project ID provided${NORMAL}"
  exit 1
fi

echo
echo "${BOLD}${YELLOW}Simulating SignalR project deletion event for:${NORMAL}"
echo "Project ID: $PROJECT_ID"
echo

# Get API token from secure storage
echo "${BLUE}Retrieving authentication token...${NORMAL}"
TOKEN=$(flutter run -d chrome --dart-define="getAuthToken=true" --dart-entrypoint-args="--get-token" | grep "AUTH_TOKEN=" | cut -d= -f2-)

if [ -z "$TOKEN" ]; then
  echo "${RED}Error: Could not retrieve auth token${NORMAL}"
  exit 1
fi

echo "${GREEN}✓ Token retrieved successfully${NORMAL}"

# API base URL
API_URL=$(grep "apiBaseUrl" lib/core/config/environment_config.dart | awk -F'"' '{print $2}')
if [ -z "$API_URL" ]; then
  API_URL="https://api.solar-project.app/api/v1"
fi

# SignalR hub URL
SIGNALR_URL="$API_URL/notificationHub"
echo "${BLUE}SignalR Hub URL: $SIGNALR_URL${NORMAL}"

echo
echo "${BOLD}${YELLOW}Testing real-time deletion notification...${NORMAL}"

# Send test notification using curl
echo "${BLUE}Sending test SignalR event...${NORMAL}"
curl -X POST "$API_URL/test/signalr/send-event" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"projectDeleted\",
    \"data\": {
      \"projectId\": \"$PROJECT_ID\"
    }
  }" || echo "${RED}Failed to send test event${NORMAL}"

echo
echo "${GREEN}✓ Test event sent successfully${NORMAL}"
echo
echo "${BOLD}${YELLOW}Now check your app UI to see if the project was removed from the list${NORMAL}"
echo "If the UI did not update automatically, there may be an issue with SignalR reception"
echo
echo "Diagnostic steps:"
echo "1. Check browser console for SignalR connection logs"
echo "2. Verify the project_bloc.dart has proper deletion handling"
echo "3. Check if the ProjectsLoaded state is updated correctly"
echo "4. Verify your SignalR hub is broadcasting the event correctly"
echo
echo "${BOLD}${GREEN}Try the 'Force Refresh' button in the app${NORMAL}"
echo "- We added a blue 'Force Refresh' button next to the real-time status indicator"
echo "- This will clear the cache and force a complete reload of project data"
echo "- Use this as a fallback if SignalR updates aren't working properly"
