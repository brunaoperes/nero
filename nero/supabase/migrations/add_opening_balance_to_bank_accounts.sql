-- ============================================
-- Migration: Adicionar opening_balance às contas bancárias
-- Data: 2025-11-12
-- Descrição: Adiciona saldo de abertura para cálculo correto do saldo atual
-- ============================================

-- Adicionar coluna opening_balance (saldo de abertura)
ALTER TABLE public.bank_accounts
ADD COLUMN IF NOT EXISTS opening_balance DECIMAL(12, 2) DEFAULT 0.00 NOT NULL;

-- Migrar saldos atuais para opening_balance se ainda não houver transações
-- Isso preserva o saldo inicial das contas existentes
UPDATE public.bank_accounts
SET opening_balance = balance
WHERE opening_balance = 0.00;

-- Criar índice para consultas de saldo
CREATE INDEX IF NOT EXISTS idx_bank_accounts_opening_balance ON public.bank_accounts(opening_balance);

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON COLUMN public.bank_accounts.opening_balance IS 'Saldo inicial da conta (base para cálculo do saldo corrente)';
