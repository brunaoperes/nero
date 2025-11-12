# 🔔 GUIA DE NOTIFICAÇÕES - NERO

**Versão**: 1.0
**Data**: Janeiro 2025
**Status**: ✅ Implementado

---

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Tipos de Notificações](#tipos-de-notificações)
4. [Como Usar](#como-usar)
5. [Configuração](#configuração)
6. [Testes](#testes)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 VISÃO GERAL

O sistema de notificações do Nero foi projetado para manter os usuários informados sobre:

- ⏰ **Lembretes de Tarefas**: Notificações antes das tarefas agendadas
- 💰 **Alertas Financeiros**: Gastos acima da média, orçamentos excedidos
- 🎯 **Metas Atingidas**: Celebração quando metas financeiras são alcançadas
- 📅 **Reuniões**: Lembretes de reuniões empresariais
- 🤖 **Recomendações IA**: Sugestões personalizadas do assistente

### Tecnologias Utilizadas

- **flutter_local_notifications**: Notificações locais (iOS/Android)
- **Firebase Cloud Messaging (FCM)**: Push notifications remotas
- **Supabase**: Armazenamento de histórico de notificações
- **Riverpod**: Gerenciamento de estado

---

## 🏗️ ARQUITETURA

```
lib/
├── core/services/
│   ├── notification_service.dart       # Notificações locais
│   ├── fcm_service.dart                # Push notifications (FCM)
│   ├── task_reminder_service.dart      # Lembretes de tarefas
│   └── finance_alert_service.dart      # Alertas financeiros
│
└── features/notifications/
    ├── data/
    │   ├── datasources/
    │   │   └── notification_remote_datasource.dart
    │   ├── models/
    │   │   └── notification_model.dart
    │   └── repositories/
    │       └── notification_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── notification_entity.dart
    │   ├── repositories/
    │   │   └── notification_repository.dart
    │   └── usecases/
    │       ├── get_notifications.dart
    │       └── mark_as_read.dart
    └── presentation/
        ├── pages/
        │   ├── notifications_page.dart
        │   └── notification_settings_page.dart
        ├── providers/
        │   └── notification_providers.dart
        └── widgets/
            └── notification_card.dart
```

---

## 🔔 TIPOS DE NOTIFICAÇÕES

### 1. Lembretes de Tarefas

**Serviço**: `TaskReminderService`

```dart
import 'package:nero/core/services/task_reminder_service.dart';

final reminderService = TaskReminderService();

// Agendar lembrete 15 minutos antes da tarefa
await reminderService.scheduleTaskReminder(
  task: taskEntity,
  minutesBefore: 15,
);

// Múltiplos lembretes (1 dia, 1 hora, 15 min antes)
await reminderService.scheduleMultipleReminders(
  task: taskEntity,
  minutesList: [1440, 60, 15],
);

// Lembrete para tarefa atrasada
await reminderService.scheduleOverdueTaskNotification(taskEntity);

// Resumo diário
await reminderService.scheduleDailySummary(
  totalTasks: 10,
  completedTasks: 7,
  pendingTasks: 2,
  overdueTasks: 1,
);
```

### 2. Alertas Financeiros

**Serviço**: `FinanceAlertService`

```dart
import 'package:nero/core/services/finance_alert_service.dart';

final alertService = FinanceAlertService();

// Alerta de gasto acima da média
await alertService.sendHighSpendingAlert(
  amount: 500.0,
  category: 'Alimentação',
  averageAmount: 300.0,
);

// Alerta de orçamento excedido
await alertService.sendBudgetExceededAlert(
  category: 'Transporte',
  budgetLimit: 400.0,
  currentAmount: 450.0,
);

// Alerta de meta atingida
await alertService.sendGoalAchievedAlert(
  goalName: 'Economizar R$ 1000',
  goalAmount: 1000.0,
);

// Lembrete de despesa recorrente
await alertService.sendRecurringExpenseReminder(
  expenseName: 'Aluguel',
  amount: 1500.0,
  dueDate: DateTime.now().add(Duration(days: 3)),
);

// Resumo mensal
await alertService.sendMonthlySummary(
  totalIncome: 5000.0,
  totalExpenses: 3500.0,
  topCategories: {
    'Alimentação': 800.0,
    'Transporte': 500.0,
    'Lazer': 400.0,
  },
);
```

### 3. Notificações Remotas (FCM)

**Serviço**: `FCMService`

```dart
import 'package:nero/core/services/fcm_service.dart';

final fcmService = FCMService();

// Inicializar (já feito no main.dart)
await fcmService.initialize();

// Obter token FCM
final token = fcmService.fcmToken;
print('FCM Token: $token');

// Inscrever em tópico
await fcmService.subscribeToTopic('finance_alerts');

// Desinscrever de tópico
await fcmService.unsubscribeFromTopic('finance_alerts');

// Deletar token (útil no logout)
await fcmService.deleteToken();
```

---

## 🎨 COMO USAR

### 1. Exibir Lista de Notificações

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nero/features/notifications/presentation/pages/notifications_page.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsPage(),
          ),
        );
      },
      child: Text('Ver Notificações'),
    );
  }
}
```

### 2. Mostrar Badge de Notificações Não Lidas

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nero/features/notifications/presentation/providers/notification_providers.dart';

class NotificationBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return unreadCount.when(
      data: (count) => count > 0
          ? Badge(
              label: Text('$count'),
              child: Icon(Icons.notifications),
            )
          : Icon(Icons.notifications),
      loading: () => Icon(Icons.notifications),
      error: (_, __) => Icon(Icons.notifications),
    );
  }
}
```

