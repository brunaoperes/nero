-- ============================================
-- NERO - Setup da tabela AI Recommendations
-- ============================================

-- 1. Remover tabela existente (se houver)
DROP TABLE IF EXISTS public.ai_recommendations CASCADE;

-- 2. Criar tabela de recomendações de IA
CREATE TABLE public.ai_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Informações da recomendação
    type TEXT NOT NULL CHECK (type IN ('task', 'financial', 'productivity', 'alert')),
    title TEXT NOT NULL,
    description TEXT NOT NULL,

    -- Priorização
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')) DEFAULT 'medium',
    confidence DECIMAL(3, 2) CHECK (confidence >= 0 AND confidence <= 1),
    score INTEGER DEFAULT 0, -- Score calculado para ordenação

    -- Estado da recomendação
    is_read BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    action_taken TEXT CHECK (action_taken IN ('accepted', 'rejected', 'completed', 'ignored')),
    action_taken_at TIMESTAMPTZ,

    -- Metadados e contexto
    metadata JSONB,
    expires_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Criar índices para otimização de queries
CREATE INDEX idx_ai_recommendations_user_id ON public.ai_recommendations(user_id);
CREATE INDEX idx_ai_recommendations_type ON public.ai_recommendations(type);
CREATE INDEX idx_ai_recommendations_priority ON public.ai_recommendations(priority);
CREATE INDEX idx_ai_recommendations_is_read ON public.ai_recommendations(is_read);
CREATE INDEX idx_ai_recommendations_is_dismissed ON public.ai_recommendations(is_dismissed);
CREATE INDEX idx_ai_recommendations_action_taken ON public.ai_recommendations(action_taken);
CREATE INDEX idx_ai_recommendations_created_at ON public.ai_recommendations(created_at DESC);
CREATE INDEX idx_ai_recommendations_score ON public.ai_recommendations(score DESC);

-- 4. Habilitar RLS
ALTER TABLE public.ai_recommendations ENABLE ROW LEVEL SECURITY;

-- 5. Criar políticas RLS
CREATE POLICY "Users can view own recommendations"
    ON public.ai_recommendations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recommendations"
    ON public.ai_recommendations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recommendations"
    ON public.ai_recommendations FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recommendations"
    ON public.ai_recommendations FOR DELETE
    USING (auth.uid() = user_id);

-- 6. Criar trigger para updated_at
CREATE OR REPLACE FUNCTION update_ai_recommendations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_ai_recommendations_updated_at
    BEFORE UPDATE ON public.ai_recommendations
    FOR EACH ROW
    EXECUTE FUNCTION update_ai_recommendations_updated_at();

-- 7. Função para calcular score baseado em prioridade e confiança
CREATE OR REPLACE FUNCTION calculate_recommendation_score(
    p_priority TEXT,
    p_confidence DECIMAL
) RETURNS INTEGER AS $$
BEGIN
    RETURN (
        CASE p_priority
            WHEN 'high' THEN 100
            WHEN 'medium' THEN 50
            WHEN 'low' THEN 25
            ELSE 0
        END
        + (p_confidence * 100)::INTEGER
    );
END;
$$ LANGUAGE plpgsql;

-- 8. Trigger para atualizar score automaticamente
CREATE OR REPLACE FUNCTION update_recommendation_score()
RETURNS TRIGGER AS $$
BEGIN
    NEW.score = calculate_recommendation_score(NEW.priority, NEW.confidence);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_update_recommendation_score
    BEFORE INSERT OR UPDATE OF priority, confidence
    ON public.ai_recommendations
    FOR EACH ROW
    EXECUTE FUNCTION update_recommendation_score();

-- ============================================
-- ✅ Setup completo!
--
-- Para usar:
-- 1. Execute este script no SQL Editor do Supabase
-- 2. A tabela ai_recommendations será criada
-- 3. Scores serão calculados automaticamente
-- 4. RLS está habilitado para segurança
-- ============================================
