import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/product_model.dart';
import '../theme/app_colors.dart';

class ReceiveFromProductionController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final finishedProduct = Rxn<Product>();
  final quantityReceived = ''.obs;
  final remarks = ''.obs;

  final products = <Product>[].obs;
  final unitTypes = <String>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    _loadUnitTypes();
  }

  Future<void> _loadProducts() async {
    try {
      isLoading.value = true;
      final uri = Uri.parse('${ApiConfig.products}?limit=50');
      debugPrint('[RECEIVE] GET $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        _showError('Failed to load products (${response.statusCode})');
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['success'] == false) {
        throw Exception(decoded['message'] ?? 'API error');
      }

      final List data = decoded['data'] ?? [];
      products.value = data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      debugPrint('[RECEIVE] Loaded ${products.length} products');
    } catch (e, st) {
      debugPrint('[RECEIVE] Error: $e\n$st');
      _showError('Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUnitTypes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.unitTypes),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final List types = data['data'] ?? [];
          unitTypes.value = types.cast<String>();
        }
      }
    } catch (e) {
      unitTypes.value = ['KG', 'PCS', 'LTR', 'MTR', 'GM', 'ML'];
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.length < 2) {
      await _loadProducts();
      return;
    }
    try {
      final url =
          '${ApiConfig.products}?search=${Uri.encodeComponent(query)}&limit=100';
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true) {
          final List data = decoded['data'] ?? [];
          products.value = data
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[RECEIVE] Search error: $e');
    }
  }

  void setFinishedProduct(Product? product) => finishedProduct.value = product;
  void setQuantityReceived(String value) => quantityReceived.value = value;
  void setRemarks(String value) => remarks.value = value;

  bool _validateForm() {
    if (!formKey.currentState!.validate()) return false;
    if (finishedProduct.value == null) {
      _showError('Please select finished product');
      return false;
    }
    final qty = double.tryParse(quantityReceived.value);
    if (qty == null || qty <= 0) {
      _showError('Please enter valid quantity received');
      return false;
    }
    return true;
  }

  Future<void> saveDraft() async {
    if (!_validateForm()) return;
    isSaving.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      _showSuccess('Receive record saved as draft');
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> confirmReceive() async {
    if (!_validateForm()) return;
    isSaving.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      _showSuccess('Production receive recorded');
    } catch (e) {
      _showError('Failed to record receive: $e');
    } finally {
      isSaving.value = false;
    }
  }
}

void _showSuccess(String message) {
  Get.snackbar(
    'Success',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.primary,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 8,
  );
}

void _showError(String message) {
  Get.snackbar(
    'Error',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 8,
  );
}
