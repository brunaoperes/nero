import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../shared/models/transaction_model.dart';

/// Serviço para exportação de relatórios financeiros
class ReportExportService {
  /// Exporta relatório em PDF
  Future<File> exportToPDF({
    required List<TransactionModel> transactions,
    required Map<String, dynamic> stats,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relatório Financeiro - Nero',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Período: ${startDate != null ? dateFormat.format(startDate) : 'Início'} - ${endDate != null ? dateFormat.format(endDate) : 'Hoje'}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Gerado em: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Resumo
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Resumo Financeiro',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total de Receitas:'),
                    pw.Text(
                      currencyFormat.format(stats['total_income'] ?? 0),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total de Despesas:'),
                    pw.Text(
                      currencyFormat.format(stats['total_expense'] ?? 0),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Divider(),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Saldo:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      currencyFormat.format(stats['balance'] ?? 0),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: (stats['balance'] ?? 0) >= 0
                            ? PdfColors.green
                            : PdfColors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Tabela de transações
          pw.Text(
            'Transações',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Cabeçalho
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Data', isHeader: true),
                  _buildTableCell('Tipo', isHeader: true),
                  _buildTableCell('Categoria', isHeader: true),
                  _buildTableCell('Descrição', isHeader: true),
                  _buildTableCell('Valor', isHeader: true),
                ],
              ),
              // Dados
              ...transactions.map((transaction) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(
                      transaction.date != null
                          ? dateFormat.format(transaction.date!)
                          : '-',
                    ),
                    _buildTableCell(
                      transaction.type == 'income' ? 'Receita' : 'Despesa',
                    ),
                    _buildTableCell(transaction.category ?? '-'),
                    _buildTableCell(
                      transaction.description ?? '-',
                      maxLines: 2,
                    ),
                    _buildTableCell(
                      currencyFormat.format(transaction.amount),
                      align: pw.TextAlign.right,
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    // Salva o PDF
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/relatorio_financeiro_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Exporta relatório em Excel
  Future<File> exportToExcel({
    required List<TransactionModel> transactions,
    required Map<String, dynamic> stats,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Relatório'];
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');

    // Cabeçalho
    sheet.appendRow([
      TextCellValue('Relatório Financeiro - Nero'),
    ]);
    sheet.appendRow([
      TextCellValue('Período: ${startDate != null ? dateFormat.format(startDate) : 'Início'} - ${endDate != null ? dateFormat.format(endDate) : 'Hoje'}'),
    ]);
    sheet.appendRow([
      TextCellValue('Gerado em: ${dateFormat.format(DateTime.now())}'),
    ]);
    sheet.appendRow([]); // Linha vazia

    // Resumo
    sheet.appendRow([TextCellValue('Resumo Financeiro')]);
    sheet.appendRow([
      TextCellValue('Total de Receitas:'),
      TextCellValue(currencyFormat.format(stats['total_income'] ?? 0)),
    ]);
    sheet.appendRow([
      TextCellValue('Total de Despesas:'),
      TextCellValue(currencyFormat.format(stats['total_expense'] ?? 0)),
    ]);
    sheet.appendRow([
      TextCellValue('Saldo:'),
      TextCellValue(currencyFormat.format(stats['balance'] ?? 0)),
    ]);
    sheet.appendRow([]); // Linha vazia

    // Cabeçalho da tabela de transações
    sheet.appendRow([
      TextCellValue('Transações'),
    ]);
    sheet.appendRow([
      TextCellValue('Data'),
      TextCellValue('Tipo'),
      TextCellValue('Categoria'),
      TextCellValue('Descrição'),
      TextCellValue('Valor'),
    ]);

    // Dados das transações
    for (final transaction in transactions) {
      sheet.appendRow([
        TextCellValue(
          transaction.date != null
              ? dateFormat.format(transaction.date!)
              : '-',
        ),
        TextCellValue(transaction.type == 'income' ? 'Receita' : 'Despesa'),
        TextCellValue(transaction.category ?? '-'),
        TextCellValue(transaction.description ?? '-'),
        TextCellValue(currencyFormat.format(transaction.amount)),
      ]);
    }

    // Salva o Excel
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/relatorio_financeiro_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  /// Helper para criar células da tabela PDF
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    int maxLines = 1,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        maxLines: maxLines,
        overflow: pw.TextOverflow.clip,
        textAlign: align,
      ),
    );
  }
}
