// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStorageProvider = Provider<AppStorage>((ref) => AppStorage());

class AppStorage {
  Future<void> write(String key, String value) async {
    try {
      html.window.localStorage[key] = value;
    } catch (_) {}
  }

  Future<String?> read(String key) async {
    try {
      return html.window.localStorage[key];
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      html.window.localStorage.remove(key);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      html.window.localStorage.clear();
    } catch (_) {}
  }
}
