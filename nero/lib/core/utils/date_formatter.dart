import 'package:intl/intl.dart';

/// Utilitário para formatação de datas relativas (estilo Organizze)
class DateFormatter {
  /// Formata uma data de forma relativa:
  /// - "hoje" para data atual
  /// - "amanhã" para D+1
  /// - "ontem" para D-1
  /// - "segunda", "terça", etc. para próximos 7 dias
  /// - "15 de novembro" para datas mais distantes
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    // Hoje
    if (difference == 0) {
      return 'hoje';
    }

    // Amanhã
    if (difference == 1) {
      return 'amanhã';
    }

    // Ontem
    if (difference == -1) {
      return 'ontem';
    }

    // Próximos 7 dias (exibir dia da semana)
    if (difference > 1 && difference <= 7) {
      return _getWeekdayName(date.weekday);
    }

    // Últimos 7 dias (exibir dia da semana)
    if (difference < -1 && difference >= -7) {
      return _getWeekdayName(date.weekday);
    }

    // Datas mais distantes (formato "15 de novembro")
    return DateFormat('d \'de\' MMMM', 'pt_BR').format(date);
  }

  /// Retorna o nome do dia da semana em minúsculas
  static String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'segunda';
      case DateTime.tuesday:
        return 'terça';
      case DateTime.wednesday:
        return 'quarta';
      case DateTime.thursday:
        return 'quinta';
      case DateTime.friday:
        return 'sexta';
      case DateTime.saturday:
        return 'sábado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return '';
    }
  }

  /// Retorna o texto de status de pagamento baseado no tipo e estado isPaid
  /// - Despesa paga: "pago"
  /// - Despesa não paga: "não pago"
  /// - Receita paga: "recebido"
  /// - Receita não paga: "não recebido"
  static String getPaymentStatusText(String type, bool isPaid) {
    if (type == 'expense') {
      return isPaid ? 'pago' : 'não pago';
    } else if (type == 'income') {
      return isPaid ? 'recebido' : 'não recebido';
    } else {
      // Transferências sempre são consideradas pagas
      return 'concluído';
    }
  }

  /// Formata data para exibição completa (ex: "15 de novembro de 2025")
  static String formatFullDate(DateTime date) {
    return DateFormat('d \'de\' MMMM \'de\' yyyy', 'pt_BR').format(date);
  }

  /// Formata data curta (ex: "15/11/2025")
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }
}
