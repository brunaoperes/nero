import cron from 'node-cron';
import { supabaseAdmin } from '../config/supabase';
import notificationService from './notification.service';

/**
 * Serviço de Agendamento de Notificações
 * Usa node-cron para verificar e enviar lembretes automáticos
 */
export class NotificationSchedulerService {
  private tasks: cron.ScheduledTask[] = [];

  /**
   * Inicia todos os agendadores
   */
  start() {
    console.log('🕐 Iniciando agendadores de notificações...');

    // Lembretes de tarefas - verifica a cada hora
    this.tasks.push(
      cron.schedule('0 * * * *', () => this.checkTaskReminders())
    );

    // Lembretes de reuniões - verifica a cada 15 minutos
    this.tasks.push(
      cron.schedule('*/15 * * * *', () => this.checkMeetingReminders())
    );

    // Alertas financeiros - verifica diariamente às 9h
    this.tasks.push(
      cron.schedule('0 9 * * *', () => this.checkFinanceAlerts())
    );

    // Resumo semanal - domingos às 18h
    this.tasks.push(
      cron.schedule('0 18 * * 0', () => this.sendWeeklySummary())
    );

    console.log(`✓ ${this.tasks.length} agendadores iniciados`);
  }

  /**
   * Para todos os agendadores
   */
  stop() {
    this.tasks.forEach((task) => task.stop());
    this.tasks = [];
    console.log('✓ Agendadores parados');
  }

  /**
   * Verifica tarefas que precisam de lembrete
   */
  private async checkTaskReminders() {
    console.log('🔔 Verificando lembretes de tarefas...');

    try {
      // Buscar usuários com preferências ativas
      const { data: usersWithPrefs } = await supabaseAdmin
        .from('notification_preferences')
        .select('user_id, task_reminders, task_reminder_hours, enabled')
        .eq('enabled', true)
        .eq('task_reminders', true);

      if (!usersWithPrefs || usersWithPrefs.length === 0) {
        return;
      }

      for (const pref of usersWithPrefs) {
        const { user_id, task_reminder_hours } = pref;

        // Buscar tarefas que vencem nas próximas X horas
        const now = new Date();
        const reminderTime = new Date(now.getTime() + task_reminder_hours * 60 * 60 * 1000);

        const { data: tasks } = await supabaseAdmin
          .from('tasks')
          .select('id, title, due_date')
          .eq('user_id', user_id)
          .eq('is_completed', false)
          .gte('due_date', now.toISOString())
          .lte('due_date', reminderTime.toISOString());

        if (tasks && tasks.length > 0) {
          for (const task of tasks) {
            await notificationService.sendNotificationToUser(user_id, {
              type: 'task_reminder',
              title: 'Lembrete de Tarefa',
              body: `A tarefa "${task.title}" vence em breve!`,
              relatedId: task.id,
              relatedType: 'task',
              data: {
                taskId: task.id,
                dueDate: task.due_date,
              },
            });
          }

          console.log(`✓ Enviados ${tasks.length} lembretes de tarefas para ${user_id}`);
        }
      }
    } catch (error) {
      console.error('Erro ao verificar lembretes de tarefas:', error);
    }
  }

  /**
   * Verifica reuniões que precisam de lembrete
   */
  private async checkMeetingReminders() {
    console.log('🔔 Verificando lembretes de reuniões...');

    try {
      const { data: usersWithPrefs } = await supabaseAdmin
        .from('notification_preferences')
        .select('user_id, meeting_reminders, meeting_reminder_minutes, enabled')
        .eq('enabled', true)
        .eq('meeting_reminders', true);

      if (!usersWithPrefs || usersWithPrefs.length === 0) {
        return;
      }

      for (const pref of usersWithPrefs) {
        const { user_id, meeting_reminder_minutes } = pref;

        // Buscar tarefas do tipo reunião
        const now = new Date();
        const reminderTime = new Date(now.getTime() + meeting_reminder_minutes * 60 * 1000);

        const { data: meetings } = await supabaseAdmin
          .from('tasks')
          .select('id, title, due_date, metadata')
          .eq('user_id', user_id)
          .eq('is_completed', false)
          .gte('due_date', now.toISOString())
          .lte('due_date', reminderTime.toISOString())
          .contains('metadata', { type: 'meeting' });

        if (meetings && meetings.length > 0) {
          for (const meeting of meetings) {
            const metadata = meeting.metadata as any;
            const location = metadata?.location || 'Local não especificado';

            await notificationService.sendNotificationToUser(user_id, {
              type: 'meeting_reminder',
              title: 'Lembrete de Reunião',
              body: `Reunião "${meeting.title}" começa em ${meeting_reminder_minutes} minutos. Local: ${location}`,
              relatedId: meeting.id,
              relatedType: 'meeting',
              data: {
                meetingId: meeting.id,
                location,
                dueDate: meeting.due_date,
              },
            });
          }

          console.log(`✓ Enviados ${meetings.length} lembretes de reuniões para ${user_id}`);
        }
      }
    } catch (error) {
      console.error('Erro ao verificar lembretes de reuniões:', error);
    }
  }

