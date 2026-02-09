import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';

class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._storage) : super(_storage.getOnboardingComplete());

  final LocalStorage _storage;

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingComplete();
    state = true;
  }
}

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, bool>((ref) {
  final storage = ref.watch(localStorageProvider);
  return OnboardingController(storage);
});
