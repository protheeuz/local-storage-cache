# Local Storage Cache - Flutter

A comprehensive Flutter package for managing local storage and caching with advanced features like encryption, TTL (Time-To-Live), and backup/restore capabilities.

## Features

- **Data Storage**: Save and retrieve data of various types (String, int, bool, double, JSON) using shared preferences.
- **Encryption**: Automatically encrypt data before saving and decrypt upon retrieval to ensure security.
- **Cache Management**: Cache data with optional TTL (Time-To-Live) using SQLite, enabling temporary storage of data that expires after a set duration.
- **Data Removal**: Remove specific data or clear all data from both local storage and cache.
- **Backup and Restore**: Backup and restore data for both local storage and cache, allowing for easy data migration and recovery.
- **Expiration Notification**: Callback function to notify when cached data expires.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  local_storage_cache:
    git:
      url: https://github.com/protheeuz/local_storage_cache.git
      ref: main
```

### Usage

## Local Storage
```dart
import 'package:local_storage_cache/local_storage_cache.dart';

final localStorage = LocalStorage();

// Save data
await localStorage.saveString('key1', 'value1');

// Retrieve data
final value = await localStorage.getString('key1');
print(value); // Output: value1

// Save other types of data
await localStorage.saveInt('key2', 123);
await localStorage.saveBool('key3', true);
await localStorage.saveDouble('key4', 1.23);
await localStorage.saveJson('key5', {'field': 'value'});

// Retrieve other types of data
final intValue = await localStorage.getInt('key2');
final boolValue = await localStorage.getBool('key3');
final doubleValue = await localStorage.getDouble('key4');
final jsonValue = await localStorage.getJson('key5');

// Remove data
await localStorage.removeData('key1');

// Clear all data
await localStorage.clearAll();
```
## Cache Manager
```dart
import 'package:local_storage_cache/local_storage_cache.dart';

final cacheManager = CacheManager(expirationCallback: (key) {
  print('Cache expired for key: $key');
});

// Save cache
await cacheManager.saveCache('key1', 'value1');

// Retrieve cache
final value = await cacheManager.getCache('key1');
print(value); // Output: value1

// Save cache with TTL
await cacheManager.saveCache('key2', 'value2', ttl: Duration(seconds: 5));

// Retrieve cache before expiration
final valueBeforeExpiration = await cacheManager.getCache('key2');
print(valueBeforeExpiration); // Output: value2

// Wait for TTL to expire
await Future.delayed(Duration(seconds: 6));

// Retrieve cache after expiration
final valueAfterExpiration = await cacheManager.getCache('key2');
print(valueAfterExpiration); // Output: null

// Remove cache
await cacheManager.removeCache('key1');

// Clear all cache
await cacheManager.clearAll();

// Backup cache
await cacheManager.backupCache('/path/to/backup.json');

// Restore cache
await cacheManager.restoreCache('/path/to/backup.json');
```

### Additional Notes
Make sure to replace `/path/to/backup.json` with the appropriate path in your file system when using the backup and restore functions. You can also add more examples and documentation based on the additional features implemented if needed.

## Explanation
- General Description: A comprehensive Flutter package for managing local storage and caching with advanced features like encryption, TTL (Time-To-Live), and backup/restore capabilities.
**Key Features:**
- Data Storage: Save and retrieve data of various types (String, int, bool, double, JSON) using shared preferences.
- Encryption: Automatically encrypt data before saving and decrypt upon retrieval to ensure security.
- Cache Management: Cache data with optional TTL (Time-To-Live) using SQLite, enabling temporary storage of data that expires after a set duration.
- Data Removal: Remove specific data or clear all data from both local storage and cache.
- Backup and Restore: Backup and restore data for both local storage and cache, allowing for easy data migration and recovery.
- Expiration Notification: Callback function to notify when cached data expires.

**Installation Instructions:** Add the package to your pubspec.yaml file and run flutter pub get to install it.
**Usage Examples:**
- For LocalStorage: Includes examples for saving, retrieving, removing, and backing up/restoring data.
- For CacheManager: Includes examples for saving with TTL, retrieving, removing, and backing up/restoring cached data.
**Additional Notes:** Replace /path/to/backup.json with the appropriate path in your file system when using the backup and restore functions. You can also add more examples and documentation based on the additional features implemented if needed.
