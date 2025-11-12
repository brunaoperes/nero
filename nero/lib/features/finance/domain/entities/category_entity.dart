import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';

/// Entidade que representa uma categoria de transação
@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String id,
    required String name,
    required String icon,
    required String color,
    required CategoryType type,
    required bool isDefault,
    String? userId, // null se for categoria padrão do sistema
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CategoryEntity;
}

/// Tipo de categoria (para receitas ou despesas)
enum CategoryType {
  income,
  expense,
  both,
}

/// Extensão para CategoryType
extension CategoryTypeExtension on CategoryType {
  String toJson() {
    switch (this) {
      case CategoryType.income:
        return 'income';
      case CategoryType.expense:
        return 'expense';
      case CategoryType.both:
        return 'both';
    }
  }

  static CategoryType fromJson(String json) {
    switch (json) {
      case 'income':
        return CategoryType.income;
      case 'expense':
        return CategoryType.expense;
      case 'both':
        return CategoryType.both;
      default:
        return CategoryType.both;
    }
  }
}

/// Categorias padrão do sistema
class DefaultCategories {
  // Categorias de Despesas
  static const List<Map<String, String>> expenses = [
    {'name': 'Alimentação', 'icon': '🍔', 'color': 'FF6B6B'},
    {'name': 'Transporte', 'icon': '🚗', 'color': '4ECDC4'},
    {'name': 'Moradia', 'icon': '🏠', 'color': '95E1D3'},
    {'name': 'Saúde', 'icon': '🏥', 'color': 'F38181'},
    {'name': 'Educação', 'icon': '📚', 'color': 'AA96DA'},
    {'name': 'Lazer', 'icon': '🎮', 'color': 'FCBAD3'},
    {'name': 'Vestuário', 'icon': '👕', 'color': 'FFFFD2'},
    {'name': 'Beleza', 'icon': '💄', 'color': 'FFB6C1'},
    {'name': 'Compras', 'icon': '🛒', 'color': 'DDA15E'},
    {'name': 'Contas', 'icon': '📄', 'color': 'BC6C25'},
    {'name': 'Impostos', 'icon': '💼', 'color': '606C38'},
    {'name': 'Investimentos', 'icon': '📈', 'color': '283618'},
    {'name': 'Outros', 'icon': '📦', 'color': '999999'},
  ];

  // Categorias de Receitas
  static const List<Map<String, String>> incomes = [
    {'name': 'Salário', 'icon': '💵', 'color': '06D6A0'},
    {'name': 'Freelance', 'icon': '💻', 'color': '118AB2'},
    {'name': 'Investimentos', 'icon': '📊', 'color': '073B4C'},
    {'name': 'Vendas', 'icon': '💳', 'color': 'EF476F'},
    {'name': 'Aluguel', 'icon': '🏘️', 'color': 'FFD166'},
    {'name': 'Presente', 'icon': '🎁', 'color': '06FFA5'},
    {'name': 'Reembolso', 'icon': '💰', 'color': '26547C'},
    {'name': 'Outros', 'icon': '📥', 'color': '999999'},
  ];
}