  /**
   * Verifica alertas financeiros
   */
  private async checkFinanceAlerts() {
    console.log('🔔 Verificando alertas financeiros...');

    try {
      const { data: usersWithPrefs } = await supabaseAdmin
        .from('notification_preferences')
        .select('user_id, finance_alerts, finance_threshold, enabled')
        .eq('enabled', true)
        .eq('finance_alerts', true);

      if (!usersWithPrefs || usersWithPrefs.length === 0) {
        return;
      }

      for (const pref of usersWithPrefs) {
        const { user_id, finance_threshold } = pref;

        // Buscar transações do mês atual
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        const { data: transactions } = await supabaseAdmin
          .from('transactions')
          .select('amount, type')
          .eq('user_id', user_id)
          .gte('date', startOfMonth.toISOString());

        if (!transactions) continue;

        // Calcular total de despesas
        const totalExpenses = transactions
          .filter((t: any) => t.type === 'expense')
          .reduce((sum: number, t: any) => sum + t.amount, 0);

        // Se ultrapassou o limite, enviar alerta
        if (totalExpenses > finance_threshold) {
          await notificationService.sendNotificationToUser(user_id, {
            type: 'finance_alert',
            title: 'Alerta Financeiro',
            body: `Você gastou R$ ${totalExpenses.toFixed(2)} este mês, ultrapassando seu limite de R$ ${finance_threshold.toFixed(2)}.`,
            data: {
              totalExpenses: totalExpenses.toString(),
              threshold: finance_threshold.toString(),
            },
          });

          console.log(`✓ Alerta financeiro enviado para ${user_id}`);
        }
      }
    } catch (error) {
      console.error('Erro ao verificar alertas financeiros:', error);
    }
  }

  /**
   * Envia resumo semanal
   */
  private async sendWeeklySummary() {
    console.log('🔔 Enviando resumos semanais...');

    try {
      const { data: usersWithPrefs } = await supabaseAdmin
        .from('notification_preferences')
        .select('user_id, enabled, weekly_summary')
        .eq('enabled', true)
        .eq('weekly_summary', true);

      if (!usersWithPrefs || usersWithPrefs.length === 0) {
        return;
      }

      for (const pref of usersWithPrefs) {
        const { user_id } = pref;

        // Buscar estatísticas da semana
        const now = new Date();
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

        // Tarefas completadas
        const { data: completedTasks } = await supabaseAdmin
          .from('tasks')
          .select('id')
          .eq('user_id', user_id)
          .eq('is_completed', true)
          .gte('completed_at', weekAgo.toISOString());

        // Transações
        const { data: transactions } = await supabaseAdmin
          .from('transactions')
          .select('amount, type')
          .eq('user_id', user_id)
          .gte('date', weekAgo.toISOString());

        const completedCount = completedTasks?.length || 0;
        const totalIncome = transactions
          ?.filter((t: any) => t.type === 'income')
          .reduce((sum: number, t: any) => sum + t.amount, 0) || 0;
        const totalExpenses = transactions
          ?.filter((t: any) => t.type === 'expense')
          .reduce((sum: number, t: any) => sum + t.amount, 0) || 0;

        await notificationService.sendNotificationToUser(user_id, {
          type: 'custom',
          title: 'Resumo Semanal',
          body: `Você completou ${completedCount} tarefas esta semana. Receitas: R$ ${totalIncome.toFixed(2)}, Despesas: R$ ${totalExpenses.toFixed(2)}.`,
          data: {
            completedTasks: completedCount.toString(),
            totalIncome: totalIncome.toString(),
            totalExpenses: totalExpenses.toString(),
          },
        });

        console.log(`✓ Resumo semanal enviado para ${user_id}`);
      }
    } catch (error) {
      console.error('Erro ao enviar resumos semanais:', error);
    }
  }

  /**
   * Envia notificação de recomendação de IA
   */
  async sendAIRecommendationNotification(userId: string, recommendationId: string) {
    try {
      // Buscar recomendação
      const { data: recommendation } = await supabaseAdmin
        .from('ai_recommendations')
        .select('title, description, priority')
        .eq('id', recommendationId)
        .single();

      if (!recommendation) return;

      await notificationService.sendNotificationToUser(userId, {
        type: 'ai_recommendation',
        title: 'Nova Recomendação de IA',
        body: recommendation.title,
        relatedId: recommendationId,
        relatedType: 'ai_recommendation',
        data: {
          priority: recommendation.priority,
        },
      });

      console.log(`✓ Notificação de recomendação IA enviada para ${userId}`);
    } catch (error) {
      console.error('Erro ao enviar notificação de recomendação IA:', error);
    }
  }
}

export default new NotificationSchedulerService();
