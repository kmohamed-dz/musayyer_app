import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../storage/local_storage.dart';
import '../storage/storage_keys.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._storage)
      : super(
          Locale(_storage.getString(StorageKeys.preferredLocale) ?? 'ar'),
        );

  final LocalStorage _storage;

  Future<void> setLocale(Locale locale) async {
    await _storage.setString(StorageKeys.preferredLocale, locale.languageCode);
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(localStorageProvider);
  return LocaleNotifier(storage);
});
