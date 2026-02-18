import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _submitBarcode(AppState state) {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final product = state.findProductByBarcode(barcode);
    if (product != null) {
      Navigator.pop<Product>(context, product);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product not found')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                hintText: 'Enter barcode manually',
              ),
              onSubmitted: (_) => _submitBarcode(state),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _submitBarcode(state),
              child: const Text('Find Product'),
            ),
          ],
        ),
      ),
    );
  }
}
