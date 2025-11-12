import '../../shared/models/bank_account_model.dart';
import '../../shared/models/transaction_model.dart';

/// Serviço para cálculo de saldo corrente das contas bancárias
class BalanceCalculatorService {
  /// Calcula o saldo corrente de uma conta baseado em:
  /// - opening_balance (saldo de abertura)
  /// - Transações pagas (is_paid = true) até agora
  ///
  /// Fórmula:
  /// saldo_corrente = opening_balance
  ///                  + somatório(receitas PAGAS)
  ///                  - somatório(despesas PAGAS)
  ///                  + somatório(transferências_entrada PAGAS)
  ///                  - somatório(transferências_saida PAGAS)
  static double calculateAccountBalance({
    required BankAccountModel account,
    required List<TransactionModel> allTransactions,
  }) {
    // Começar com o saldo de abertura
    double balance = account.openingBalance;

    // Filtrar transações dessa conta que estão pagas
    final accountTransactions = allTransactions.where((t) {
      // Considerar apenas transações pagas
      if (!t.isPaid) return false;

      // Considerar apenas transações dessa conta
      // Para income e expense: t.account
      // Para transfer: t.account (origem) ou t.destinationAccount (destino)
      return t.account == account.name ||
             (t.type == 'transfer' && t.destinationAccount == account.name);
    }).toList();

    // Calcular impacto de cada transação
    for (final transaction in accountTransactions) {
      switch (transaction.type) {
        case 'income':
          // Receita: aumenta o saldo
          balance += transaction.amount;
          break;

        case 'expense':
          // Despesa: diminui o saldo
          balance -= transaction.amount;
          break;

        case 'transfer':
          // Transferência: precisa verificar se é entrada ou saída
          if (transaction.account == account.name) {
            // Saída: diminui o saldo (origem da transferência)
            balance -= transaction.amount;
          } else if (transaction.destinationAccount == account.name) {
            // Entrada: aumenta o saldo (destino da transferência)
            balance += transaction.amount;
          }
          break;
      }
    }

    return balance;
  }

  /// Calcula o saldo atual global somando todas as contas visíveis
  ///
  /// Regras:
  /// - Considera apenas contas com isHiddenBalance = false
  /// - Usa o saldo corrente de cada conta (já calculado)
  /// - Transferências se cancelam automaticamente (saem de uma e entram em outra)
  static double calculateTotalBalance({
    required List<BankAccountModel> accounts,
    required List<TransactionModel> allTransactions,
  }) {
    double totalBalance = 0.0;

    // Somar saldo corrente de cada conta visível
    for (final account in accounts) {
      // Pular contas ocultas
      if (account.isHiddenBalance) continue;

      // Calcular e somar o saldo corrente desta conta
      final accountBalance = calculateAccountBalance(
        account: account,
        allTransactions: allTransactions,
      );

      totalBalance += accountBalance;
    }

    return totalBalance;
  }

  /// Calcula totais de entradas e saídas do período (para o card de resumo)
  ///
  /// Regras:
  /// - Considera apenas transações pagas (is_paid = true)
  /// - Filtra pelo período especificado
  /// - Ignora transferências (não afetam entradas/saídas globais)
  static Map<String, double> calculatePeriodTotals({
    required List<TransactionModel> allTransactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final transaction in allTransactions) {
      // Considerar apenas transações pagas
      if (!transaction.isPaid) continue;

      // Considerar apenas transações do período
      final transactionDate = transaction.paidAt ?? transaction.date ?? DateTime.now();
      if (transactionDate.isBefore(startDate) || transactionDate.isAfter(endDate)) {
        continue;
      }

      // Ignorar transferências (não afetam entradas/saídas globais)
      if (transaction.type == 'transfer') continue;

      // Somar receitas e despesas
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpense += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }
}
