-- ============================================
-- MÓDULO DE FINANÇAS - NERO
-- Versão: 1.0
-- Data: Janeiro 2025
-- ============================================

-- ============================================
-- TABELA: categories
-- Descrição: Categorias de transações (padrão + customizadas)
-- ============================================

CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    icon TEXT NOT NULL DEFAULT '📦',
    color TEXT NOT NULL DEFAULT '999999',
    type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'both')),
    is_default BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON public.categories(type);
CREATE INDEX IF NOT EXISTS idx_categories_is_default ON public.categories(is_default);

-- RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view default and own categories"
    ON public.categories FOR SELECT
    USING (is_default = TRUE OR auth.uid() = user_id);

CREATE POLICY "Users can create own categories"
    ON public.categories FOR INSERT
    WITH CHECK (auth.uid() = user_id AND is_default = FALSE);

CREATE POLICY "Users can update own categories"
    ON public.categories FOR UPDATE
    USING (auth.uid() = user_id AND is_default = FALSE);

CREATE POLICY "Users can delete own categories"
    ON public.categories FOR DELETE
    USING (auth.uid() = user_id AND is_default = FALSE);

-- ============================================
-- TABELA: transactions
-- Descrição: Transações financeiras (receitas e despesas)
-- ============================================

CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    date TIMESTAMPTZ NOT NULL,
    description TEXT,
    company_id UUID, -- Para vincular a empresas (futuro)
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern TEXT CHECK (recurrence_pattern IN ('daily', 'weekly', 'monthly', 'yearly')),
    next_recurrence_date TIMESTAMPTZ,
    ai_category_suggestion TEXT,
    ai_category_confirmed BOOLEAN DEFAULT FALSE,
    attachment_url TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON public.transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_is_recurring ON public.transactions(is_recurring);
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON public.transactions(user_id, date DESC);

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

-- ============================================
-- TABELA: budgets
-- Descrição: Orçamentos por categoria
-- ============================================

CREATE TABLE IF NOT EXISTS public.budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    limit_amount DECIMAL(12, 2) NOT NULL CHECK (limit_amount > 0),
    period TEXT NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'yearly')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    alert_threshold DECIMAL(3, 2) DEFAULT 0.80 CHECK (alert_threshold > 0 AND alert_threshold <= 1),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON public.budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_category_id ON public.budgets(category_id);
CREATE INDEX IF NOT EXISTS idx_budgets_is_active ON public.budgets(is_active);

-- RLS
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own budgets"
    ON public.budgets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own budgets"
    ON public.budgets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets"
    ON public.budgets FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets"
    ON public.budgets FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- TABELA: financial_goals
-- Descrição: Metas financeiras
-- ============================================

CREATE TABLE IF NOT EXISTS public.financial_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    target_amount DECIMAL(12, 2) NOT NULL CHECK (target_amount > 0),
    current_amount DECIMAL(12, 2) DEFAULT 0 CHECK (current_amount >= 0),
    target_date TIMESTAMPTZ NOT NULL,
    description TEXT,
    icon TEXT DEFAULT '🎯',
    color TEXT DEFAULT '06D6A0',
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'achieved', 'cancelled')),
    achieved_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_financial_goals_user_id ON public.financial_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_financial_goals_status ON public.financial_goals(status);
CREATE INDEX IF NOT EXISTS idx_financial_goals_target_date ON public.financial_goals(target_date);

-- RLS
ALTER TABLE public.financial_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own goals"
    ON public.financial_goals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own goals"
    ON public.financial_goals FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own goals"
    ON public.financial_goals FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own goals"
    ON public.financial_goals FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- TRIGGERS
-- ============================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_finance_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER categories_updated_at_trigger
    BEFORE UPDATE ON public.categories
    FOR EACH ROW
    EXECUTE FUNCTION update_finance_updated_at();

CREATE TRIGGER transactions_updated_at_trigger
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_finance_updated_at();

