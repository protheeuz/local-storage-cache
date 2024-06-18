import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_cache/local_storage_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  // Inisialisasi binding Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi databaseFactory untuk pengujian sqflite
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalStorage', () {
    final localStorage = LocalStorage();

    test('Save and retrieve string', () async {
      SharedPreferences.setMockInitialValues({});
      await localStorage.saveString('key1', 'value1');
      final value = await localStorage.getString('key1');
      expect(value, 'value1');
    });

    test('Save and retrieve int', () async {
      SharedPreferences.setMockInitialValues({});
      await localStorage.saveInt('key2', 123);
      final value = await localStorage.getInt('key2');
      expect(value, 123);
    });

    test('Save and retrieve bool', () async {
      SharedPreferences.setMockInitialValues({});
      await localStorage.saveBool('key3', true);
      final value = await localStorage.getBool('key3');
      expect(value, true);
    });

    test('Save and retrieve double', () async {
      SharedPreferences.setMockInitialValues({});
      await localStorage.saveDouble('key4', 1.23);
      final value = await localStorage.getDouble('key4');
      expect(value, 1.23);
    });

    test('Save and retrieve JSON', () async {
      SharedPreferences.setMockInitialValues({});
      await localStorage.saveJson('key5', {'field': 'value'});
      final value = await localStorage.getJson('key5');
      expect(value, {'field': 'value'});
    });

    test('Remove data', () async {
      SharedPreferences.setMockInitialValues({'key2': 'value2'});
      await localStorage.removeData('key2');
      final value = await localStorage.getString('key2');
      expect(value, null);
    });

    test('Clear all data', () async {
      SharedPreferences.setMockInitialValues({'key3': 'value3'});
      await localStorage.clearAll();
      final value = await localStorage.getString('key3');
      expect(value, null);
    });

    test('Backup and restore data', () async {
      SharedPreferences.setMockInitialValues({});
      await localStorage.saveString('key1', 'value1');
      const backupPath = 'test_backup.json';
      await localStorage.backupStorage(backupPath);

      await localStorage.clearAll();
      await localStorage.restoreStorage(backupPath);

      final value = await localStorage.getString('key1');
      expect(value, 'value1');

      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    });
  });

  group('CacheManager', () {
    final cacheManager = CacheManager(expirationCallback: (key) {
      print('Cache expired for key: $key');
    });

    test('Save and retrieve cache', () async {
      await cacheManager.saveCache('key1', 'value1');
      final value = await cacheManager.getCache('key1');
      expect(value, 'value1');
    });

    test('Save cache with TTL and retrieve before expiration', () async {
      await cacheManager.saveCache('key2', 'value2',
          ttl: const Duration(seconds: 2));
      final value = await cacheManager.getCache('key2');
      expect(value, 'value2');
    });

    test('Save cache with TTL and retrieve after expiration', () async {
      await cacheManager.saveCache('key3', 'value3',
          ttl: const Duration(seconds: 1));
      await Future.delayed(const Duration(seconds: 2));
      final value = await cacheManager.getCache('key3');
      expect(value, null);
    });

    test('Remove cache', () async {
      await cacheManager.saveCache('key4', 'value4');
      await cacheManager.removeCache('key4');
      final value = await cacheManager.getCache('key4');
      expect(value, null);
    });

    test('Clear all cache', () async {
      await cacheManager.saveCache('key5', 'value5');
      await cacheManager.clearAll();
      final value = await cacheManager.getCache('key5');
      expect(value, null);
    });

    test('Backup and restore cache', () async {
      await cacheManager.saveCache('key1', 'value1');
      const backupPath = 'test_cache_backup.json';
      await cacheManager.backupCache(backupPath);

      await cacheManager.clearAll();
      await cacheManager.restoreCache(backupPath);

      final value = await cacheManager.getCache('key1');
      expect(value, 'value1');

      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    });
  });
}
