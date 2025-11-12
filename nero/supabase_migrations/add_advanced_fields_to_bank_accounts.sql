-- Adiciona campos avançados para contas bancárias
-- is_hidden_balance: esconder saldo da conta
-- account_type: tipo da conta (PF ou PJ)
-- icon_key: identificador do ícone/banco escolhido

-- Adicionar novos campos
ALTER TABLE bank_accounts
ADD COLUMN IF NOT EXISTS is_hidden_balance BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS account_type TEXT DEFAULT 'pf' CHECK (account_type IN ('pf', 'pj')),
ADD COLUMN IF NOT EXISTS icon_key TEXT DEFAULT 'generic';

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_bank_accounts_is_hidden ON bank_accounts(is_hidden_balance);
CREATE INDEX IF NOT EXISTS idx_bank_accounts_account_type ON bank_accounts(account_type);

-- Comentários
COMMENT ON COLUMN bank_accounts.is_hidden_balance IS 'Quando TRUE, o saldo não aparece e não é somado no total';
COMMENT ON COLUMN bank_accounts.account_type IS 'Tipo da conta: pf (Pessoa Física) ou pj (Pessoa Jurídica)';
COMMENT ON COLUMN bank_accounts.icon_key IS 'Identificador do ícone do banco: nubank, itau, bradesco, caixa, santander, c6, inter, xp, wallet, generic';

-- Atualizar contas existentes com valores padrão
UPDATE bank_accounts
SET
  is_hidden_balance = FALSE,
  account_type = 'pf',
  icon_key = CASE
    WHEN LOWER(name) LIKE '%nubank%' THEN 'nubank'
    WHEN LOWER(name) LIKE '%itau%' OR LOWER(name) LIKE '%itaú%' THEN 'itau'
    WHEN LOWER(name) LIKE '%bradesco%' THEN 'bradesco'
    WHEN LOWER(name) LIKE '%caixa%' THEN 'caixa'
    WHEN LOWER(name) LIKE '%santander%' THEN 'santander'
    WHEN LOWER(name) LIKE '%c6%' THEN 'c6'
    WHEN LOWER(name) LIKE '%inter%' THEN 'inter'
    WHEN LOWER(name) LIKE '%xp%' THEN 'xp'
    WHEN LOWER(name) LIKE '%carteira%' OR LOWER(name) LIKE '%dinheiro%' THEN 'wallet'
    ELSE 'generic'
  END
WHERE is_hidden_balance IS NULL OR account_type IS NULL OR icon_key IS NULL;
