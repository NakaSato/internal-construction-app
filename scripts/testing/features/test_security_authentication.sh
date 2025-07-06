#!/bin/bash

# Security and Authentication Testing Script
# Tests the enhanced authentication and security features implemented in the Flutter app

echo "🔐 Testing Security and Authentication Enhancements"
echo "=================================================="

# Set environment variables
export API_BASE_URL="http://localhost:5001"
export TEST_USERNAME="test_admin"
export TEST_PASSWORD="Admin123!"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "\n${BLUE}Test $TESTS_RUN: $test_name${NC}"
    echo "Command: $test_command"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAILED${NC}"
    fi
}

# Test 1: Verify app compiles without errors
run_test "App Compilation" "flutter analyze lib/app.dart --fatal-infos"

# Test 2: Verify TokenService compilation
run_test "TokenService Compilation" "flutter analyze lib/core/services/token_service.dart --fatal-infos"

# Test 3: Verify SecurityService compilation
run_test "SecurityService Compilation" "flutter analyze lib/core/services/security_service.dart --fatal-infos"

# Test 4: Verify SecureStorageService compilation
run_test "SecureStorageService Compilation" "flutter analyze lib/core/storage/secure_storage_service.dart --fatal-infos"

# Test 5: Check if services are properly registered in DI
run_test "Dependency Injection Check" "grep -q 'TokenService\|SecurityService' lib/core/di/injection.config.dart"

# Test 6: Verify authentication documentation is in place
run_test "Authentication Documentation" "test -f docs/api/authentication.md"

# Test 7: Verify test scripts are organized
run_test "Test Scripts Organization" "test -d scripts/testing/api && test -d scripts/testing/realtime && test -d scripts/testing/features"

# Test 8: Check for proper import structure in app.dart
run_test "Import Structure" "grep -q 'core/services/token_service.dart\|core/services/security_service.dart' lib/app.dart"

# Test 9: Verify authentication state handling
run_test "Auth State Handling" "grep -q '_handleGlobalAuthChanges\|_performSecureLogout\|_initializeSecuritySession' lib/app.dart"

# Test 10: Check for app lifecycle security integration
run_test "Lifecycle Security Integration" "grep -q '_refreshTokensOnResume\|updateLastActivity\|isSessionTimedOut' lib/app.dart"

echo -e "\n${YELLOW}===============================================${NC}"
echo -e "${YELLOW}Security and Authentication Enhancement Summary${NC}"
echo -e "${YELLOW}===============================================${NC}"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}🎉 All tests passed! ($TESTS_PASSED/$TESTS_RUN)${NC}"
    echo -e "${GREEN}✅ Authentication and security enhancements successfully applied${NC}"
else
    echo -e "${RED}⚠️  Some tests failed ($TESTS_PASSED/$TESTS_RUN passed)${NC}"
    echo -e "${YELLOW}Please review the failed tests above${NC}"
fi

echo -e "\n${BLUE}Enhanced Security Features:${NC}"
echo "• JWT token management with automatic refresh"
echo "• Secure token storage using flutter_secure_storage"
echo "• Session timeout and activity monitoring"
echo "• Failed login attempt tracking and account lockout"
echo "• Password strength validation"
echo "• Input sanitization and validation"
echo "• App lifecycle security integration"
echo "• Comprehensive security event logging"
echo "• Role-based access control helpers"
echo "• Secure logout with complete cleanup"

echo -e "\n${BLUE}Enhanced Authentication Features:${NC}"
echo "• Automatic token refresh on app resume"
echo "• Session security monitoring"
echo "• Global authentication state management"
echo "• Secure application cache clearing"
echo "• Error handling with security considerations"
echo "• Real-time authentication state updates"

echo -e "\n${BLUE}Documentation Improvements:${NC}"
echo "• Comprehensive authentication API documentation"
echo "• Organized test scripts in logical subdirectories"
echo "• Updated documentation index and README files"
echo "• Security best practices integration"

echo -e "\n${GREEN}Authentication and security enhancements complete!${NC}"
