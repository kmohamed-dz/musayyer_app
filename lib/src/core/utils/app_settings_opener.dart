import 'package:flutter/services.dart';

class AppSettingsOpener {
  static const MethodChannel _channel = MethodChannel('musayyer/app_settings');

  static Future<void> openSettings() async {
    await _channel.invokeMethod<void>('openAppSettings');
  }
}