### 3. Marcar Notificação como Lida

```dart
// No NotificationCard, ao tocar
await ref
    .read(notificationControllerProvider.notifier)
    .markAsRead(notification.id);

// Refresh da lista
ref.invalidate(notificationsProvider);
ref.invalidate(unreadCountProvider);
```

### 4. Criar Notificação Programaticamente

```dart
final repository = ref.read(notificationRepositoryProvider);
final userId = Supabase.instance.client.auth.currentUser!.id;

await repository.createNotification(
  userId: userId,
  title: 'Nova Tarefa Criada',
  body: 'Você criou a tarefa: Ligar para cliente',
  type: NotificationType.taskReminder,
  payload: 'task_123',
);
```

---

## ⚙️ CONFIGURAÇÃO

### 1. Configurar Firebase

**IMPORTANTE**: Antes de usar push notifications, siga o guia completo:

📄 **Ver arquivo**: `FIREBASE_SETUP.md`

Resumo rápido:
1. Criar projeto no Firebase Console
2. Adicionar app Android e baixar `google-services.json`
3. Adicionar app iOS e baixar `GoogleService-Info.plist`
4. Configurar `build.gradle` e `AndroidManifest.xml`
5. Executar `flutter pub get`

### 2. Executar SQL no Supabase

Acesse o Supabase Dashboard e execute o SQL:

📄 **Ver arquivo**: `supabase/migrations/notifications_table.sql`

Este SQL cria:
- Tabela `notifications`
- Tabela `user_devices` (para FCM tokens)
- Índices para performance
- Políticas de RLS
- Funções auxiliares

### 3. Configurações do Usuário

O app salva as preferências de notificação no `SharedPreferences`:

| Chave | Tipo | Padrão | Descrição |
|-------|------|--------|-----------|
| `task_reminders_enabled` | bool | true | Ativar lembretes de tarefas |
| `finance_alerts_enabled` | bool | true | Ativar alertas financeiros |
| `meeting_reminders_enabled` | bool | true | Ativar lembretes de reuniões |
| `ai_recommendations_enabled` | bool | true | Ativar recomendações da IA |
| `daily_summary_enabled` | bool | true | Ativar resumo diário |
| `default_reminder_minutes` | int | 15 | Tempo padrão de lembrete |

Acessar tela de configurações:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => NotificationSettingsPage(),
  ),
);
```

---

## 🧪 TESTES

### Testar Notificação Local

```dart
import 'package:nero/core/services/notification_service.dart';

final notificationService = NotificationService();
await notificationService.initialize();

