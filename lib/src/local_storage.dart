import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

/// LocalStorage class to handle storing and retrieving data in shared preferences.
/// It supports encryption, backup, and restore functionalities.
class LocalStorage {
  final encrypt.Encrypter _encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromLength(32)));
  final encrypt.IV _iv = encrypt.IV.fromLength(16);

  /// Encrypts a plain text string.
  String _encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  /// Decrypts an encrypted text string.
  String _decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }

  /// Saves a string to shared preferences.
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, _encrypt(value));
  }

  /// Retrieves a string from shared preferences.
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedValue = prefs.getString(key);
    if (encryptedValue != null) {
      return _decrypt(encryptedValue);
    }
    return null;
  }

  /// Saves an integer to shared preferences.
  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Retrieves an integer from shared preferences.
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Saves a boolean to shared preferences.
  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Retrieves a boolean from shared preferences.
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Saves a double to shared preferences.
  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  /// Retrieves a double from shared preferences.
  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  /// Saves a JSON object to shared preferences.
  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(json));
  }

  /// Retrieves a JSON object from shared preferences.
  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Removes a specific entry from shared preferences by key.
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clears all entries from shared preferences.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Backs up shared preferences data to a specified file path.
  Future<void> backupStorage(String backupPath) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final backupData = <String, dynamic>{};
    for (final key in keys) {
      backupData[key] = prefs.get(key);
    }
    final backupFile = File(backupPath);
    await backupFile.writeAsString(jsonEncode(backupData));
  }

  /// Restores shared preferences data from a specified file path.
  Future<void> restoreStorage(String backupPath) async {
    final prefs = await SharedPreferences.getInstance();
    final backupFile = File(backupPath);
    final backupData = jsonDecode(await backupFile.readAsString()) as Map<String, dynamic>;
    for (final key in backupData.keys) {
      final value = backupData[key];
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    }
  }
}