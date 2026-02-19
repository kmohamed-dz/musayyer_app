import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/storage/storage_keys.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _shopNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final storage = ref.read(localStorageProvider);
    _shopNameController.text = storage.getString(StorageKeys.shopName) ?? '';
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final storage = ref.read(localStorageProvider);
    await storage.setString(StorageKeys.shopName, _shopNameController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.save)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.arabic),
                  selected: locale.languageCode == 'ar',
                  onSelected: (_) => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
                ),
                ChoiceChip(
                  label: Text(l10n.french),
                  selected: locale.languageCode == 'fr',
                  onSelected: (_) => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                labelText: l10n.shopName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ),
            const SizedBox(height: 16),
            Text('${l10n.appVersion}: 1.0.0+1'),
          ],
        ),
      ),
    );
  }
}
