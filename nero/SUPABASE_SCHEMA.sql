-- =====================================================
-- NERO - Schema SQL do Supabase
-- =====================================================
-- Este arquivo contém o schema completo do banco de dados
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- EXTENSÕES
-- =====================================================

-- Habilitar UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABELA: users
-- Armazena dados dos usuários do Nero
-- =====================================================

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    name TEXT,
    avatar_url TEXT,
    entrepreneur_mode BOOLEAN DEFAULT FALSE,
    wake_up_time TEXT,
    work_start_time TEXT,
    work_end_time TEXT,
    has_company BOOLEAN DEFAULT FALSE,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_entrepreneur_mode ON public.users(entrepreneur_mode);

-- RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own data"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own data"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- =====================================================
-- TABELA: companies
-- Armazena empresas cadastradas pelos usuários
-- =====================================================

CREATE TABLE IF NOT EXISTS public.companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    type TEXT DEFAULT 'small', -- mei, small, services
    cnpj TEXT,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_companies_user_id ON public.companies(user_id);
CREATE INDEX IF NOT EXISTS idx_companies_is_active ON public.companies(is_active);

-- RLS
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own companies"
    ON public.companies FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own companies"
    ON public.companies FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own companies"
    ON public.companies FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own companies"
    ON public.companies FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABELA: tasks
-- Armazena tarefas pessoais e empresariais
-- =====================================================

CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    origin TEXT DEFAULT 'personal', -- personal, company, ai, recurring
    priority INTEGER DEFAULT 2, -- 1: baixa, 2: média, 3: alta
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_company_id ON public.tasks(company_id);
CREATE INDEX IF NOT EXISTS idx_tasks_is_completed ON public.tasks(is_completed);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON public.tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_origin ON public.tasks(origin);

-- RLS
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tasks"
    ON public.tasks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own tasks"
    ON public.tasks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks"
    ON public.tasks FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks"
    ON public.tasks FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABELA: meetings
-- Armazena reuniões das empresas
-- =====================================================

CREATE TABLE IF NOT EXISTS public.meetings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    location TEXT,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    participants TEXT[] DEFAULT '{}',
    agenda TEXT,
    notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_meetings_user_id ON public.meetings(user_id);
CREATE INDEX IF NOT EXISTS idx_meetings_company_id ON public.meetings(company_id);
CREATE INDEX IF NOT EXISTS idx_meetings_start_at ON public.meetings(start_at);
CREATE INDEX IF NOT EXISTS idx_meetings_is_completed ON public.meetings(is_completed);

-- RLS
ALTER TABLE public.meetings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meetings"
    ON public.meetings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own meetings"
    ON public.meetings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meetings"
    ON public.meetings FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meetings"
    ON public.meetings FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABELA: transactions
-- Armazena transações financeiras
-- =====================================================

CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    category TEXT,
    suggested_category TEXT,
    category_confidence DECIMAL(3, 2), -- 0.00 a 1.00 (ex: 0.80 = 80%)
    category_confirmed BOOLEAN DEFAULT FALSE,
    description TEXT,
    date TIMESTAMPTZ DEFAULT NOW(),
    source TEXT, -- pluggy, manual, etc
    external_id TEXT, -- ID da transação na fonte externa
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_company_id ON public.transactions(company_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(date);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON public.transactions(category);
CREATE INDEX IF NOT EXISTS idx_transactions_external_id ON public.transactions(external_id);

-- RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
    ON public.transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own transactions"
    ON public.transactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions"
    ON public.transactions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions"
    ON public.transactions FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABELA: ai_recommendations
-- Armazena recomendações da IA
-- =====================================================

CREATE TABLE IF NOT EXISTS public.ai_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- task, finance, routine, meeting
    status TEXT DEFAULT 'sent', -- sent, read, accepted, dismissed
    action_url TEXT,
    context JSONB DEFAULT '{}',
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ,
    actioned_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_user_id ON public.ai_recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_status ON public.ai_recommendations(status);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_type ON public.ai_recommendations(type);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_sent_at ON public.ai_recommendations(sent_at);

-- RLS
ALTER TABLE public.ai_recommendations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own recommendations"
    ON public.ai_recommendations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own recommendations"
    ON public.ai_recommendations FOR UPDATE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABELA: user_behavior
-- Armazena padrões de comportamento para IA
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_behavior (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    behavior_type TEXT NOT NULL, -- task_completion, meeting_time, expense_pattern, etc
    behavior_data JSONB NOT NULL,
    frequency INTEGER DEFAULT 1,
    last_occurred_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_behavior_user_id ON public.user_behavior(user_id);
CREATE INDEX IF NOT EXISTS idx_user_behavior_type ON public.user_behavior(behavior_type);

-- RLS
ALTER TABLE public.user_behavior ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own behavior"
    ON public.user_behavior FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "System can insert behavior"
    ON public.user_behavior FOR INSERT
    WITH CHECK (true); -- Backend tem permissão de inserir

CREATE POLICY "System can update behavior"
    ON public.user_behavior FOR UPDATE
    USING (true); -- Backend tem permissão de atualizar

-- =====================================================
-- TABELA: audit_logs
-- Logs de auditoria de todas as ações
-- =====================================================

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    payload JSONB DEFAULT '{}',
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at);

-- RLS
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own logs"
    ON public.audit_logs FOR SELECT
    USING (auth.uid() = user_id);

-- =====================================================
-- FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meetings_updated_at BEFORE UPDATE ON public.meetings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_behavior_updated_at BEFORE UPDATE ON public.user_behavior
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View de resumo de tarefas por usuário
CREATE OR REPLACE VIEW user_tasks_summary AS
SELECT
    user_id,
    COUNT(*) as total_tasks,
    COUNT(*) FILTER (WHERE is_completed = TRUE) as completed_tasks,
    COUNT(*) FILTER (WHERE is_completed = FALSE) as pending_tasks,
    COUNT(*) FILTER (WHERE due_date < NOW() AND is_completed = FALSE) as overdue_tasks
FROM public.tasks
GROUP BY user_id;

-- View de resumo financeiro por usuário
CREATE OR REPLACE VIEW user_finance_summary AS
SELECT
    user_id,
    SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
    SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expenses,
    SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as balance
FROM public.transactions
GROUP BY user_id;

-- =====================================================
-- COMENTÁRIOS NAS TABELAS
-- =====================================================

COMMENT ON TABLE public.users IS 'Usuários do Nero com dados de perfil e preferências';
COMMENT ON TABLE public.companies IS 'Empresas cadastradas pelos usuários';
COMMENT ON TABLE public.tasks IS 'Tarefas pessoais e empresariais';
COMMENT ON TABLE public.meetings IS 'Reuniões agendadas das empresas';
COMMENT ON TABLE public.transactions IS 'Transações financeiras';
COMMENT ON TABLE public.ai_recommendations IS 'Recomendações da IA para os usuários';
COMMENT ON TABLE public.user_behavior IS 'Padrões de comportamento para aprendizado da IA';
COMMENT ON TABLE public.audit_logs IS 'Logs de auditoria de todas as ações';

-- =====================================================
-- FIM DO SCHEMA
-- =====================================================
