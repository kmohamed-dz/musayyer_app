import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _hasPermission = true;
  bool _isHandling = false;
  String? _lastNotFound;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: _hasPermission
          ? MobileScanner(
              onDetect: (capture) async {
                if (_isHandling) return;
                if (capture.barcodes.isEmpty) return;
                final barcode = capture.barcodes.first.rawValue;
                if (barcode == null || barcode.isEmpty) return;

                final product = state.findProductByBarcode(barcode);
                if (product != null) {
                  _isHandling = true;
                  if (mounted) {
                    Navigator.pop<Product>(context, product);
                  }
                } else if (_lastNotFound != barcode) {
                  _lastNotFound = barcode;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product not found')),
                  );
                }
              },
              onPermissionSet: (_, permission) {
                if (!permission) {
                  setState(() {
                    _hasPermission = false;
                  });
                }
              },
            )
          : const Center(
              child: Text('Camera permission denied. Please enable it in settings.'),
            ),
    );
  }
}
