# 📱 Local Storage Strategy - Solar Project Management App

## 🎯 **Storage Architecture Overview**

The app uses a **three-tier storage approach** for optimal performance and offline capabilities:

### **1. Secure Storage (Sensitive Data)**
**Location**: `flutter_secure_storage` - Encrypted keychain/keystore  
**Service**: `SecureStorageService`

```dart
// Authentication tokens, refresh tokens, encrypted user data
await secureStorage.saveAccessToken(token);
await secureStorage.saveRefreshToken(refreshToken);
await secureStorage.saveCachedUser(encryptedUserData);
```

**Used for:**
- ✅ Authentication tokens (access & refresh)
- ✅ Encrypted user credentials cache
- ✅ Security keys and certificates
- ✅ Sensitive project data (if any)

---

### **2. User Preferences (Non-sensitive Settings)**
**Location**: `shared_preferences` - Platform preference storage  
**Service**: `PreferencesService`

```dart
// User preferences, settings, remember me functionality
await preferencesService.setSavedUsername(email);
await preferencesService.setRememberMe(true);
await preferencesService.setAppTheme('dark');
```

**Used for:**
- ✅ Remember me functionality
- ✅ App theme preferences
- ✅ Notification settings
- ✅ Language preferences
- ✅ UI layout preferences

---

### **3. Application Cache (Performance & Offline)**
**Location**: `shared_preferences` with expiration logic  
**Service**: `CacheService` (newly created)

```dart
// Cached data with automatic expiration
await cacheService.cacheProjects(projectsList);
await cacheService.cacheProjectDetail(projectId, projectData);
await cacheService.cacheWorkCalendar(calendarData);
```

**Used for:**
- 🆕 Project lists (6-hour expiration)
- 🆕 Project details (24-hour expiration)
- 🆕 Work calendar data
- 🆕 User profile cache
- 🆕 App settings cache
- ✅ Daily report drafts

---

## 🔄 **Where Data Gets Saved - Implementation Locations**

### **A. Login Screen (Authentication)**
```dart
// File: lib/features/authentication/application/auth_cubit.dart
Future<void> signIn({required String email, required String password, bool rememberMe = false}) async {
  // ... authentication logic ...
  
  // Save remember me data
  if (rememberMe) {
    await _preferencesService.setSavedUsername(email);
    await _preferencesService.setRememberMe(true);
  }
}
```

### **B. Project Management (Performance Cache)**
```dart
// File: lib/features/projects/data/repositories/api_project_repository.dart
@override
Future<List<Project>> getProjects() async {
  // Try cache first for performance
  final cachedProjects = cacheService.getCachedProjects();
  if (cachedProjects != null) {
    return cachedProjects.map((json) => Project.fromJson(json)).toList();
  }

  // Fetch from API and cache
  final projects = await _apiService.getProjects();
  await cacheService.cacheProjects(projects.map((p) => p.toJson()).toList());
  return projects;
}
```

### **C. Daily Reports (Draft Storage)**
```dart
// File: lib/features/daily_reports/application/cubits/daily_reports_cubit.dart
Future<void> saveDraftLocally(DailyReport report) async {
  // Save draft for offline editing
  final result = await _saveDraftLocallyUseCase(SaveDraftParams(report: report));
  
  result.fold(
    (failure) => emit(DailyReportError(message: failure.message)),
    (savedReport) => emit(DailyReportDraftSaved(draftReport: savedReport)),
  );
}
```

### **D. User Profile (Cache + Secure Storage)**
```dart
// File: lib/features/authentication/data/repositories/api_auth_repository.dart
@override
Future<User> getCurrentUser() async {
  // Try secure cache first
  final cachedUserData = await _secureStorage.getCachedUser();
  if (cachedUserData != null) {
    return User.fromJson(jsonDecode(cachedUserData));
  }

  // Fetch from API and cache securely
  final user = await _apiService.getCurrentUser();
  await _secureStorage.saveCachedUser(jsonEncode(user.toJson()));
  return user;
}
```

---

## 📊 **Storage Usage by Feature**

| Feature | Storage Type | Service | Data Cached | Expiration |
|---------|-------------|---------|-------------|------------|
| **Authentication** | Secure + Preferences | `SecureStorageService` + `PreferencesService` | Tokens, username | Session-based |
| **Projects** | Cache | `CacheService` | Project lists, details | 6-24 hours |
| **Daily Reports** | Local Database | Mock/API Repository | Report drafts | Until synced |
| **Work Calendar** | Cache | `CacheService` | Calendar events | 24 hours |
| **User Profile** | Secure + Cache | `SecureStorageService` + `CacheService` | Profile data | 12 hours |
| **App Settings** | Preferences + Cache | `PreferencesService` + `CacheService` | UI preferences | Persistent |
| **Notifications** | Preferences | `PreferencesService` | Notification settings | Persistent |

---

## ⚡ **Performance Benefits**

### **1. Faster App Startup**
- Cached user profile loads instantly
- Saved login credentials for quick authentication
- Cached project lists show immediately

### **2. Better Offline Experience**
- Draft reports saved locally until internet available
- Cached project data accessible without connection
- App settings and preferences always available

### **3. Reduced API Calls**
- Cache hits prevent unnecessary network requests
- Automatic cache expiration ensures data freshness
- Smart cache invalidation on user actions

---

## 🔧 **Implementation in Your App**

### **Step 1: Add Cache Service to Repositories**

```dart
// Example: Project Repository with Caching
class ApiProjectRepository implements ProjectRepository {
  final CacheService _cacheService;
  
  @override
  Future<List<Project>> getProjects() async {
    // Check cache first
    final cachedData = _cacheService.getCachedProjects();
    if (cachedData != null) {
      return cachedData.map((json) => Project.fromJson(json)).toList();
    }
    
    // Fetch and cache
    final projects = await _apiService.getProjects();
    await _cacheService.cacheProjects(
      projects.map((p) => p.toJson()).toList()
    );
    return projects;
  }
}
```

### **Step 2: Add Cache Management to App Lifecycle**

```dart
// In app.dart - Clear expired cache on app startup
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Clear expired cache entries
    getIt<CacheService>().clearExpiredCache();
  }
}
```

### **Step 3: Add Cache Statistics for Debugging**

```dart
// Debug screen to show cache status
final cacheStats = cacheService.getCacheStatistics();
print('Cache entries: ${cacheStats['validEntries']}');
print('Last sync: ${cacheStats['lastSyncTime']}');
```

---

## 🎯 **Best Practices Applied**

✅ **Security**: Sensitive data in encrypted storage  
✅ **Performance**: Three-tier caching strategy  
✅ **Offline Support**: Local drafts and cached data  
✅ **Data Freshness**: Automatic cache expiration  
✅ **Memory Management**: Cache cleanup and statistics  
✅ **User Experience**: Instant loading with cache  

This storage strategy ensures your solar project management app provides excellent performance, works offline, and maintains security best practices!
