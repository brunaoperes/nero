-- =====================================================
-- NERO - Extensão do Schema para Módulo de Empresas
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- após executar o schema principal
-- =====================================================

-- =====================================================
-- TABELA: company_checklists
-- Checklists automáticos para empresas (MEI, mensal, anual)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.company_checklists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('mei', 'monthly', 'annual', 'custom')),
    frequency TEXT, -- monthly, annual, once
    due_date TIMESTAMPTZ,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    items JSONB DEFAULT '[]', -- Array de itens do checklist
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_company_checklists_company_id ON public.company_checklists(company_id);
CREATE INDEX IF NOT EXISTS idx_company_checklists_user_id ON public.company_checklists(user_id);
CREATE INDEX IF NOT EXISTS idx_company_checklists_type ON public.company_checklists(type);
CREATE INDEX IF NOT EXISTS idx_company_checklists_is_completed ON public.company_checklists(is_completed);
CREATE INDEX IF NOT EXISTS idx_company_checklists_due_date ON public.company_checklists(due_date);

-- RLS
ALTER TABLE public.company_checklists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own company checklists"
    ON public.company_checklists FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own company checklists"
    ON public.company_checklists FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own company checklists"
    ON public.company_checklists FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own company checklists"
    ON public.company_checklists FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABELA: company_actions
-- Timeline de ações das empresas
-- =====================================================

CREATE TABLE IF NOT EXISTS public.company_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    action_type TEXT NOT NULL, -- task_created, meeting_scheduled, checklist_completed, etc
    title TEXT NOT NULL,
    description TEXT,
    related_id UUID, -- ID da entidade relacionada (task_id, meeting_id, etc)
    related_type TEXT, -- task, meeting, checklist, transaction
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_company_actions_company_id ON public.company_actions(company_id);
CREATE INDEX IF NOT EXISTS idx_company_actions_user_id ON public.company_actions(user_id);
CREATE INDEX IF NOT EXISTS idx_company_actions_type ON public.company_actions(action_type);
CREATE INDEX IF NOT EXISTS idx_company_actions_created_at ON public.company_actions(created_at);
CREATE INDEX IF NOT EXISTS idx_company_actions_related ON public.company_actions(related_id, related_type);

-- RLS
ALTER TABLE public.company_actions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own company actions"
    ON public.company_actions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own company actions"
    ON public.company_actions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own company actions"
    ON public.company_actions FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TRIGGERS
-- =====================================================

CREATE TRIGGER update_company_checklists_updated_at BEFORE UPDATE ON public.company_checklists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNÇÕES ÚTEIS
-- =====================================================

-- Função para criar checklists automáticos MEI
CREATE OR REPLACE FUNCTION create_mei_checklists(p_company_id UUID, p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    -- Checklist Mensal MEI
    INSERT INTO public.company_checklists (company_id, user_id, title, description, type, frequency, items)
    VALUES (
        p_company_id,
        p_user_id,
        'Obrigações Mensais MEI',
        'Checklist mensal de obrigações para MEI',
        'mei',
        'monthly',
        '[
            {"id": "1", "title": "Pagar DAS (até dia 20)", "completed": false},
            {"id": "2", "title": "Emitir notas fiscais do mês", "completed": false},
            {"id": "3", "title": "Registrar vendas no sistema", "completed": false},
            {"id": "4", "title": "Verificar limite de faturamento", "completed": false}
        ]'::jsonb
    );

    -- Checklist Anual MEI
    INSERT INTO public.company_checklists (company_id, user_id, title, description, type, frequency, items)
    VALUES (
        p_company_id,
        p_user_id,
        'Obrigações Anuais MEI',
        'Checklist anual de obrigações para MEI',
        'mei',
        'annual',
        '[
            {"id": "1", "title": "Enviar DASN-SIMEI (até 31 de maio)", "completed": false},
            {"id": "2", "title": "Verificar CNAE está correto", "completed": false},
            {"id": "3", "title": "Atualizar dados cadastrais", "completed": false},
            {"id": "4", "title": "Revisar alíquota de impostos", "completed": false}
        ]'::jsonb
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS
-- =====================================================

COMMENT ON TABLE public.company_checklists IS 'Checklists automáticos para gestão de empresas';
COMMENT ON TABLE public.company_actions IS 'Timeline de todas as ações realizadas nas empresas';

-- =====================================================
-- FIM DA EXTENSÃO
-- =====================================================
