# Feature Testing Scripts

This directory contains scripts for testing specific application features and functionality.

## 📁 Directory Contents

### Cache Management
- `test_cache_clearing.sh` - Tests cache clearing mechanisms and data refresh

### Error Handling
- `test_401_handling.sh` - Tests HTTP 401 (Unauthorized) error handling
- `test_401_comprehensive.sh` - Comprehensive test suite for authentication error scenarios

### UI/UX Features
- `test_project_detail_fallback.sh` - Tests project detail screen fallback mechanisms

## 🚀 Usage

### Prerequisites
- Configured test environment
- Valid test credentials
- Sample test data

### Running Tests
```bash
# Test cache clearing functionality
./test_cache_clearing.sh

# Test 401 error handling
./test_401_handling.sh

# Comprehensive 401 error tests
./test_401_comprehensive.sh

# Test project detail fallbacks
./test_project_detail_fallback.sh
```

## 📋 Test Coverage

### Cache Management Tests
- Cache invalidation
- Data refresh mechanisms
- Storage cleanup
- Performance impact

### Authentication Error Tests
- 401 error detection
- Token refresh handling
- User session management
- Automatic re-authentication

### UI Fallback Tests
- Error state handling
- Graceful degradation
- User experience during failures
- Recovery mechanisms

## 🔧 Configuration

Configure test parameters by editing the configuration section in each script or setting environment variables:

- `TEST_USER_EMAIL` - Test user email
- `TEST_USER_PASSWORD` - Test user password
- `API_BASE_URL` - API endpoint base URL
- `TEST_PROJECT_ID` - Sample project ID for testing

## 🐛 Troubleshooting

Common issues and solutions:
- **Authentication failures**: Check test credentials
- **Network timeouts**: Verify API connectivity
- **Cache issues**: Clear application cache before testing
- **Permission errors**: Ensure test user has required permissions

## 📚 Related Documentation

- [Error Handling Implementation](../../../docs/archived/completed-implementations/ERROR_HANDLING_FINAL_SUMMARY.md)
- [Cache Implementation](../../../docs/archived/completed-implementations/CACHE_CLEARING_IMPLEMENTATION.md)
- [Feature Documentation](../../../docs/features/)

---

**Last Updated**: July 2025