// Notificação imediata
await notificationService.showNotification(
  id: 1,
  title: 'Teste',
  body: 'Esta é uma notificação de teste!',
  priority: NotificationPriority.high,
);
```

### Testar Notificação Agendada

```dart
// Agendar para daqui 10 segundos
await notificationService.scheduleNotification(
  id: 2,
  title: 'Lembrete',
  body: 'Notificação agendada funcionando!',
  scheduledDate: DateTime.now().add(Duration(seconds: 10)),
);
```

### Testar Push Notification (FCM)

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Vá em **Cloud Messaging**
3. Clique em **Enviar primeira mensagem**
4. Preencha:
   - **Título**: "Teste Push"
   - **Texto**: "Push notification funcionando!"
5. Selecione o app
6. Clique em **Publicar**

### Ver Notificações Pendentes

```dart
final pending = await notificationService.getPendingNotifications();
print('Notificações pendentes: ${pending.length}');
for (final notification in pending) {
  print('ID: ${notification.id}, Título: ${notification.title}');
}
```

---

## 🐛 TROUBLESHOOTING

### ❌ Problema: "Firebase not initialized"

**Solução**: Certifique-se de que o Firebase foi configurado corretamente.

1. Verifique se `google-services.json` está em `android/app/`
2. Verifique se `GoogleService-Info.plist` está em `ios/Runner/`
3. Execute: `flutter clean && flutter pub get`

### ❌ Problema: "Notifications not appearing"

**Possíveis causas**:

1. **Permissão negada**: Solicite permissão novamente
   ```dart
   await notificationService.requestPermission();
   ```

2. **Canal não criado** (Android): Os canais são criados automaticamente, mas verifique os logs

3. **App em foreground**: Em foreground, notificações FCM precisam ser exibidas manualmente (já implementado)

### ❌ Problema: "FCM token is null"

**Solução**:

1. Verifique se o Firebase foi inicializado no `main.dart`
2. Verifique se as configurações do Firebase estão corretas
3. Em emuladores, FCM pode não funcionar perfeitamente - teste em dispositivo real

### ❌ Problema: "Scheduled notification not firing"

**Solução**:

1. **Android**: Desative "Battery Optimization" para o app
2. **iOS**: Certifique-se de que o app tem permissão
3. Verifique se a data agendada não está no passado

---

## 📊 ESTRUTURA DE DADOS

### NotificationEntity

```dart
class NotificationEntity {
  String id;
  String userId;
  String title;
  String body;
  NotificationType type;
  DateTime createdAt;
  bool isRead;
  String? payload;
  String? actionUrl;
  DateTime? scheduledFor;
}
```

### NotificationType

```dart
enum NotificationType {
  taskReminder,       // Lembrete de tarefa
  taskOverdue,        // Tarefa atrasada
  financeAlert,       // Alerta financeiro
  budgetWarning,      // Aviso de orçamento
  goalAchieved,       // Meta atingida
  meetingReminder,    // Lembrete de reunião
  aiRecommendation,   // Recomendação da IA
  system,             // Notificação do sistema
  other,              // Outros
}
```

---

## 🚀 PRÓXIMOS PASSOS

### Implementações Futuras

1. **Notificações por Email**
   - Enviar resumo semanal por email
   - Alertas importantes por email

2. **Notificações no Web App**
   - Suporte para Web Push Notifications
   - Desktop notifications

3. **Agrupamento de Notificações**
   - Agrupar notificações similares
   - Resumir múltiplas notificações

4. **Ações Rápidas**
   - Marcar tarefa como concluída direto da notificação
   - Responder a recomendações da IA

5. **Rich Notifications**
   - Imagens nas notificações
   - Botões de ação customizados

---

## 📞 SUPORTE

Para problemas ou dúvidas:

1. Verifique este guia
2. Consulte `FIREBASE_SETUP.md`
3. Consulte `TROUBLESHOOTING.md`
4. Verifique os logs do app

---

## 📝 CHANGELOG

### v1.0 (Janeiro 2025)
- ✅ Implementação inicial do sistema de notificações
- ✅ Notificações locais (flutter_local_notifications)
- ✅ Push notifications (Firebase Cloud Messaging)
- ✅ Lembretes de tarefas
- ✅ Alertas financeiros
- ✅ Tela de notificações
- ✅ Tela de configurações
- ✅ Integração com Supabase

---

**Desenvolvido com ❤️ para o Projeto Nero**
