import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';
import '../services/image_upload_service.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _price;

  int? _categoryId;
  bool _loading = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  static const String _baseUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.product?.name);
    _description = TextEditingController(text: widget.product?.description);
    _price = TextEditingController(text: widget.product?.price.toString());
    _categoryId = widget.product?.categoryId;
  }

  // IMAGE PICKER
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      String? imagePath = widget.product?.imageUrl;

      if (_selectedImage != null) {
        imagePath = await ImageUploadService.uploadImage(_selectedImage!);
      }

      if (widget.product == null) {
        await ProductService.createProduct(
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: double.parse(_price.text),
          imageUrl: imagePath,
          categoryId: _categoryId!,
        );
      } else {
        await ProductService.updateProduct(
          id: widget.product!.id,
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: double.parse(_price.text),
          imageUrl: imagePath,
          categoryId: _categoryId!,
        );
      }

      ref.read(productProvider.notifier).loadProducts();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoryProvider).categories;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.product == null ? 'Create Product' : 'Edit Product',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                // IMAGE PREVIEW
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          height: 160,
                          fit: BoxFit.cover,
                        )
                      : widget.product?.imageUrl != null &&
                            widget.product!.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: '$_baseUrl/${widget.product!.imageUrl}',
                          height: 160,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const SizedBox(
                            height: 160,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),

                const SizedBox(height: 12),

                // PICK IMAGE
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: const Text(
                      'SELECT IMAGE',
                      style: TextStyle(letterSpacing: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _InputField(
                  controller: _name,
                  label: 'Name',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

                _InputField(controller: _description, label: 'Description'),

                _InputField(
                  controller: _price,
                  label: 'Price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

                DropdownButtonFormField<int>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Select category' : null,
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    height: 48,
                    alignment: Alignment.center,
                    color: Colors.black,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 160,
      color: Colors.grey.shade200,
      child: const Icon(Icons.menu_book, size: 48, color: Colors.grey),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
