import 'dart:io';
import '../../shared/models/task_model.dart';

/// Serviço para geração de relatórios em PDF
///
/// NOTA: Este é um stub temporário enquanto o package PDF é reinstalado
/// Para habilitar a funcionalidade completa, execute:
/// ```
/// flutter pub cache repair
/// flutter pub get
/// ```
/// E restaure o arquivo pdf_service.dart.disabled
class PDFService {
  /// Gera relatório de tarefas em PDF
  static Future<File> generateTasksReport({
    required List<TaskModel> tasks,
    required String title,
    String? period,
    Map<String, String>? filters,
  }) async {
    throw UnimplementedError(
      'PDF Service está temporariamente desabilitado.\n'
      'Execute: flutter pub cache repair && flutter pub get\n'
      'Depois restaure o arquivo pdf_service.dart.disabled'
    );
  }

  /// Gera relatório financeiro em PDF
  static Future<File> generateFinanceReport({
    required List<Map<String, dynamic>> transactions,
    required double totalIncome,
    required double totalExpenses,
    required double balance,
    required String title,
    String? period,
    Map<String, String>? filters,
  }) async {
    throw UnimplementedError(
      'PDF Service está temporariamente desabilitado.\n'
      'Execute: flutter pub cache repair && flutter pub get\n'
      'Depois restaure o arquivo pdf_service.dart.disabled'
    );
  }

  /// Gera relatório consolidado (tarefas + finanças)
  static Future<File> generateConsolidatedReport({
    required List<TaskModel> tasks,
    required List<Map<String, dynamic>> transactions,
    required double totalIncome,
    required double totalExpenses,
    required double balance,
    required String title,
    String? period,
  }) async {
    throw UnimplementedError(
      'PDF Service está temporariamente desabilitado.\n'
      'Execute: flutter pub cache repair && flutter pub get\n'
      'Depois restaure o arquivo pdf_service.dart.disabled'
    );
  }
}
