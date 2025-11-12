import 'package:intl/intl.dart';
import '../../features/finance/domain/models/transaction_group_model.dart';
import '../../shared/models/transaction_model.dart';
import './date_formatter.dart';

/// Utilitários para agrupamento de transações por data
class TransactionGroupingUtils {
  /// Agrupa transações por data e retorna lista ordenada de grupos
  static List<TransactionGroup> groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    if (transactions.isEmpty) {
      return [];
    }

    // Agrupar por data (sem hora)
    final Map<DateTime, List<TransactionModel>> groupedMap = {};

    for (final transaction in transactions) {
      final date = transaction.date ?? DateTime.now();
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (!groupedMap.containsKey(dateOnly)) {
        groupedMap[dateOnly] = [];
      }
      groupedMap[dateOnly]!.add(transaction);
    }

    // Ordenar transações dentro de cada grupo por timestamp (desc)
    groupedMap.forEach((date, items) {
      items.sort((a, b) {
        final dateA = a.createdAt ?? a.date ?? DateTime.now();
        final dateB = b.createdAt ?? b.date ?? DateTime.now();
        return dateB.compareTo(dateA); // Mais recente primeiro
      });
    });

    // Criar grupos e ordenar por data (desc)
    final groups = groupedMap.entries.map((entry) {
      return TransactionGroup(
        date: entry.key,
        label: formatDateLabel(entry.key),
        transactions: entry.value,
      );
    }).toList();

    // Ordenar grupos por data (mais recente primeiro)
    groups.sort((a, b) => b.date.compareTo(a.date));

    return groups;
  }

  /// Formata label da data: "hoje", "amanhã", "ontem", "segunda", "12 de novembro"
  static String formatDateLabel(DateTime date) {
    return DateFormatter.formatRelativeDate(date);
  }

  /// Formata label da data com ano se for de outro ano
  static String formatDateLabelWithYear(DateTime date) {
    final now = DateTime.now();
    final sameYear = date.year == now.year;

    if (sameYear) {
      return formatDateLabel(date);
    } else {
      // Formato: "12 de novembro de 2024"
      final formatter = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');
      return formatter.format(date);
    }
  }

  /// Agrupa transações por mês (para visão anual)
  static Map<String, List<TransactionModel>> groupTransactionsByMonth(
    List<TransactionModel> transactions,
  ) {
    final Map<String, List<TransactionModel>> groupedMap = {};

    for (final transaction in transactions) {
      final date = transaction.date ?? DateTime.now();
      final monthKey = DateFormat('MMMM y', 'pt_BR').format(date);

      if (!groupedMap.containsKey(monthKey)) {
        groupedMap[monthKey] = [];
      }
      groupedMap[monthKey]!.add(transaction);
    }

    // Ordenar transações dentro de cada mês
    groupedMap.forEach((month, items) {
      items.sort((a, b) {
        final dateA = a.date ?? DateTime.now();
        final dateB = b.date ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
    });

    return groupedMap;
  }
}
