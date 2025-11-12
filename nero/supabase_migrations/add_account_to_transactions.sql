-- Adicionar coluna 'account' na tabela transactions
ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS account TEXT;

-- Criar índice para melhorar performance de filtros por conta
CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account);

-- Atualizar transações existentes com uma conta padrão (opcional)
-- Descomente a linha abaixo se quiser preencher transações antigas
-- UPDATE transactions SET account = 'Não informada' WHERE account IS NULL;
