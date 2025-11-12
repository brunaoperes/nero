import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar categorias de despesas
final expenseCategoriesProvider = StateNotifierProvider<CategoriesNotifier, List<String>>((ref) {
  return CategoriesNotifier('expense_categories', [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Vestuário',
    'Outros',
  ]);
});

/// Provider para gerenciar categorias de receitas
final incomeCategoriesProvider = StateNotifierProvider<CategoriesNotifier, List<String>>((ref) {
  return CategoriesNotifier('income_categories', [
    'Salário',
    'Freelance',
    'Investimentos',
    'Vendas',
    'Outros',
  ]);
});

/// Notifier para gerenciar categorias
class CategoriesNotifier extends StateNotifier<List<String>> {
  final String _key;
  final List<String> _defaultCategories;

  CategoriesNotifier(this._key, this._defaultCategories) : super(_defaultCategories) {
    _loadCategories();
  }

  /// Carrega categorias do SharedPreferences
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key);
      if (saved != null && saved.isNotEmpty) {
        state = saved;
      }
    } catch (e) {
      print('[CategoriesNotifier] Erro ao carregar categorias: $e');
    }
  }

  /// Salva categorias no SharedPreferences
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state);
    } catch (e) {
      print('[CategoriesNotifier] Erro ao salvar categorias: $e');
    }
  }

  /// Adiciona uma nova categoria
  Future<void> addCategory(String category) async {
    if (category.trim().isEmpty) return;
    if (state.contains(category.trim())) return;

    state = [...state, category.trim()];
    await _saveCategories();
  }

  /// Remove uma categoria
  Future<void> removeCategory(String category) async {
    state = state.where((c) => c != category).toList();
    await _saveCategories();
  }

  /// Edita uma categoria
  Future<void> editCategory(String oldCategory, String newCategory) async {
    if (newCategory.trim().isEmpty) return;
    if (state.contains(newCategory.trim()) && oldCategory != newCategory) return;

    final index = state.indexOf(oldCategory);
    if (index == -1) return;

    final newList = [...state];
    newList[index] = newCategory.trim();
    state = newList;
    await _saveCategories();
  }

  /// Restaura categorias padrão
  Future<void> restoreDefaults() async {
    state = _defaultCategories;
    await _saveCategories();
  }
}
