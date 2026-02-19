import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/storage/storage_keys.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(localStorageProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.welcomeToMusayyer)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.runStoreWithConfidence,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.onboardingDescription,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(l10n.offlineFirst),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(l10n.secureAuth),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(l10n.modularArchitecture),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () async {
                await storage.setBool(StorageKeys.onboardingDone, true);
                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: Text(l10n.getStarted),
            ),
          ],
        ),
      ),
    );
  }
}
