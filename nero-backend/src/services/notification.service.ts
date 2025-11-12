import { messaging } from '../config/firebase';
import { supabaseAdmin } from '../config/supabase';
import { MulticastMessage, Message } from 'firebase-admin/messaging';

export interface NotificationPayload {
  title: string;
  body: string;
  type: 'task_reminder' | 'meeting_reminder' | 'finance_alert' | 'ai_recommendation' | 'custom';
  relatedId?: string;
  relatedType?: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

export interface DeviceToken {
  id: string;
  user_id: string;
  token: string;
  device_type: 'android' | 'ios' | 'web';
  device_name?: string;
  is_active: boolean;
}

export interface NotificationPreferences {
  enabled: boolean;
  task_reminders: boolean;
  meeting_reminders: boolean;
  finance_alerts: boolean;
  ai_recommendations: boolean;
  task_reminder_hours: number;
  meeting_reminder_minutes: number;
  finance_threshold: number;
  quiet_hours_enabled: boolean;
  quiet_hours_start?: string;
  quiet_hours_end?: string;
}

/**
 * Serviço de Push Notifications com Firebase Cloud Messaging
 */
export class NotificationService {
  /**
   * Registra um device token do usuário
   */
  async registerDeviceToken(
    userId: string,
    token: string,
    deviceType: 'android' | 'ios' | 'web',
    deviceName?: string
  ): Promise<boolean> {
    try {
      const { error } = await supabaseAdmin
        .from('device_tokens')
        .upsert({
          user_id: userId,
          token,
          device_type: deviceType,
          device_name: deviceName,
          is_active: true,
          last_used_at: new Date().toISOString(),
        }, {
          onConflict: 'token',
        });

      if (error) {
        console.error('Erro ao registrar device token:', error);
        return false;
      }

      console.log(`✓ Device token registrado para usuário ${userId}`);
      return true;
    } catch (error) {
      console.error('Erro ao registrar device token:', error);
      return false;
    }
  }

  /**
   * Remove um device token
   */
  async unregisterDeviceToken(userId: string, token: string): Promise<boolean> {
    try {
      const { error } = await supabaseAdmin
        .from('device_tokens')
        .delete()
        .eq('user_id', userId)
        .eq('token', token);

      if (error) {
        console.error('Erro ao remover device token:', error);
        return false;
      }

      console.log(`✓ Device token removido para usuário ${userId}`);
      return true;
    } catch (error) {
      console.error('Erro ao remover device token:', error);
      return false;
    }
  }

  /**
   * Busca tokens ativos do usuário
   */
  async getUserTokens(userId: string): Promise<string[]> {
    try {
      const { data, error } = await supabaseAdmin
        .from('device_tokens')
        .select('token')
        .eq('user_id', userId)
        .eq('is_active', true);

      if (error) {
        console.error('Erro ao buscar tokens:', error);
        return [];
      }

      return data.map((t: any) => t.token);
    } catch (error) {
      console.error('Erro ao buscar tokens:', error);
      return [];
    }
  }

  /**
   * Busca preferências de notificação do usuário
   */
  async getUserPreferences(userId: string): Promise<NotificationPreferences | null> {
    try {
      const { data, error } = await supabaseAdmin
        .from('notification_preferences')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (error || !data) {
        // Retornar preferências padrão
        return {
          enabled: true,
          task_reminders: true,
          meeting_reminders: true,
          finance_alerts: true,
          ai_recommendations: true,
          task_reminder_hours: 24,
          meeting_reminder_minutes: 30,
          finance_threshold: 1000,
          quiet_hours_enabled: false,
        };
      }

      return data as NotificationPreferences;
    } catch (error) {
      console.error('Erro ao buscar preferências:', error);
      return null;
    }
  }

  /**
   * Atualiza preferências de notificação
   */
  async updateUserPreferences(
    userId: string,
    preferences: Partial<NotificationPreferences>
  ): Promise<boolean> {
    try {
      const { error } = await supabaseAdmin
        .from('notification_preferences')
        .upsert({
          user_id: userId,
          ...preferences,
        }, {
          onConflict: 'user_id',
        });

      if (error) {
        console.error('Erro ao atualizar preferências:', error);
        return false;
      }

      return true;
    } catch (error) {
      console.error('Erro ao atualizar preferências:', error);
      return false;
    }
  }

  /**
   * Verifica se está em horário de silêncio
   */
  private isQuietHours(preferences: NotificationPreferences): boolean {
    if (!preferences.quiet_hours_enabled) return false;
    if (!preferences.quiet_hours_start || !preferences.quiet_hours_end) return false;

    const now = new Date();
    const currentTime = now.getHours() * 60 + now.getMinutes();

    const [startHour, startMin] = preferences.quiet_hours_start.split(':').map(Number);
    const [endHour, endMin] = preferences.quiet_hours_end.split(':').map(Number);

    const startTime = startHour * 60 + startMin;
    const endTime = endHour * 60 + endMin;

    if (startTime <= endTime) {
      return currentTime >= startTime && currentTime <= endTime;
    } else {
      // Horário atravessa meia-noite
      return currentTime >= startTime || currentTime <= endTime;
    }
  }

