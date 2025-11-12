-- ============================================
-- TABELA: notifications
-- Descrição: Armazena notificações enviadas aos usuários
-- ============================================

-- Criar tabela notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL, -- task_reminder, task_overdue, finance_alert, budget_warning, goal_achieved, meeting_reminder, ai_recommendation, system, other
    payload TEXT, -- Dados adicionais (ex: task_id, transaction_id, etc)
    action_url TEXT, -- URL para navegação quando a notificação é tocada
    is_read BOOLEAN DEFAULT FALSE,
    scheduled_for TIMESTAMPTZ, -- Para notificações agendadas
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id
    ON public.notifications(user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_is_read
    ON public.notifications(is_read);

CREATE INDEX IF NOT EXISTS idx_notifications_type
    ON public.notifications(type);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
    ON public.notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
    ON public.notifications(user_id, is_read)
    WHERE is_read = FALSE;

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notifications_updated_at_trigger
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policy: Usuários podem ver apenas suas próprias notificações
CREATE POLICY "Users can view own notifications"
    ON public.notifications
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Usuários podem criar suas próprias notificações
CREATE POLICY "Users can create own notifications"
    ON public.notifications
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem atualizar suas próprias notificações (marcar como lida)
CREATE POLICY "Users can update own notifications"
    ON public.notifications
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem deletar suas próprias notificações
CREATE POLICY "Users can delete own notifications"
    ON public.notifications
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- TABELA: user_devices (para FCM tokens)
-- Descrição: Armazena os tokens FCM dos dispositivos dos usuários
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL UNIQUE,
    device_type TEXT NOT NULL, -- android, ios, web
    device_name TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id
    ON public.user_devices(user_id);

CREATE INDEX IF NOT EXISTS idx_user_devices_fcm_token
    ON public.user_devices(fcm_token);

CREATE INDEX IF NOT EXISTS idx_user_devices_is_active
    ON public.user_devices(is_active);

-- Trigger para atualizar updated_at
CREATE TRIGGER user_devices_updated_at_trigger
    BEFORE UPDATE ON public.user_devices
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- RLS para user_devices
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;

-- Policy: Usuários podem ver seus próprios dispositivos
CREATE POLICY "Users can view own devices"
    ON public.user_devices
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Usuários podem inserir seus próprios dispositivos
CREATE POLICY "Users can insert own devices"
    ON public.user_devices
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem atualizar seus próprios dispositivos
CREATE POLICY "Users can update own devices"
    ON public.user_devices
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem deletar seus próprios dispositivos
CREATE POLICY "Users can delete own devices"
    ON public.user_devices
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- FUNÇÃO: Marcar todas as notificações como lidas
-- ============================================

CREATE OR REPLACE FUNCTION mark_all_notifications_as_read(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.notifications
    SET is_read = TRUE
    WHERE user_id = p_user_id AND is_read = FALSE;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÃO: Deletar notificações antigas (cleanup)
-- ============================================

CREATE OR REPLACE FUNCTION delete_old_read_notifications(days_old INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    DELETE FROM public.notifications
    WHERE is_read = TRUE
      AND created_at < NOW() - (days_old || ' days')::INTERVAL;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÃO: Criar notificação para usuário
-- ============================================

CREATE OR REPLACE FUNCTION create_user_notification(
    p_user_id UUID,
    p_title TEXT,
    p_body TEXT,
    p_type TEXT,
    p_payload TEXT DEFAULT NULL,
    p_action_url TEXT DEFAULT NULL,
    p_scheduled_for TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO public.notifications (
        user_id,
        title,
        body,
        type,
        payload,
        action_url,
        scheduled_for
    ) VALUES (
        p_user_id,
        p_title,
        p_body,
        p_type,
        p_payload,
        p_action_url,
        p_scheduled_for
    )
    RETURNING id INTO v_notification_id;

    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON TABLE public.notifications IS 'Armazena todas as notificações enviadas aos usuários';
COMMENT ON TABLE public.user_devices IS 'Armazena os tokens FCM dos dispositivos dos usuários para push notifications';
COMMENT ON COLUMN public.notifications.type IS 'Tipos: task_reminder, task_overdue, finance_alert, budget_warning, goal_achieved, meeting_reminder, ai_recommendation, system, other';
COMMENT ON COLUMN public.notifications.payload IS 'Dados adicionais em formato JSON ou string (task_id, transaction_id, etc)';
COMMENT ON COLUMN public.notifications.action_url IS 'URL para navegação quando a notificação é tocada';
COMMENT ON COLUMN public.user_devices.fcm_token IS 'Token do Firebase Cloud Messaging para enviar push notifications';
COMMENT ON COLUMN public.user_devices.device_type IS 'Tipo do dispositivo: android, ios ou web';

-- ============================================
-- DADOS DE EXEMPLO (opcional - comentar em produção)
-- ============================================

/*
-- Exemplo de notificação de lembrete de tarefa
INSERT INTO public.notifications (user_id, title, body, type, payload)
VALUES (
    'USER_ID_AQUI',
    '⏰ Tarefa em 15 minutos',
    'Reunião com cliente às 14h',
    'task_reminder',
    'task_123'
);

-- Exemplo de notificação de alerta financeiro
INSERT INTO public.notifications (user_id, title, body, type, payload)
VALUES (
    'USER_ID_AQUI',
    '💰 Gasto Acima da Média',
    'Você gastou R$ 500 em Alimentação (50% acima da média)',
    'finance_alert',
    'category_alimentacao'
);

-- Exemplo de notificação de meta atingida
INSERT INTO public.notifications (user_id, title, body, type, payload)
VALUES (
    'USER_ID_AQUI',
    '🎉 Meta Atingida!',
    'Parabéns! Você atingiu a meta "Economizar R$ 1000" de R$ 1000.00',
    'goal_achieved',
    'goal_economizar'
);
*/
