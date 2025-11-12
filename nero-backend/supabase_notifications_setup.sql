-- ============================================
-- NERO - Setup de Notificações
-- Tabelas para push notifications e device tokens
-- ============================================

-- 1. Tabela de Device Tokens (FCM)
DROP TABLE IF EXISTS public.device_tokens CASCADE;

CREATE TABLE public.device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    device_type TEXT CHECK (device_type IN ('android', 'ios', 'web')),
    device_name TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_device_tokens_user_id ON public.device_tokens(user_id);
CREATE INDEX idx_device_tokens_token ON public.device_tokens(token);
CREATE INDEX idx_device_tokens_is_active ON public.device_tokens(is_active);

-- 2. Tabela de Preferências de Notificações
DROP TABLE IF EXISTS public.notification_preferences CASCADE;

CREATE TABLE public.notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Preferências gerais
    enabled BOOLEAN DEFAULT TRUE,

    -- Tipos de notificação
    task_reminders BOOLEAN DEFAULT TRUE,
    meeting_reminders BOOLEAN DEFAULT TRUE,
    finance_alerts BOOLEAN DEFAULT TRUE,
    ai_recommendations BOOLEAN DEFAULT TRUE,

    -- Configurações de tempo
    task_reminder_hours INTEGER DEFAULT 24,
    meeting_reminder_minutes INTEGER DEFAULT 30,

    -- Configurações financeiras
    finance_threshold DECIMAL(10, 2) DEFAULT 1000,
    daily_summary BOOLEAN DEFAULT FALSE,
    weekly_summary BOOLEAN DEFAULT TRUE,

    -- Horário de silêncio
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice
CREATE INDEX idx_notification_preferences_user_id ON public.notification_preferences(user_id);

-- 3. Tabela de Histórico de Notificações Enviadas
DROP TABLE IF EXISTS public.notification_history CASCADE;

CREATE TABLE public.notification_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Informações da notificação
    type TEXT NOT NULL CHECK (type IN ('task_reminder', 'meeting_reminder', 'finance_alert', 'ai_recommendation', 'custom')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,

    -- Dados relacionados
    related_id UUID,
    related_type TEXT,

    -- Status
    status TEXT NOT NULL CHECK (status IN ('sent', 'failed', 'clicked', 'dismissed')),
    error_message TEXT,

    -- Metadados
    metadata JSONB,

    -- Timestamps
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    clicked_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ
);

-- Índices
CREATE INDEX idx_notification_history_user_id ON public.notification_history(user_id);
CREATE INDEX idx_notification_history_type ON public.notification_history(type);
CREATE INDEX idx_notification_history_status ON public.notification_history(status);
CREATE INDEX idx_notification_history_sent_at ON public.notification_history(sent_at DESC);

-- 4. Habilitar RLS em todas as tabelas
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_history ENABLE ROW LEVEL SECURITY;

-- 5. Políticas RLS para device_tokens
CREATE POLICY "Users can view own device tokens"
    ON public.device_tokens FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own device tokens"
    ON public.device_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own device tokens"
    ON public.device_tokens FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own device tokens"
    ON public.device_tokens FOR DELETE
    USING (auth.uid() = user_id);

-- 6. Políticas RLS para notification_preferences
CREATE POLICY "Users can view own notification preferences"
    ON public.notification_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification preferences"
    ON public.notification_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification preferences"
    ON public.notification_preferences FOR UPDATE
    USING (auth.uid() = user_id);

-- 7. Políticas RLS para notification_history
CREATE POLICY "Users can view own notification history"
    ON public.notification_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification history"
    ON public.notification_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 8. Triggers para updated_at
CREATE OR REPLACE FUNCTION update_device_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_device_tokens_updated_at
    BEFORE UPDATE ON public.device_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_device_tokens_updated_at();

CREATE OR REPLACE FUNCTION update_notification_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_notification_preferences_updated_at
    BEFORE UPDATE ON public.notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_notification_preferences_updated_at();

-- 9. Função para criar preferências padrão ao criar usuário
CREATE OR REPLACE FUNCTION create_default_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.notification_preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_user_created_notification_preferences
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_default_notification_preferences();

-- ============================================
-- ✅ Setup completo!
--
-- Tabelas criadas:
-- - device_tokens (tokens FCM dos dispositivos)
-- - notification_preferences (preferências do usuário)
-- - notification_history (histórico de notificações)
--
-- Features:
-- - RLS habilitado
-- - Triggers automáticos
-- - Preferências padrão criadas automaticamente
-- ============================================
