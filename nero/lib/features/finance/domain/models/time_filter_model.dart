/// Tipos de intervalo de filtro temporal
enum IntervaloFiltro {
  mes,          // Filtro por mês (padrão)
  hoje,         // Hoje (00:00 - 23:59:59)
  ult7,         // Últimos 7 dias
  ult30,        // Últimos 30 dias
  anoAtual,     // Ano atual (01/01 - 31/12)
  personalizado // Período personalizado
}

/// Modelo de filtro temporal para transações
class FiltroTempo {
  final IntervaloFiltro tipo;
  final DateTime start;
  final DateTime end;

  const FiltroTempo({
    required this.tipo,
    required this.start,
    required this.end,
  });

  /// Cria filtro para o mês especificado
  factory FiltroTempo.mes(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1)
        .subtract(const Duration(microseconds: 1));

    return FiltroTempo(
      tipo: IntervaloFiltro.mes,
      start: start,
      end: end,
    );
  }

  /// Cria filtro para hoje
  factory FiltroTempo.hoje() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);

    return FiltroTempo(
      tipo: IntervaloFiltro.hoje,
      start: start,
      end: end,
    );
  }

  /// Cria filtro para últimos 7 dias
  factory FiltroTempo.ultimos7Dias() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
    final start = DateTime(now.year, now.month, now.day - 6);

    return FiltroTempo(
      tipo: IntervaloFiltro.ult7,
      start: start,
      end: end,
    );
  }

  /// Cria filtro para últimos 30 dias
  factory FiltroTempo.ultimos30Dias() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
    final start = DateTime(now.year, now.month, now.day - 29);

    return FiltroTempo(
      tipo: IntervaloFiltro.ult30,
      start: start,
      end: end,
    );
  }

  /// Cria filtro para o ano atual
  factory FiltroTempo.anoAtual() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1); // 01/01 00:00:00
    final end = DateTime(now.year, 12, 31, 23, 59, 59, 999, 999); // 31/12 23:59:59.999999

    return FiltroTempo(
      tipo: IntervaloFiltro.anoAtual,
      start: start,
      end: end,
    );
  }

  /// Cria filtro personalizado
  factory FiltroTempo.personalizado({
    required DateTime start,
    required DateTime end,
  }) {
    return FiltroTempo(
      tipo: IntervaloFiltro.personalizado,
      start: start,
      end: end,
    );
  }

  /// Label curto para exibir no badge
  String get badgeLabel {
    switch (tipo) {
      case IntervaloFiltro.hoje:
        return 'Hoje';
      case IntervaloFiltro.ult7:
        return '7d';
      case IntervaloFiltro.ult30:
        return '30d';
      case IntervaloFiltro.anoAtual:
        return 'Ano';
      case IntervaloFiltro.personalizado:
        return 'Per.';
      case IntervaloFiltro.mes:
        return '';
    }
  }

  /// Descrição completa para exibir no menu
  String get descricao {
    switch (tipo) {
      case IntervaloFiltro.hoje:
        return 'Apenas transações de hoje';
      case IntervaloFiltro.ult7:
        return 'Últimos 7 dias (incluindo hoje)';
      case IntervaloFiltro.ult30:
        return 'Últimos 30 dias (incluindo hoje)';
      case IntervaloFiltro.anoAtual:
        return 'Transações do ano atual';
      case IntervaloFiltro.personalizado:
        return 'Intervalo personalizado';
      case IntervaloFiltro.mes:
        return 'Filtro por mês';
    }
  }

  /// Converte para JSON para persistência
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo.index,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    };
  }

  /// Cria a partir de JSON
  factory FiltroTempo.fromJson(Map<String, dynamic> json) {
    return FiltroTempo(
      tipo: IntervaloFiltro.values[json['tipo'] as int],
      start: DateTime.fromMillisecondsSinceEpoch(json['start'] as int),
      end: DateTime.fromMillisecondsSinceEpoch(json['end'] as int),
    );
  }

  @override
  String toString() => 'FiltroTempo(tipo: $tipo, start: $start, end: $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiltroTempo &&
          runtimeType == other.runtimeType &&
          tipo == other.tipo &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => tipo.hashCode ^ start.hashCode ^ end.hashCode;
}
