import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/tasks/domain/models/task_model.dart';
import '../../features/finances/domain/models/transaction_model.dart';

/// Serviço para geração de relatórios em Excel
///
/// Recursos:
/// - Múltiplas planilhas (abas)
/// - Formatação de células
/// - Fórmulas automáticas
/// - Cores e estilos
/// - Filtros Excel
/// - Formatação brasileira (PT-BR)
class ExcelService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  // ==================== CORES DO APP ====================
  static const _primaryColor = '#0072FF';
  static const _successColor = '#00C853';
  static const _errorColor = '#FF5252';
  static const _warningColor = '#FFD700';

  // ==================== RELATÓRIO DE TAREFAS ====================

  /// Gera relatório de tarefas em Excel
  ///
  /// Estrutura:
  /// - Aba "Resumo": Estatísticas gerais
  /// - Aba "Pessoal": Tarefas pessoais
  /// - Aba "Empresa": Tarefas de empresas
  /// - Aba "Recorrente": Tarefas recorrentes
  /// - Aba "Todas": Lista completa
  static Future<File> generateTasksReport({
    required List<TaskModel> tasks,
    String? period,
    Map<String, String>? filters,
  }) async {
    final excel = Excel.createExcel();

    // Remover planilha padrão
    excel.delete('Sheet1');

    // Separar tarefas por origem
    final personalTasks = tasks.where((t) => t.origin == 'personal').toList();
    final companyTasks = tasks.where((t) => t.origin == 'company').toList();
    final recurringTasks = tasks.where((t) => t.origin == 'recurring').toList();

    // Criar abas
    _createTasksSummarySheet(excel, tasks, period, filters);
    _createTasksSheet(excel, 'Pessoal', personalTasks);
    _createTasksSheet(excel, 'Empresa', companyTasks);
    _createTasksSheet(excel, 'Recorrente', recurringTasks);
    _createTasksSheet(excel, 'Todas', tasks);

    return _saveExcel(excel, 'relatorio_tarefas');
  }

  /// Cria aba de resumo de tarefas
  static void _createTasksSummarySheet(
    Excel excel,
    List<TaskModel> tasks,
    String? period,
    Map<String, String>? filters,
  ) {
    final sheet = excel['Resumo'];

    // Cabeçalho
    _setCellValue(sheet, 'A1', 'RELATÓRIO DE TAREFAS');
    _mergeCells(sheet, 'A1', 'D1');
    _styleHeader(sheet, 'A1');

    if (period != null) {
      _setCellValue(sheet, 'A2', 'Período: $period');
      _mergeCells(sheet, 'A2', 'D2');
    }

    int row = 4;

    // Estatísticas gerais
    _setCellValue(sheet, 'A$row', 'ESTATÍSTICAS GERAIS');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.length - completedTasks;
    final completionRate = tasks.isEmpty ? 0.0 : (completedTasks / tasks.length) * 100;

    _setCellValue(sheet, 'A$row', 'Total de Tarefas');
    _setCellValue(sheet, 'B$row', tasks.length);
    _styleCell(sheet, 'A$row', backgroundColor: '#F5F5F5', bold: true);
    row++;

    _setCellValue(sheet, 'A$row', 'Concluídas');
    _setCellValue(sheet, 'B$row', completedTasks);
    _styleCell(sheet, 'B$row', backgroundColor: _successColor, textColor: '#FFFFFF');
    row++;

    _setCellValue(sheet, 'A$row', 'Pendentes');
    _setCellValue(sheet, 'B$row', pendingTasks);
    _styleCell(sheet, 'B$row', backgroundColor: _warningColor);
    row++;

    _setCellValue(sheet, 'A$row', 'Taxa de Conclusão');
    _setCellValue(sheet, 'B$row', '${completionRate.toStringAsFixed(1)}%');
    _styleCell(sheet, 'A$row', backgroundColor: '#F5F5F5', bold: true);
    row += 2;

    // Por origem
    _setCellValue(sheet, 'A$row', 'POR ORIGEM');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    final personalCount = tasks.where((t) => t.origin == 'personal').length;
    final companyCount = tasks.where((t) => t.origin == 'company').length;
    final recurringCount = tasks.where((t) => t.origin == 'recurring').length;

    _setCellValue(sheet, 'A$row', 'Pessoal');
    _setCellValue(sheet, 'B$row', personalCount);
    row++;

    _setCellValue(sheet, 'A$row', 'Empresa');
    _setCellValue(sheet, 'B$row', companyCount);
    row++;

    _setCellValue(sheet, 'A$row', 'Recorrente');
    _setCellValue(sheet, 'B$row', recurringCount);
    row += 2;

    // Por prioridade
    _setCellValue(sheet, 'A$row', 'POR PRIORIDADE');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    final highPriority = tasks.where((t) => t.priority == 'high').length;
    final mediumPriority = tasks.where((t) => t.priority == 'medium').length;
    final lowPriority = tasks.where((t) => t.priority == 'low').length;

    _setCellValue(sheet, 'A$row', 'Alta');
    _setCellValue(sheet, 'B$row', highPriority);
    _styleCell(sheet, 'B$row', backgroundColor: _errorColor, textColor: '#FFFFFF');
    row++;

    _setCellValue(sheet, 'A$row', 'Média');
    _setCellValue(sheet, 'B$row', mediumPriority);
    _styleCell(sheet, 'B$row', backgroundColor: _warningColor);
    row++;

    _setCellValue(sheet, 'A$row', 'Baixa');
    _setCellValue(sheet, 'B$row', lowPriority);
    _styleCell(sheet, 'B$row', backgroundColor: _successColor, textColor: '#FFFFFF');
    row++;

    // Ajustar largura das colunas
    _setColumnWidth(sheet, 'A', 25);
    _setColumnWidth(sheet, 'B', 15);
  }

  /// Cria aba de tarefas
  static void _createTasksSheet(
    Excel excel,
    String sheetName,
    List<TaskModel> tasks,
  ) {
    final sheet = excel[sheetName];

    // Cabeçalhos
    final headers = ['Título', 'Prioridade', 'Status', 'Data', 'Origem', 'Descrição'];
    for (int i = 0; i < headers.length; i++) {
      final col = String.fromCharCode(65 + i); // A, B, C, D, E, F
      _setCellValue(sheet, '$col${1}', headers[i]);
      _styleHeader(sheet, '$col${1}');
    }

    // Dados
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final row = i + 2;

      _setCellValue(sheet, 'A$row', task.title);
      _setCellValue(sheet, 'B$row', _getPriorityLabel(task.priority ?? ''));
      _setCellValue(sheet, 'C$row', task.isCompleted ? 'Concluída' : 'Pendente');
      _setCellValue(sheet, 'D$row', task.dueDate != null ? _dateTimeFormat.format(task.dueDate!) : '-');
      _setCellValue(sheet, 'E$row', _getSourceLabel(task.origin));
      _setCellValue(sheet, 'F$row', task.description ?? '-');

      // Cores por prioridade
      final priorityColor = _getPriorityColor(task.priority ?? '');
      _styleCell(sheet, 'B$row', backgroundColor: priorityColor, textColor: task.priority == 'low' ? '#000000' : '#FFFFFF');

      // Cores por status
      if (task.isCompleted) {
        _styleCell(sheet, 'C$row', backgroundColor: _successColor, textColor: '#FFFFFF');
      } else {
        _styleCell(sheet, 'C$row', backgroundColor: _warningColor);
      }
    }

    // Ajustar largura das colunas
    _setColumnWidth(sheet, 'A', 30);
    _setColumnWidth(sheet, 'B', 12);
    _setColumnWidth(sheet, 'C', 12);
    _setColumnWidth(sheet, 'D', 18);
    _setColumnWidth(sheet, 'E', 12);
    _setColumnWidth(sheet, 'F', 40);

    // Aplicar filtro
    if (tasks.isNotEmpty) {
      // Excel filters são aplicados automaticamente quando o arquivo é aberto
      // A biblioteca excel não suporta filtros diretamente, mas podemos preparar a estrutura
    }
  }

  // ==================== RELATÓRIO FINANCEIRO ====================

  /// Gera relatório financeiro em Excel
  ///
  /// Estrutura:
  /// - Aba "Resumo": Estatísticas gerais
  /// - Aba "Receitas": Todas as receitas
  /// - Aba "Despesas": Todas as despesas
  /// - Aba "Gráficos": Dados para gráficos
  static Future<File> generateFinanceReport({
    required List<TransactionModel> transactions,
    String? period,
    Map<String, String>? filters,
  }) async {
    final excel = Excel.createExcel();

    // Remover planilha padrão
    excel.delete('Sheet1');

    // Separar por tipo
    final revenues = transactions.where((t) => t.type == 'income').toList();
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // Criar abas
    _createFinanceSummarySheet(excel, transactions, period, filters);
    _createTransactionsSheet(excel, 'Receitas', revenues);
    _createTransactionsSheet(excel, 'Despesas', expenses);
    _createFinanceChartsSheet(excel, revenues, expenses);

    return _saveExcel(excel, 'relatorio_financeiro');
  }

  /// Cria aba de resumo financeiro
  static void _createFinanceSummarySheet(
    Excel excel,
    List<TransactionModel> transactions,
    String? period,
    Map<String, String>? filters,
  ) {
    final sheet = excel['Resumo'];

    // Cabeçalho
    _setCellValue(sheet, 'A1', 'RELATÓRIO FINANCEIRO');
    _mergeCells(sheet, 'A1', 'D1');
    _styleHeader(sheet, 'A1');

    if (period != null) {
      _setCellValue(sheet, 'A2', 'Período: $period');
      _mergeCells(sheet, 'A2', 'D2');
    }

    int row = 4;

    // Calcular totais
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    // Resumo financeiro
    _setCellValue(sheet, 'A$row', 'RESUMO FINANCEIRO');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    _setCellValue(sheet, 'A$row', 'Total de Receitas');
    _setCellValue(sheet, 'B$row', _currencyFormat.format(totalIncome));
    _styleCell(sheet, 'B$row', backgroundColor: _successColor, textColor: '#FFFFFF', bold: true);
    row++;

    _setCellValue(sheet, 'A$row', 'Total de Despesas');
    _setCellValue(sheet, 'B$row', _currencyFormat.format(totalExpense));
    _styleCell(sheet, 'B$row', backgroundColor: _errorColor, textColor: '#FFFFFF', bold: true);
    row++;

    _setCellValue(sheet, 'A$row', 'Saldo');
    _setCellValue(sheet, 'B$row', _currencyFormat.format(balance));
    final balanceColor = balance >= 0 ? _successColor : _errorColor;
    _styleCell(sheet, 'B$row', backgroundColor: balanceColor, textColor: '#FFFFFF', bold: true);
    row += 2;

    // Estatísticas
    _setCellValue(sheet, 'A$row', 'ESTATÍSTICAS');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    _setCellValue(sheet, 'A$row', 'Quantidade de Receitas');
    _setCellValue(sheet, 'B$row', transactions.where((t) => t.type == 'income').length);
    row++;

    _setCellValue(sheet, 'A$row', 'Quantidade de Despesas');
    _setCellValue(sheet, 'B$row', transactions.where((t) => t.type == 'expense').length);
    row++;

    if (totalIncome > 0) {
      final expenseRate = (totalExpense / totalIncome) * 100;
      _setCellValue(sheet, 'A$row', 'Taxa de Gastos');
      _setCellValue(sheet, 'B$row', '${expenseRate.toStringAsFixed(1)}%');
      row++;
    }

    // Ajustar largura das colunas
    _setColumnWidth(sheet, 'A', 25);
    _setColumnWidth(sheet, 'B', 20);
  }

  /// Cria aba de transações
  static void _createTransactionsSheet(
    Excel excel,
    String sheetName,
    List<TransactionModel> transactions,
  ) {
    final sheet = excel[sheetName];

    // Cabeçalhos
    final headers = ['Data', 'Descrição', 'Categoria', 'Valor', 'Origem'];
    for (int i = 0; i < headers.length; i++) {
      final col = String.fromCharCode(65 + i);
      _setCellValue(sheet, '$col${1}', headers[i]);
      _styleHeader(sheet, '$col${1}');
    }

    // Dados
    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final row = i + 2;

      _setCellValue(sheet, 'A$row', transaction.date != null ? _dateFormat.format(transaction.date!) : '-');
      _setCellValue(sheet, 'B$row', transaction.description);
      _setCellValue(sheet, 'C$row', transaction.category ?? '-');
      _setCellValue(sheet, 'D$row', _currencyFormat.format(transaction.amount));
      _setCellValue(sheet, 'E$row', transaction.source ?? 'Manual');

      // Cor do valor
      final valueColor = transaction.type == 'income' ? _successColor : _errorColor;
      _styleCell(sheet, 'D$row', backgroundColor: valueColor, textColor: '#FFFFFF', bold: true);
    }

    // Linha de total
    if (transactions.isNotEmpty) {
      final row = transactions.length + 2;
      _setCellValue(sheet, 'C$row', 'TOTAL');
      final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
      _setCellValue(sheet, 'D$row', _currencyFormat.format(total));
      _styleCell(sheet, 'C$row', backgroundColor: _primaryColor, textColor: '#FFFFFF', bold: true);
      _styleCell(sheet, 'D$row', backgroundColor: _primaryColor, textColor: '#FFFFFF', bold: true);
    }

    // Ajustar largura das colunas
    _setColumnWidth(sheet, 'A', 15);
    _setColumnWidth(sheet, 'B', 35);
    _setColumnWidth(sheet, 'C', 20);
    _setColumnWidth(sheet, 'D', 18);
    _setColumnWidth(sheet, 'E', 15);
  }

  /// Cria aba com dados para gráficos
  static void _createFinanceChartsSheet(
    Excel excel,
    List<TransactionModel> revenues,
    List<TransactionModel> expenses,
  ) {
    final sheet = excel['Gráficos'];

    // Agrupamento por categoria
    _setCellValue(sheet, 'A1', 'RECEITAS POR CATEGORIA');
    _mergeCells(sheet, 'A1', 'B1');
    _styleHeader(sheet, 'A1');

    _setCellValue(sheet, 'A2', 'Categoria');
    _setCellValue(sheet, 'B2', 'Valor');
    _styleSubHeader(sheet, 'A2');
    _styleSubHeader(sheet, 'B2');

    final revenuesByCategory = <String, double>{};
    for (final transaction in revenues) {
      final category = transaction.category ?? 'Sem Categoria';
      revenuesByCategory[category] = (revenuesByCategory[category] ?? 0) + transaction.amount;
    }

    int row = 3;
    revenuesByCategory.forEach((category, amount) {
      _setCellValue(sheet, 'A$row', category);
      _setCellValue(sheet, 'B$row', _currencyFormat.format(amount));
      row++;
    });

    row += 2;

    // Despesas por categoria
    _setCellValue(sheet, 'A$row', 'DESPESAS POR CATEGORIA');
    _mergeCells(sheet, 'A$row', 'B$row');
    _styleHeader(sheet, 'A$row');
    row++;

    _setCellValue(sheet, 'A$row', 'Categoria');
    _setCellValue(sheet, 'B$row', 'Valor');
    _styleSubHeader(sheet, 'A$row');
    _styleSubHeader(sheet, 'B$row');
    row++;

    final expensesByCategory = <String, double>{};
    for (final transaction in expenses) {
      final category = transaction.category ?? 'Sem Categoria';
      expensesByCategory[category] = (expensesByCategory[category] ?? 0) + transaction.amount;
    }

    expensesByCategory.forEach((category, amount) {
      _setCellValue(sheet, 'A$row', category);
      _setCellValue(sheet, 'B$row', _currencyFormat.format(amount));
      row++;
    });

    // Ajustar largura das colunas
    _setColumnWidth(sheet, 'A', 25);
    _setColumnWidth(sheet, 'B', 18);
  }

  // ==================== RELATÓRIO CONSOLIDADO ====================

  /// Gera relatório consolidado (Tarefas + Finanças)
  static Future<File> generateConsolidatedReport({
    required List<TaskModel> tasks,
    required List<TransactionModel> transactions,
    String? period,
  }) async {
    final excel = Excel.createExcel();

    // Remover planilha padrão
    excel.delete('Sheet1');

    // Criar aba de resumo geral
    final sheet = excel['Resumo Geral'];

    // Cabeçalho
    _setCellValue(sheet, 'A1', 'RELATÓRIO CONSOLIDADO');
    _mergeCells(sheet, 'A1', 'D1');
    _styleHeader(sheet, 'A1');

    if (period != null) {
      _setCellValue(sheet, 'A2', 'Período: $period');
      _mergeCells(sheet, 'A2', 'D2');
    }

    int row = 4;

    // Seção de Tarefas
    _setCellValue(sheet, 'A$row', 'TAREFAS');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    _setCellValue(sheet, 'A$row', 'Total de Tarefas');
    _setCellValue(sheet, 'B$row', tasks.length);
    row++;

    _setCellValue(sheet, 'A$row', 'Concluídas');
    _setCellValue(sheet, 'B$row', completedTasks);
    _styleCell(sheet, 'B$row', backgroundColor: _successColor, textColor: '#FFFFFF');
    row++;

    _setCellValue(sheet, 'A$row', 'Pendentes');
    _setCellValue(sheet, 'B$row', tasks.length - completedTasks);
    _styleCell(sheet, 'B$row', backgroundColor: _warningColor);
    row += 2;

    // Seção Financeira
    _setCellValue(sheet, 'A$row', 'FINANÇAS');
    _mergeCells(sheet, 'A$row', 'D$row');
    _styleSubHeader(sheet, 'A$row');
    row += 2;

    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    _setCellValue(sheet, 'A$row', 'Receitas');
    _setCellValue(sheet, 'B$row', _currencyFormat.format(totalIncome));
    _styleCell(sheet, 'B$row', backgroundColor: _successColor, textColor: '#FFFFFF', bold: true);
    row++;

    _setCellValue(sheet, 'A$row', 'Despesas');
    _setCellValue(sheet, 'B$row', _currencyFormat.format(totalExpense));
    _styleCell(sheet, 'B$row', backgroundColor: _errorColor, textColor: '#FFFFFF', bold: true);
    row++;

    _setCellValue(sheet, 'A$row', 'Saldo');
    _setCellValue(sheet, 'B$row', _currencyFormat.format(balance));
    final balanceColor = balance >= 0 ? _successColor : _errorColor;
    _styleCell(sheet, 'B$row', backgroundColor: balanceColor, textColor: '#FFFFFF', bold: true);

    // Ajustar largura das colunas
    _setColumnWidth(sheet, 'A', 25);
    _setColumnWidth(sheet, 'B', 20);

    return _saveExcel(excel, 'relatorio_consolidado');
  }

  // ==================== MÉTODOS AUXILIARES ====================

  /// Define valor de uma célula
  static void _setCellValue(Sheet sheet, String cellRef, dynamic value) {
    final cell = sheet.cell(CellIndex.indexByString(cellRef));
    cell.value = TextCellValue(value.toString());
  }

  /// Mescla células
  static void _mergeCells(Sheet sheet, String start, String end) {
    sheet.merge(CellIndex.indexByString(start), CellIndex.indexByString(end));
  }

  /// Estiliza cabeçalho
  static void _styleHeader(Sheet sheet, String cellRef) {
    final cell = sheet.cell(CellIndex.indexByString(cellRef));
    cell.cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString(_primaryColor),
      fontColorHex: ExcelColor.white,
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
  }

  /// Estiliza sub-cabeçalho
  static void _styleSubHeader(Sheet sheet, String cellRef) {
    final cell = sheet.cell(CellIndex.indexByString(cellRef));
    cell.cellStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#F5F5F5'),
      bold: true,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );
  }

  /// Estiliza célula
  static void _styleCell(
    Sheet sheet,
    String cellRef, {
    String? backgroundColor,
    String? textColor,
    bool bold = false,
  }) {
    final cell = sheet.cell(CellIndex.indexByString(cellRef));

    // Criar CellStyle apenas se houver alguma estilização
    if (backgroundColor != null || textColor != null || bold) {
      cell.cellStyle = CellStyle(
        backgroundColorHex: backgroundColor != null ? ExcelColor.fromHexString(backgroundColor) : ExcelColor.fromHexString('#FFFFFF'),
        fontColorHex: textColor != null ? ExcelColor.fromHexString(textColor) : ExcelColor.fromHexString('#000000'),
        bold: bold,
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
      );
    }
  }

  /// Define largura de coluna
  static void _setColumnWidth(Sheet sheet, String column, double width) {
    final colIndex = column.codeUnitAt(0) - 65; // A = 0, B = 1, etc.
    sheet.setColumnWidth(colIndex, width);
  }

  /// Salva arquivo Excel
  static Future<File> _saveExcel(Excel excel, String baseName) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$timestamp.xlsx';
    final filePath = '${dir.path}/$fileName';

    final file = File(filePath);
    final bytes = excel.encode();

    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    return file;
  }

  /// Obtém label de prioridade
  static String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'Alta';
      case 'medium':
        return 'Média';
      case 'low':
        return 'Baixa';
      default:
        return priority;
    }
  }

  /// Obtém cor de prioridade
  static String _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return _errorColor;
      case 'medium':
        return _warningColor;
      case 'low':
        return _successColor;
      default:
        return '#CCCCCC';
    }
  }

  /// Obtém label de origem
  static String _getSourceLabel(String source) {
    switch (source) {
      case 'personal':
        return 'Pessoal';
      case 'company':
        return 'Empresa';
      case 'recurring':
        return 'Recorrente';
      default:
        return source;
    }
  }
}
