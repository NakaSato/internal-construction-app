#!/bin/bash

# Test 401 Handling in Flutter App - Comprehensive Test
# This script helps test the complete 401 handling flow

echo "🔐 Flutter App 401 Handling Test Guide"
echo "======================================"
echo

echo "📋 Test Steps:"
echo "1. Start the Flutter app"
echo "2. Login with valid credentials"  
echo "3. Corrupt the token to simulate expiration"
echo "4. Navigate to trigger an API call"
echo "5. Verify automatic logout and snackbar"
echo

# Function to start the app
start_app() {
    echo "🚀 Starting Flutter App..."
    echo "========================="
    echo
    echo "Choose your platform:"
    echo "1) iOS Simulator"
    echo "2) macOS Desktop"
    echo "3) Chrome Web"
    
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo "Starting on iOS Simulator..."
            cd /Users/chanthawat/Development/flutter-dev-solar-mana
            flutter run -d "iPhone 16 Pro" --flavor development
            ;;
        2)
            echo "Starting on macOS Desktop..."
            cd /Users/chanthawat/Development/flutter-dev-solar-mana
            flutter run -d macos --flavor development
            ;;
        3)
            echo "Starting on Chrome Web..."
            cd /Users/chanthawat/Development/flutter-dev-solar-mana
            flutter run -d chrome --flavor development
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

# Function to show test credentials
show_credentials() {
    echo "🔑 Test Credentials:"
    echo "==================="
    echo "Username: sysadmin"
    echo "Password: Admin123!"
    echo
    echo "Alternative credentials:"
    echo "Username: user@gridtokenx.com"
    echo "Password: User123!"
    echo
}

# Function to simulate token corruption
simulate_token_corruption() {
    echo "🔧 Token Corruption Simulation:"
    echo "==============================="
    echo
    echo "To simulate token expiration/corruption:"
    echo
    echo "1. Use your Flutter app's debug tools or"
    echo "2. Use ADB for Android to modify secure storage:"
    echo "   adb shell run-as com.example.solar_management_app"
    echo
    echo "3. Or use iOS Simulator tools to clear keychain"
    echo
    echo "4. Alternatively, wait for token to naturally expire"
    echo "   (tokens expire based on server configuration)"
    echo
    echo "5. Or modify the stored token in your debug session:"
    echo "   - Use flutter inspector"
    echo "   - Modify secure storage values"
    echo "   - Trigger an API call"
    echo
}

# Function to check expected behavior
check_expected_behavior() {
    echo "✅ Expected Behavior:"
    echo "===================="
    echo
    echo "When a 401 error occurs, you should see:"
    echo "1. Orange snackbar with message: 'Session expired. Please log in again.'"
    echo "2. Automatic navigation to login screen"
    echo "3. All tokens cleared from secure storage"
    echo "4. User logged out of the app"
    echo
    echo "Debug console should show:"
    echo "🔐 Auth Interceptor: Token invalid/expired - User logged out and redirected to login"
    echo
}

# Function to run API health check
api_health_check() {
    echo "🌐 API Health Check:"
    echo "==================="
    echo
    curl -s 'https://api-icms.gridtokenx.com/health' | python3 -m json.tool
    echo
}

# Function to test 401 scenarios
test_401_scenarios() {
    echo "🧪 Testing 401 Scenarios:"
    echo "========================="
    echo
    
    echo "Testing with invalid token:"
    RESPONSE_CODE=$(curl -s -w "%{http_code}" -o /dev/null \
      -H "Authorization: Bearer invalid.token.here" \
      'https://api-icms.gridtokenx.com/api/v1/projects')
    
    if [ "$RESPONSE_CODE" = "401" ]; then
        echo "✅ API returns 401 for invalid tokens"
    else
        echo "❌ API returned: $RESPONSE_CODE (expected 401)"
    fi
    echo
}

# Main menu
show_menu() {
    echo "🔗 Flutter 401 Handling Test Menu:"
    echo "=================================="
    echo "1) Show test credentials"
    echo "2) Check API health"
    echo "3) Test 401 API responses"
    echo "4) Show token corruption methods"
    echo "5) Show expected behavior"
    echo "6) Start Flutter app"
    echo "7) Exit"
    echo
}

# Main loop
while true; do
    show_menu
    read -p "Choose an option (1-7): " option
    echo
    
    case $option in
        1) show_credentials ;;
        2) api_health_check ;;
        3) test_401_scenarios ;;
        4) simulate_token_corruption ;;
        5) check_expected_behavior ;;
        6) start_app ;;
        7) echo "👋 Happy testing!"; exit 0 ;;
        *) echo "❌ Invalid option" ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
    echo
done
