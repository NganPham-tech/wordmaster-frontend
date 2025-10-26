import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data/mysql_helper.dart';

class CategoryProvider with ChangeNotifier {
  final MySQLHelper _mysqlHelper = MySQLHelper();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;

    try {
      _categories = await _mysqlHelper.getAllCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(Category category) async {
    _setLoading(true);
    _error = null;

    try {
      final categoryId = await _mysqlHelper.insertCategory(category);
      final newCategory = category.copyWith(categoryID: categoryId);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding category: $e');
    } finally {
      _setLoading(false);
    }
  }

  Category? getCategoryById(int? categoryId) {
    if (categoryId == null) return null;
    try {
      return _categories.firstWhere(
        (category) => category.categoryID == categoryId,
      );
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
