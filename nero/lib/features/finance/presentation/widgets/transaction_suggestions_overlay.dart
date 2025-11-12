import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/models/transaction_suggestion_model.dart';
import 'package:intl/intl.dart';

/// Overlay de sugestões de transações para autocomplete
///
/// Exibe até 5 sugestões baseadas na query do usuário,
/// com opção de preencher automaticamente os campos.
class TransactionSuggestionsOverlay extends StatelessWidget {
  final List<TransactionSuggestion> suggestions;
  final Function(TransactionSuggestion, {bool includeAmount}) onSuggestionSelected;
  final String currentQuery;

  const TransactionSuggestionsOverlay({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
    required this.currentQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    debugPrint('🟣 [OVERLAY WIDGET] Build com ${suggestions.length} sugestões');

    // Não mostrar overlay se não há sugestões
    if (suggestions.isEmpty) {
      debugPrint('🟣 [OVERLAY WIDGET] Lista vazia, retornando SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8.0,
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: suggestions
                .map((suggestion) => _buildSuggestionItem(
                      context,
                      suggestion,
                      isDark,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    TransactionSuggestion suggestion,
    bool isDark,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final hasAmount = suggestion.lastAmount != null && suggestion.lastAmount! > 0;

    return GestureDetector(
      onTapDown: (_) {
        debugPrint('🟡 [TOQUE] onTapDown chamado para: ${suggestion.description}');
        onSuggestionSelected(suggestion, includeAmount: false);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Ícone da categoria
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getCategoryColor(suggestion.category).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(suggestion.category),
                size: 16,
                color: _getCategoryColor(suggestion.category),
              ),
            ),
            const SizedBox(width: 12),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Text(
                    suggestion.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Categoria • Conta
                  Text(
                    _buildSubtitle(suggestion),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Valor + chip "preencher valor também"
            if (hasAmount) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(suggestion.lastAmount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Chip para preencher valor também
                  GestureDetector(
                    onTapDown: (_) {
                      debugPrint('🟡 [TOQUE] onTapDown no chip +valor para: ${suggestion.description}');
                      onSuggestionSelected(suggestion, includeAmount: true);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'valor',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(TransactionSuggestion suggestion) {
    final parts = <String>[];
    if (suggestion.category != null && suggestion.category!.isNotEmpty) {
      parts.add(suggestion.category!);
    }
    if (suggestion.account != null && suggestion.account!.isNotEmpty) {
      parts.add(suggestion.account!);
    }
    return parts.isEmpty ? 'Sem informações' : parts.join(' • ');
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
        return const Color(0xFFFF6B6B);
      case 'transporte':
        return const Color(0xFF4ECDC4);
      case 'moradia':
        return const Color(0xFF95E1D3);
      case 'saúde':
        return const Color(0xFFFF8B94);
      case 'educação':
        return const Color(0xFF5F9DF7);
      case 'lazer':
        return const Color(0xFFFFA07A);
      case 'vestuário':
        return const Color(0xFFDDA15E);
      case 'salário':
        return const Color(0xFF06C46B);
      case 'freelance':
        return const Color(0xFF7B68EE);
      case 'investimentos':
        return const Color(0xFF20B2AA);
      case 'vendas':
        return const Color(0xFF32CD32);
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'moradia':
        return Icons.home;
      case 'saúde':
        return Icons.local_hospital;
      case 'educação':
        return Icons.school;
      case 'lazer':
        return Icons.sports_esports;
      case 'vestuário':
        return Icons.shopping_bag;
      case 'salário':
        return Icons.attach_money;
      case 'freelance':
        return Icons.work;
      case 'investimentos':
        return Icons.trending_up;
      case 'vendas':
        return Icons.point_of_sale;
      default:
        return Icons.category;
    }
  }
}
