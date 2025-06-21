# 🔷 Solar Projects API - curl Test Commands

## 📋 API Base URL
```
https://solar-projects-api.azurewebsites.net
```

## 🏥 Health Check (No Auth Required)
```bash
curl -s 'https://solar-projects-api.azurewebsites.net/health' | python3 -m json.tool
```

## 🔐 Authentication

### Login
```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "your_email@example.com", "password": "your_password"}' \
  'https://solar-projects-api.azurewebsites.net/api/v1/auth/login' | python3 -m json.tool
```

### Register
```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "newuser",
    "email": "user@example.com", 
    "password": "password123",
    "fullName": "Full Name",
    "roleId": 3
  }' \
  'https://solar-projects-api.azurewebsites.net/api/v1/auth/register' | python3 -m json.tool
```

## 📊 Projects API (Requires Authentication)

### Get All Projects
```bash
curl -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects' | python3 -m json.tool
```

### Get Projects with Pagination
```bash
curl -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects?pageNumber=1&pageSize=5' | python3 -m json.tool
```

### Get Projects by Status
```bash
curl -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects?status=Active' | python3 -m json.tool
```

### Get Single Project by ID
```bash
curl -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects/1' | python3 -m json.tool
```

## 🔍 Testing Without Auth (Should Return 401)
```bash
curl -s -w '\nHTTP Status: %{http_code}\n' \
  -H 'Content-Type: application/json' \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects'
```

## 📝 Complete Workflow Example

### 1. Login and Extract Token
```bash
# Login and save response
LOGIN_RESPONSE=$(curl -s -X POST \
  -H 'Content-Type: application/json' \
  -d '{"username": "your_email", "password": "your_password"}' \
  'https://solar-projects-api.azurewebsites.net/api/v1/auth/login')

# Extract token (requires jq)
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token')

echo "Token: $TOKEN"
```

### 2. Use Token to Get Projects
```bash
curl -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects' | python3 -m json.tool
```

## 🛠️ Debugging Tips

### Check Response Headers
```bash
curl -I 'https://solar-projects-api.azurewebsites.net/api/v1/projects'
```

### Verbose Output for Debugging
```bash
curl -v -H 'Content-Type: application/json' \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects'
```

### Test CORS
```bash
curl -X OPTIONS \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type,Authorization" \
  'https://solar-projects-api.azurewebsites.net/api/v1/projects'
```

## 📊 Expected Response Formats

### Health Check Response
```json
{
  "status": "Healthy",
  "timestamp": "2025-06-21T02:05:45.8772437Z",
  "version": "1.0.0",
  "environment": "Production"
}
```

### Login Success Response
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "user": {
      "userId": "123",
      "username": "user",
      "email": "user@example.com",
      "fullName": "User Name",
      "roleName": "admin"
    }
  }
}
```

### Projects Response
```json
{
  "success": true,
  "message": "Projects retrieved successfully",
  "data": {
    "items": [
      {
        "projectId": "1",
        "projectName": "Solar Installation ABC",
        "address": "123 Main St",
        "clientInfo": "Client Name",
        "status": "Active",
        "startDate": "2025-01-01T00:00:00Z",
        "estimatedEndDate": "2025-12-31T00:00:00Z",
        "taskCount": 10,
        "completedTaskCount": 5
      }
    ],
    "totalCount": 1,
    "pageNumber": 1,
    "pageSize": 10,
    "totalPages": 1
  }
}
```

## ⚠️ Authentication Notes

- The projects API requires a valid JWT token
- Tokens are obtained by logging in with valid credentials
- Include the token in the Authorization header: `Bearer <token>`
- If you get 401 errors, your token may be expired or invalid

## 🎯 Quick Test Status

- ✅ **API Health**: Working (`/health`)
- ✅ **CORS**: Configured properly
- ✅ **Auth Endpoint**: Available (`/api/v1/auth/login`)
- 🔐 **Projects**: Requires valid authentication
- ❓ **Test Credentials**: Need valid username/password for full testing
