-- Adiciona coluna is_default à tabela categories
-- Esta migração é necessária se a tabela categories foi criada sem essa coluna

-- Adicionar coluna is_default
ALTER TABLE public.categories
ADD COLUMN IF NOT EXISTS is_default BOOLEAN DEFAULT FALSE;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_categories_is_default
ON public.categories(is_default);

-- Atualizar categorias existentes (marcar como padrão se não tiverem user_id)
UPDATE public.categories
SET is_default = TRUE
WHERE user_id IS NULL AND is_default = FALSE;

-- Comentário
COMMENT ON COLUMN public.categories.is_default IS 'Indica se a categoria é padrão do sistema (TRUE) ou personalizada do usuário (FALSE)';
