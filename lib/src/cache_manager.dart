import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Callback function type for cache expiration.
typedef ExpirationCallback = void Function(String key);

/// CacheManager class to handle caching operations with optional TTL (Time-To-Live).
/// It also supports encryption, backup, and restore functionalities.
class CacheManager {
  static Database? _database;
  final encrypt.Encrypter _encrypter =
      encrypt.Encrypter(encrypt.AES(encrypt.Key.fromLength(32)));
  final encrypt.IV _iv = encrypt.IV.fromLength(16);
  final int _maxCacheSize;
  final ExpirationCallback? _expirationCallback;

  /// Private constructor with optional parameters for max cache size and expiration callback.
  CacheManager._internal([this._maxCacheSize = 100, this._expirationCallback]);

  /// Factory constructor for CacheManager with customizable max cache size and expiration callback.
  factory CacheManager(
      {int maxCacheSize = 100, ExpirationCallback? expirationCallback}) {
    return CacheManager._internal(maxCacheSize, expirationCallback);
  }

  /// Encrypts a plain text string.
  String _encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  /// Decrypts an encrypted text string.
  String _decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }

  /// Initializes and returns the database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Sets up the SQLite database.
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE,
            value TEXT,
            ttl INTEGER
          )
        ''');
      },
    );
  }

  /// Saves data to the cache with an optional TTL (Time-To-Live).
  Future<void> saveCache(String key, String value, {Duration? ttl}) async {
    final db = await database;
    final expiration =
        ttl != null ? DateTime.now().add(ttl).millisecondsSinceEpoch : null;
    await db.insert(
      'cache',
      {'key': key, 'value': _encrypt(value), 'ttl': expiration},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _enforceMaxCacheSize(db);
  }

  /// Enforces the maximum cache size by removing the oldest entries.
  Future<void> _enforceMaxCacheSize(Database db) async {
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cache'));
    if (count! > _maxCacheSize) {
      await db.delete('cache',
          where: 'id IN (SELECT id FROM cache ORDER BY ttl ASC LIMIT ?)',
          whereArgs: [count - _maxCacheSize]);
    }
  }

  /// Retrieves data from the cache by key.
  Future<String?> getCache(String key) async {
    final db = await database;
    final result = await db.query(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      final ttl = row['ttl'] as int?;
      if (ttl != null && ttl < DateTime.now().millisecondsSinceEpoch) {
        await removeCache(key);
        if (_expirationCallback != null) {
          _expirationCallback(key);
        }
        return null;
      }
      return _decrypt(row['value'] as String);
    } else {
      return null;
    }
  }

  /// Removes a specific cache entry by key.
  Future<void> removeCache(String key) async {
    final db = await database;
    await db.delete(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Clears all cache entries.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('cache');
  }

  /// Deletes all the expired cache entries based on ttl.
  ///
  /// Returns the number of entries deleted.
  Future<int> deleteExpiredCache() async {
    final db = await database;
    return await db.delete('cache',
        where: 'ttl != NULL AND ttl < ?',
        whereArgs: [DateTime.now().millisecondsSinceEpoch]);
  }

  /// Backs up cache data to a specified file path.
  Future<void> backupCache(String backupPath) async {
    final db = await database;
    final cacheData = await db.query('cache');
    final backupFile = File(backupPath);
    await backupFile.writeAsString(jsonEncode(cacheData));
  }

  /// Restores cache data from a specified file path.
  Future<void> restoreCache(String backupPath) async {
    final db = await database;
    final backupFile = File(backupPath);
    final cacheData =
        jsonDecode(await backupFile.readAsString()) as List<dynamic>;
    for (final entry in cacheData) {
      await db.insert(
        'cache',
        Map<String, dynamic>.from(entry),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
