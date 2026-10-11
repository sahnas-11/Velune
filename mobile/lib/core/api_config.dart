import 'dart:io';

/// Centralized API configuration for Velune mobile app.
/// Configures backend host for Android Emulator (10.0.2.2), physical Android phone
/// via USB reverse proxy (`adb reverse tcp:8000 tcp:8000` -> 127.0.0.1:8000), or custom IP.
class ApiConfig {
  /// When true, uses 127.0.0.1 on Android (standard workflow with `adb reverse tcp:8000 tcp:8000`).
  /// When false, uses 10.0.2.2 for Android emulator without reverse proxy.
  static bool useAdbReverse = true;

  /// Optional manual IP address override (e.g., '192.168.1.50:8000' for Wi-Fi testing)
  static String? customHost;

  static String get host {
    if (customHost != null && customHost!.isNotEmpty) {
      return customHost!;
    }
    if (Platform.isAndroid) {
      return useAdbReverse ? '127.0.0.1:8000' : '10.0.2.2:8000';
    }
    return '127.0.0.1:8000';
  }

  static String get baseUrl => 'http://$host/api';
}
