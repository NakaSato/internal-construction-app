# 🐛 Registration Error Debug Guide

## Current Issue
You're getting a 400 Bad Request error when trying to register with:
- **Email**: test@gmail.com
- **Password**: Test@pass
- **Name**: TEST

## Password Analysis: `Test@pass`
- ✅ **Length**: 9 characters (>=8 required)
- ✅ **Uppercase**: T
- ✅ **Lowercase**: est, pass
- ❌ **Digit**: Missing (0-9)
- ✅ **Special**: @ symbol

**Issue**: The password is missing a digit (0-9)

## Quick Fixes

### 1. Add a Digit to Password
Try these passwords instead:
- `Test@pass1` 
- `Test@pass123`
- `Test1@pass`

### 2. Check API Requirements
Your API might have additional requirements:
- Minimum 8-100 characters ✅
- At least one uppercase letter ✅
- At least one lowercase letter ✅
- At least one digit ❌
- At least one special character ✅

## Debug Tools Added

### 1. Enhanced Logging
I've added detailed debug logging to:
- `ApiErrorParser` - Shows raw API responses
- `ApiAuthRepository` - Shows registration API errors

### 2. Debug Registration App
Run: `flutter run debug_registration.dart`

This app will:
- Show password requirement analysis
- Display detailed error messages
- Provide "fix password" button
- Show console logs for debugging

### 3. Better Error Parsing
The `ApiErrorParser` now:
- Logs all response details in debug mode
- Handles malformed JSON responses
- Shows response types and content
- Provides fallback error messages

## Expected API Response Format

When you use a weak password, expect this response:
```json
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Password": [
      "Password must be between 8 and 100 characters",
      "Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character"
    ]
  }
}
```

## What to Check in Console

Look for these debug logs:
```
=== Registration API Error Debug ===
Status Code: 400
Response Data: {...}
=== ApiErrorParser Debug ===
Raw Response: {...}
=== Extracting Validation Errors ===
```

## Troubleshooting Steps

1. **Run Debug App**: `flutter run debug_registration.dart`
2. **Check Console Logs**: Look for detailed API response
3. **Fix Password**: Add digit to password (Test@pass1)
4. **Verify API**: Make sure your ASP.NET Core API is running
5. **Check Network**: Ensure app can reach localhost:5002

## Common Issues

### Password Too Weak
- **Solution**: Add missing character types (digits, specials, etc.)

### User Already Exists
- **Solution**: Use different email or username

### API Not Running
- **Solution**: Start your ASP.NET Core backend

### Network Issues
- **Solution**: Check API base URL in .env file

## Test Passwords

✅ **Strong Passwords** (should work):
- `Test@pass123`
- `StrongPass1!`
- `MyPassword1@`

❌ **Weak Passwords** (will fail):
- `Test@pass` (no digit)
- `testpass123` (no uppercase/special)
- `TESTPASS123` (no lowercase/special)
- `Test123` (no special character)

Run the debug app to see exactly what your API is returning!
