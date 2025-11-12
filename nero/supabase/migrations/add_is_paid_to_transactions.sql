-- ============================================
-- Migration: Adicionar campos is_paid e paid_at
-- Data: 2025-11-12
-- Descrição: Adiciona suporte para status de pagamento (Joia)
-- ============================================

-- Adicionar coluna is_paid (padrão: true - pago)
ALTER TABLE public.transactions
ADD COLUMN IF NOT EXISTS is_paid BOOLEAN DEFAULT TRUE NOT NULL;

-- Adicionar coluna paid_at (data/hora do pagamento)
ALTER TABLE public.transactions
ADD COLUMN IF NOT EXISTS paid_at TIMESTAMPTZ;

-- Criar índice para consultas por status de pagamento
CREATE INDEX IF NOT EXISTS idx_transactions_is_paid ON public.transactions(is_paid);

-- Criar índice para consultas por data de pagamento
CREATE INDEX IF NOT EXISTS idx_transactions_paid_at ON public.transactions(paid_at);

-- Atualizar registros existentes: definir paid_at = created_at para transações já marcadas como pagas
UPDATE public.transactions
SET paid_at = created_at
WHERE is_paid = TRUE AND paid_at IS NULL;

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON COLUMN public.transactions.is_paid IS 'Status de pagamento: true = pago (joia para cima), false = não pago (joia para baixo)';
COMMENT ON COLUMN public.transactions.paid_at IS 'Data/hora efetiva do pagamento (null se não pago)';
