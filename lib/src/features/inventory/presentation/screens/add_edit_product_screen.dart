import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  const AddEditProductScreen({
    super.key,
    this.productId,
  });

  final String? productId;

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameArController = TextEditingController();
  final _nameFrController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');
  final _categoryController = TextEditingController();
  final _barcodeController = TextEditingController();

  Product? _existingProduct;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProductIfNeeded();
  }

  Future<void> _loadProductIfNeeded() async {
    if (widget.productId == null) {
      return;
    }

    final product = await ref.read(productRepositoryProvider).getProductById(widget.productId!);
    if (product == null || !mounted) {
      return;
    }

    setState(() {
      _existingProduct = product;
      _nameArController.text = product.nameAr;
      _nameFrController.text = product.nameFr;
      _priceController.text = product.price.toString();
      _costPriceController.text = product.costPrice.toString();
      _stockController.text = product.stock.toString();
      _unitController.text = product.unit;
      _categoryController.text = product.category ?? '';
      _barcodeController.text = product.barcode ?? '';
    });
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameFrController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result == null || result.isEmpty || !mounted) {
      return;
    }
    setState(() {
      _barcodeController.text = result;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final product = Product(
      id: _existingProduct?.id ?? const Uuid().v4(),
      name: _nameFrController.text.trim().isEmpty
          ? _nameArController.text.trim()
          : _nameFrController.text.trim(),
      nameAr: _nameArController.text.trim(),
      nameFr: _nameFrController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      costPrice: double.parse(_costPriceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      imagePath: _existingProduct?.imagePath,
      unit: _unitController.text.trim(),
      createdAt: _existingProduct?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(productsProvider.notifier);
    if (_existingProduct == null) {
      await notifier.addProduct(product);
    } else {
      await notifier.updateProduct(product);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                controller: _nameArController,
                label: 'Name (AR)',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _nameFrController,
                label: 'Name (FR)',
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _priceController,
                label: 'Price (DZD)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null || price <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _costPriceController,
                label: 'Cost Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final cost = double.tryParse(value ?? '');
                  if (cost == null || cost < 0) {
                    return 'Cost price must be valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _stockController,
                label: 'Stock Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final stock = int.tryParse(value ?? '');
                  if (stock == null || stock < 0) {
                    return 'Stock must be 0 or more';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _unitController,
                label: 'Unit',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unit is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _categoryController,
                label: 'Category',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _barcodeController,
                      label: 'Barcode',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