  /**
   * Verifica se deve enviar notificação baseado nas preferências
   */
  private async shouldSendNotification(
    userId: string,
    notificationType: NotificationPayload['type']
  ): Promise<boolean> {
    const preferences = await this.getUserPreferences(userId);

    if (!preferences || !preferences.enabled) {
      console.log(`Notificações desabilitadas para usuário ${userId}`);
      return false;
    }

    if (this.isQuietHours(preferences)) {
      console.log(`Horário de silêncio ativo para usuário ${userId}`);
      return false;
    }

    // Verificar preferências específicas por tipo
    switch (notificationType) {
      case 'task_reminder':
        return preferences.task_reminders;
      case 'meeting_reminder':
        return preferences.meeting_reminders;
      case 'finance_alert':
        return preferences.finance_alerts;
      case 'ai_recommendation':
        return preferences.ai_recommendations;
      default:
        return true;
    }
  }

  /**
   * Envia notificação para um usuário
   */
  async sendNotificationToUser(
    userId: string,
    payload: NotificationPayload
  ): Promise<{ success: boolean; successCount: number; failureCount: number }> {
    try {
      // Verificar se deve enviar
      const shouldSend = await this.shouldSendNotification(userId, payload.type);
      if (!shouldSend) {
        console.log(`Notificação não enviada devido às preferências do usuário ${userId}`);
        return { success: false, successCount: 0, failureCount: 0 };
      }

      // Buscar tokens do usuário
      const tokens = await this.getUserTokens(userId);

      if (tokens.length === 0) {
        console.log(`Nenhum token encontrado para usuário ${userId}`);
        return { success: false, successCount: 0, failureCount: 0 };
      }

      // Preparar mensagem
      const message: MulticastMessage = {
        tokens,
        notification: {
          title: payload.title,
          body: payload.body,
          ...(payload.imageUrl && { imageUrl: payload.imageUrl }),
        },
        data: {
          type: payload.type,
          ...(payload.relatedId && { relatedId: payload.relatedId }),
          ...(payload.relatedType && { relatedType: payload.relatedType }),
          ...(payload.data || {}),
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            channelId: 'nero_notifications',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        webpush: {
          notification: {
            icon: '/icon-192.png',
            requireInteraction: true,
          },
        },
      };

      // Enviar
      const response = await messaging.sendEachForMulticast(message);

      // Salvar no histórico
      await this.saveNotificationHistory(userId, payload, 'sent');

      // Invalidar tokens que falharam
      if (response.failureCount > 0) {
        const failedTokens = response.responses
          .map((resp, idx) => (!resp.success ? tokens[idx] : null))
          .filter((token): token is string => token !== null);

        await this.invalidateTokens(failedTokens);
      }

      console.log(
        `✓ Notificação enviada: ${response.successCount} sucesso, ${response.failureCount} falhas`
      );

      return {
        success: response.successCount > 0,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error('Erro ao enviar notificação:', error);
      await this.saveNotificationHistory(
        userId,
        payload,
        'failed',
        error instanceof Error ? error.message : 'Erro desconhecido'
      );
      return { success: false, successCount: 0, failureCount: 1 };
    }
  }

  /**
   * Envia notificação para múltiplos usuários
   */
  async sendNotificationToUsers(
    userIds: string[],
    payload: NotificationPayload
  ): Promise<{ totalSuccess: number; totalFailure: number }> {
    let totalSuccess = 0;
    let totalFailure = 0;

    for (const userId of userIds) {
      const result = await this.sendNotificationToUser(userId, payload);
      totalSuccess += result.successCount;
      totalFailure += result.failureCount;
    }

    return { totalSuccess, totalFailure };
  }

  /**
   * Invalida tokens que falharam
   */
  private async invalidateTokens(tokens: string[]): Promise<void> {
    if (tokens.length === 0) return;

    try {
      await supabaseAdmin
        .from('device_tokens')
        .update({ is_active: false })
        .in('token', tokens);

      console.log(`✓ ${tokens.length} tokens inválidos marcados como inativos`);
    } catch (error) {
      console.error('Erro ao invalidar tokens:', error);
    }
  }

  /**
   * Salva histórico de notificação
   */
  private async saveNotificationHistory(
    userId: string,
    payload: NotificationPayload,
    status: 'sent' | 'failed',
    errorMessage?: string
  ): Promise<void> {
    try {
      await supabaseAdmin.from('notification_history').insert({
        user_id: userId,
        type: payload.type,
        title: payload.title,
        body: payload.body,
        related_id: payload.relatedId,
        related_type: payload.relatedType,
        status,
        error_message: errorMessage,
        metadata: payload.data,
      });
    } catch (error) {
      console.error('Erro ao salvar histórico:', error);
    }
  }

  /**
   * Busca histórico de notificações do usuário
   */
  async getNotificationHistory(userId: string, limit: number = 50) {
    try {
      const { data, error } = await supabaseAdmin
        .from('notification_history')
        .select('*')
        .eq('user_id', userId)
        .order('sent_at', { ascending: false })
        .limit(limit);

      if (error) {
        console.error('Erro ao buscar histórico:', error);
        return [];
      }

      return data;
    } catch (error) {
      console.error('Erro ao buscar histórico:', error);
      return [];
    }
  }
}

export default new NotificationService();
