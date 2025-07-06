# API Testing Scripts

This directory contains scripts for testing various API endpoints and configurations.

## 📁 Directory Contents

### Configuration Testing
- `test_api_config.sh` - Tests API configuration and endpoint connectivity
- `test_production_users.sh` - Tests production user authentication and data

### Development & Debugging
- `debug_flutter_api.sh` - Debug script for Flutter API integration issues

## 🚀 Usage

### Prerequisites
Ensure you have the following environment variables set:
- `API_BASE_URL` - Base URL for the API
- `API_KEY` - API authentication key (if required)

### Running Tests
```bash
# Test API configuration
./test_api_config.sh

# Test production users
./test_production_users.sh

# Debug API issues
./debug_flutter_api.sh
```

## 📋 Test Coverage

These scripts test:
- API endpoint availability
- Authentication mechanisms
- User data retrieval
- Error handling scenarios
- Network connectivity

## 🔧 Configuration

Scripts can be configured through environment variables or by editing the configuration section at the top of each script.

## 📚 Related Documentation

- [API Documentation](../../../docs/api/) - API reference
- [Environment Configuration](../../../docs/api/environment_configuration.md) - Environment setup
- [Testing Guide](../../../docs/testing/) - General testing guidelines

---

**Last Updated**: July 2025