CREATE TRIGGER budgets_updated_at_trigger
    BEFORE UPDATE ON public.budgets
    FOR EACH ROW
    EXECUTE FUNCTION update_finance_updated_at();

CREATE TRIGGER financial_goals_updated_at_trigger
    BEFORE UPDATE ON public.financial_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_finance_updated_at();

-- ============================================
-- FUNÇÕES ÚTEIS
-- ============================================

-- Função para calcular total gasto em uma categoria
CREATE OR REPLACE FUNCTION get_category_total(
    p_user_id UUID,
    p_category_id UUID,
    p_start_date TIMESTAMPTZ,
    p_end_date TIMESTAMPTZ
)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO v_total
    FROM public.transactions
    WHERE user_id = p_user_id
      AND category_id = p_category_id
      AND type = 'expense'
      AND date >= p_start_date
      AND date <= p_end_date;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para calcular progresso de uma meta
CREATE OR REPLACE FUNCTION calculate_goal_progress(p_goal_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_progress DECIMAL;
    v_current DECIMAL;
    v_target DECIMAL;
BEGIN
    SELECT current_amount, target_amount INTO v_current, v_target
    FROM public.financial_goals
    WHERE id = p_goal_id;

    IF v_target > 0 THEN
        v_progress = (v_current / v_target) * 100;
    ELSE
        v_progress = 0;
    END IF;

    RETURN v_progress;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- INSERIR CATEGORIAS PADRÃO
-- ============================================

-- Categorias de Despesas
INSERT INTO public.categories (name, icon, color, type, is_default) VALUES
('Alimentação', '🍔', 'FF6B6B', 'expense', TRUE),
('Transporte', '🚗', '4ECDC4', 'expense', TRUE),
('Moradia', '🏠', '95E1D3', 'expense', TRUE),
('Saúde', '🏥', 'F38181', 'expense', TRUE),
('Educação', '📚', 'AA96DA', 'expense', TRUE),
('Lazer', '🎮', 'FCBAD3', 'expense', TRUE),
('Vestuário', '👕', 'FFFFD2', 'expense', TRUE),
('Beleza', '💄', 'FFB6C1', 'expense', TRUE),
('Compras', '🛒', 'DDA15E', 'expense', TRUE),
('Contas', '📄', 'BC6C25', 'expense', TRUE),
('Impostos', '💼', '606C38', 'expense', TRUE),
('Investimentos', '📈', '283618', 'expense', TRUE),
('Outros - Despesa', '📦', '999999', 'expense', TRUE)
ON CONFLICT DO NOTHING;

-- Categorias de Receitas
INSERT INTO public.categories (name, icon, color, type, is_default) VALUES
('Salário', '💵', '06D6A0', 'income', TRUE),
('Freelance', '💻', '118AB2', 'income', TRUE),
('Investimentos', '📊', '073B4C', 'income', TRUE),
('Vendas', '💳', 'EF476F', 'income', TRUE),
('Aluguel', '🏘️', 'FFD166', 'income', TRUE),
('Presente', '🎁', '06FFA5', 'income', TRUE),
('Reembolso', '💰', '26547C', 'income', TRUE),
('Outros - Receita', '📥', '999999', 'income', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON TABLE public.categories IS 'Categorias de transações (padrão do sistema + customizadas do usuário)';
COMMENT ON TABLE public.transactions IS 'Transações financeiras (receitas e despesas)';
COMMENT ON TABLE public.budgets IS 'Orçamentos por categoria para controle de gastos';
COMMENT ON TABLE public.financial_goals IS 'Metas financeiras do usuário';

COMMENT ON COLUMN public.transactions.ai_category_suggestion IS 'Sugestão de categoria feita pela IA';
COMMENT ON COLUMN public.transactions.ai_category_confirmed IS 'Se o usuário confirmou a sugestão da IA';
COMMENT ON COLUMN public.budgets.alert_threshold IS 'Percentual para alertar (0.8 = 80% do orçamento)';
