# Real-time Feature Testing Scripts

This directory contains scripts for testing real-time features including SignalR connections, WebSocket functionality, and live data updates.

## 📁 Directory Contents

### SignalR Testing
- `test_signalr_connection.sh` - Tests SignalR connection establishment and stability
- `test_signalr_auto_refresh.sh` - Tests automatic refresh functionality via SignalR

### Real-time Data Testing
- `test_project_deletion_realtime.sh` - Tests real-time project deletion events

## 🚀 Usage

### Prerequisites
Ensure the following are configured:
- SignalR hub URL
- WebSocket endpoint
- Authentication tokens
- Test project data

### Running Tests
```bash
# Test SignalR connection
./test_signalr_connection.sh

# Test auto-refresh functionality
./test_signalr_auto_refresh.sh

# Test real-time project deletion
./test_project_deletion_realtime.sh
```

## 📋 Test Coverage

These scripts test:
- SignalR connection establishment
- WebSocket communication
- Real-time event broadcasting
- Auto-refresh mechanisms
- Connection stability and reconnection
- Event handling and data synchronization

## 🔧 Configuration

Configure the following environment variables:
- `SIGNALR_HUB_URL` - SignalR hub endpoint
- `WEBSOCKET_URL` - WebSocket server URL
- `AUTH_TOKEN` - Authentication token for real-time connections

## 🐛 Debugging

For debugging real-time issues:
1. Check network connectivity
2. Verify authentication tokens
3. Monitor console logs during test execution
4. Use browser developer tools for WebSocket inspection

## 📚 Related Documentation

- [Real-time Implementation Guide](../../../docs/implementation/REALTIME_INTEGRATION_GUIDE.md)
- [SignalR Configuration](../../../docs/api/signalr_real_time_notifications.md)
- [WebSocket Documentation](../../../docs/implementation/WEBSOCKET_REALTIME_FINAL_IMPLEMENTATION.md)

---

**Last Updated**: July 2025
