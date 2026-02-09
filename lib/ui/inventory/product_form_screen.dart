import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';
import '../sales/scanner_screen.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _unitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _salePriceController;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _unitController = TextEditingController(text: product?.unit ?? 'unit');
    _quantityController = TextEditingController(
      text: product?.quantity.toString() ?? '0',
    );
    _purchasePriceController = TextEditingController(
      text: product?.purchasePrice.toString() ?? '0',
    );
    _salePriceController = TextEditingController(
      text: product?.salePrice.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) => double.tryParse(value) ?? 0;

  Future<void> _save(AppState state) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final product = Product(
      id: widget.product?.id ?? nowMs.toString(),
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim(),
      unit: _unitController.text.trim(),
      quantity: _parseDouble(_quantityController.text),
      purchasePrice: _parseDouble(_purchasePriceController.text),
      salePrice: _parseDouble(_salePriceController.text),
      createdAtMs: widget.product?.createdAtMs ?? nowMs,
    );

    await state.upsertProduct(product);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _delete(AppState state) async {
    final id = widget.product?.id;
    if (id == null) return;
    await state.deleteProduct(id);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(state),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(labelText: 'Barcode'),
                    ),
                  ),
                  if (state.scanMode) ...[
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(builder: (_) => const ScannerScreen()),
                        );
                        if (result != null) {
                          _barcodeController.text = result;
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g. unit, kg)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(labelText: 'Purchase price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(labelText: 'Sale price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(state),
                child: Text(_isEditing ? 'Save changes' : 'Add product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
