# Data Files

This directory contains data files, user accounts, and configuration data for the Flutter Solar Project Management app.

## 📁 Directory Contents

### 👥 User Account Data
- [user.md](./user.md) - Test user accounts and credentials
- [production_users.json](./production_users.json) - Production user data (JSON format)
- [users_simple.json](./users_simple.json) - Simplified user data structure

## 🔐 Test Accounts

The following test accounts are available for development and testing:

| Role | Username | Password | Email | Status |
|------|----------|----------|-------|---------|
| Admin | `test_admin` | `Admin123!` | test_admin@example.com | ✅ Active |
| Manager | `test_manager` | `Manager123!` | test_manager@example.com | ✅ Active |
| User | `test_user` | `User123!` | test_user@example.com | ✅ Active |
| Viewer | `test_viewer` | `Viewer123!` | test_viewer@example.com | ✅ Active |

## 🔑 Account Creation Details

- **Database**: All accounts successfully created in PostgreSQL
- **API**: Authentication verified with test_admin account
- **Created**: 2025-06-14 10:06:37 UTC
- **Password Hashing**: Proper bcrypt hashing applied via API registration endpoint

## 🎯 Usage

### For Development
Use these accounts when testing authentication flows, role-based access control, and feature permissions.

### For API Testing
These accounts can be used with the testing scripts in `/scripts/testing/` to verify API functionality.

### For Manual Testing
Use different role accounts to test various user experience flows and permission levels.

## 🛡️ Security Notes

- These are **development/testing accounts only**
- Do not use these credentials in production
- All passwords follow the security policy (8+ chars, mixed case, numbers, symbols)
- Accounts are created through the standard API registration flow

## 🔄 Data Formats

### JSON Structure
```json
{
  "userId": "uuid",
  "username": "string",
  "email": "string",
  "roleName": "string",
  "isActive": boolean,
  "createdAt": "ISO timestamp"
}
```

### Roles Available
- **Admin**: Full system access
- **Manager**: Project management access
- **User**: Standard user access
- **Viewer**: Read-only access

## 📚 Related Documentation

- [Authentication Feature](../docs/features/authentication/) - Authentication implementation
- [Authorization Feature](../docs/features/authorization/) - Role-based access control
- [Testing Scripts](../scripts/testing/) - Scripts using these accounts
