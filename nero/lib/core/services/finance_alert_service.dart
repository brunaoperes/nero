import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Serviço responsável por gerenciar alertas financeiros
/// Notifica sobre gastos, metas, orçamentos e anomalias
class FinanceAlertService {
  static final FinanceAlertService _instance = FinanceAlertService._internal();
  factory FinanceAlertService() => _instance;
  FinanceAlertService._internal();

  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger();

  // Prefixos para IDs de notificação
  static const int _financeAlertIdPrefix = 3000000;
  static const int _budgetAlertIdPrefix = 4000000;
  static const int _goalAlertIdPrefix = 5000000;

  /// Envia alerta de gasto acima da média
  Future<void> sendHighSpendingAlert({
    required double amount,
    required String category,
    required double averageAmount,
  }) async {
    try {
      final percentageAbove = ((amount - averageAmount) / averageAmount * 100).toStringAsFixed(0);

      await _notificationService.showNotification(
        id: _financeAlertIdPrefix + 1,
        title: '💰 Gasto Acima da Média',
        body: 'Você gastou R\$ ${amount.toStringAsFixed(2)} em $category '
            '($percentageAbove% acima da média)',
        payload: 'finance_high_spending',
        priority: NotificationPriority.high,
      );

      _logger.i('Alerta de gasto alto enviado: $category - R\$ $amount');
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de gasto alto', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de orçamento excedido
  Future<void> sendBudgetExceededAlert({
    required String category,
    required double budgetLimit,
    required double currentAmount,
  }) async {
    try {
      final percentageUsed = (currentAmount / budgetLimit * 100).toStringAsFixed(0);

      await _notificationService.showNotification(
        id: _budgetAlertIdPrefix + category.hashCode.abs() % 1000000,
        title: '⚠️ Orçamento Excedido!',
        body: '$category: R\$ ${currentAmount.toStringAsFixed(2)} '
            'de R\$ ${budgetLimit.toStringAsFixed(2)} ($percentageUsed%)',
        payload: 'finance_budget_exceeded_$category',
        priority: NotificationPriority.high,
      );

      _logger.i('Alerta de orçamento excedido enviado: $category');
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de orçamento excedido', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de orçamento próximo do limite
  Future<void> sendBudgetWarningAlert({
    required String category,
    required double budgetLimit,
    required double currentAmount,
    double warningThreshold = 0.8, // 80% do orçamento
  }) async {
    try {
      final percentageUsed = (currentAmount / budgetLimit * 100).toStringAsFixed(0);

      if (currentAmount >= budgetLimit * warningThreshold) {
        await _notificationService.showNotification(
          id: _budgetAlertIdPrefix + category.hashCode.abs() % 1000000,
          title: '⚡ Atenção: Orçamento',
          body: '$category: Você já usou $percentageUsed% do orçamento',
          payload: 'finance_budget_warning_$category',
          priority: NotificationPriority.normal,
        );

        _logger.i('Alerta de orçamento próximo do limite enviado: $category');
      }
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de orçamento', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de meta atingida
  Future<void> sendGoalAchievedAlert({
    required String goalName,
    required double goalAmount,
  }) async {
    try {
      await _notificationService.showNotification(
        id: _goalAlertIdPrefix + goalName.hashCode.abs() % 1000000,
        title: '🎉 Meta Atingida!',
        body: 'Parabéns! Você atingiu a meta "$goalName" '
            'de R\$ ${goalAmount.toStringAsFixed(2)}',
        payload: 'finance_goal_achieved_$goalName',
        priority: NotificationPriority.normal,
      );

      _logger.i('Alerta de meta atingida enviado: $goalName');
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de meta atingida', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de meta próxima de ser atingida
  Future<void> sendGoalProgressAlert({
    required String goalName,
    required double goalAmount,
    required double currentAmount,
    double progressThreshold = 0.9, // 90% da meta
  }) async {
    try {
      final percentageAchieved = (currentAmount / goalAmount * 100).toStringAsFixed(0);

      if (currentAmount >= goalAmount * progressThreshold) {
        await _notificationService.showNotification(
          id: _goalAlertIdPrefix + goalName.hashCode.abs() % 1000000,
          title: '🎯 Quase lá!',
          body: 'Meta "$goalName": $percentageAchieved% concluída!',
          payload: 'finance_goal_progress_$goalName',
          priority: NotificationPriority.normal,
        );

        _logger.i('Alerta de progresso de meta enviado: $goalName');
      }
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de progresso', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de despesa recorrente próxima
  Future<void> sendRecurringExpenseReminder({
    required String expenseName,
    required double amount,
    required DateTime dueDate,
  }) async {
    try {
      final daysUntil = dueDate.difference(DateTime.now()).inDays;

      String dueDateText;
      if (daysUntil == 0) {
        dueDateText = 'hoje';
      } else if (daysUntil == 1) {
        dueDateText = 'amanhã';
      } else {
        dueDateText = 'em $daysUntil dias';
      }

      await _notificationService.showNotification(
        id: _financeAlertIdPrefix + expenseName.hashCode.abs() % 1000000,
        title: '📅 Despesa Recorrente',
        body: '$expenseName (R\$ ${amount.toStringAsFixed(2)}) vence $dueDateText',
        payload: 'finance_recurring_expense_$expenseName',
        priority: daysUntil <= 1 ? NotificationPriority.high : NotificationPriority.normal,
      );

      _logger.i('Lembrete de despesa recorrente enviado: $expenseName');
    } catch (e, stack) {
      _logger.e('Erro ao enviar lembrete de despesa', error: e, stackTrace: stack);
    }
  }

  /// Envia resumo financeiro mensal
  Future<void> sendMonthlySummary({
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> topCategories,
  }) async {
    try {
      final balance = totalIncome - totalExpenses;
      final balanceText = balance >= 0 ? 'Saldo positivo' : 'Déficit';

      // Construir texto das principais categorias
      final categoriesText = topCategories.entries
          .take(3)
          .map((e) => '${e.key}: R\$ ${e.value.toStringAsFixed(2)}')
          .join(' • ');

      await _notificationService.showNotification(
        id: _financeAlertIdPrefix + 999,
        title: '📊 Resumo Financeiro do Mês',
        body: '$balanceText: R\$ ${balance.abs().toStringAsFixed(2)}\n'
            'Principais gastos: $categoriesText',
        payload: 'finance_monthly_summary',
        priority: NotificationPriority.normal,
      );

      _logger.i('Resumo financeiro mensal enviado');
    } catch (e, stack) {
      _logger.e('Erro ao enviar resumo mensal', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de gasto incomum (anomalia detectada pela IA)
  Future<void> sendUnusualSpendingAlert({
    required double amount,
    required String category,
    required String reason,
  }) async {
    try {
      await _notificationService.showNotification(
        id: _financeAlertIdPrefix + 2,
        title: '🔍 Gasto Incomum Detectado',
        body: 'R\$ ${amount.toStringAsFixed(2)} em $category - $reason',
        payload: 'finance_unusual_spending',
        priority: NotificationPriority.high,
      );

      _logger.i('Alerta de gasto incomum enviado: $category');
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de gasto incomum', error: e, stackTrace: stack);
    }
  }

  /// Envia alerta de economia (gastos abaixo da média)
  Future<void> sendSavingsAlert({
    required double savedAmount,
    required String period,
  }) async {
    try {
      await _notificationService.showNotification(
        id: _financeAlertIdPrefix + 3,
        title: '💎 Você está economizando!',
        body: 'Você economizou R\$ ${savedAmount.toStringAsFixed(2)} $period',
        payload: 'finance_savings',
        priority: NotificationPriority.normal,
      );

      _logger.i('Alerta de economia enviado: R\$ $savedAmount');
    } catch (e, stack) {
      _logger.e('Erro ao enviar alerta de economia', error: e, stackTrace: stack);
    }
  }

  /// Agenda lembrete de revisão financeira semanal
  Future<void> scheduleWeeklyReview() async {
    try {
      await _notificationService.schedulePeriodicNotification(
        id: _financeAlertIdPrefix + 1000,
        title: '📅 Revisão Financeira Semanal',
        body: 'Que tal revisar suas finanças da semana?',
        repeatInterval: RepeatInterval.weekly,
        payload: 'finance_weekly_review',
        priority: NotificationPriority.normal,
      );

      _logger.i('Lembrete semanal de revisão financeira agendado');
    } catch (e, stack) {
      _logger.e('Erro ao agendar revisão semanal', error: e, stackTrace: stack);
    }
  }

  /// Cancela um alerta específico
  Future<void> cancelAlert(int alertId) async {
    try {
      await _notificationService.cancelNotification(alertId);
      _logger.i('Alerta financeiro cancelado: $alertId');
    } catch (e, stack) {
      _logger.e('Erro ao cancelar alerta', error: e, stackTrace: stack);
    }
  }

  /// Cancela todos os alertas financeiros
  Future<void> cancelAllAlerts() async {
    try {
      // Cancelar apenas alertas financeiros (baseado nos prefixos)
      final pending = await _notificationService.getPendingNotifications();

      for (final notification in pending) {
        if (notification.id >= _financeAlertIdPrefix &&
            notification.id < _financeAlertIdPrefix + 1000000) {
          await _notificationService.cancelNotification(notification.id);
        }
      }

      _logger.i('Todos os alertas financeiros cancelados');
    } catch (e, stack) {
      _logger.e('Erro ao cancelar todos os alertas', error: e, stackTrace: stack);
    }
  }

  // Configurações de alertas (salvas no SharedPreferences)

  /// Salva configuração de alertas de orçamento
  Future<void> saveBudgetAlertConfig({
    required bool enabled,
    required double warningThreshold,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('budget_alerts_enabled', enabled);
      await prefs.setDouble('budget_warning_threshold', warningThreshold);
      _logger.d('Configuração de alertas de orçamento salva');
    } catch (e) {
      _logger.e('Erro ao salvar config de alertas', error: e);
    }
  }

  /// Obtém configuração de alertas de orçamento
  Future<Map<String, dynamic>> getBudgetAlertConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'enabled': prefs.getBool('budget_alerts_enabled') ?? true,
        'warningThreshold': prefs.getDouble('budget_warning_threshold') ?? 0.8,
      };
    } catch (e) {
      _logger.e('Erro ao obter config de alertas', error: e);
      return {'enabled': true, 'warningThreshold': 0.8};
    }
  }
}
