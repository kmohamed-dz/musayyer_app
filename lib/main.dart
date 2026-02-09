import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'ui/inventory/inventory_screen.dart';

Future<void> main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MusayyerApp(),
    ),
  );
}

class MusayyerApp extends StatelessWidget {
  const MusayyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musayyer',
      theme: ThemeData(useMaterial3: true),
      home: const InventoryScreen(),
    );
  }
}
