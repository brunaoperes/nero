-- Adiciona a coluna 'account' na tabela transactions
-- Esta coluna armazena o banco/conta associado à transação (ex: "Nubank", "Itaú", etc)

ALTER TABLE transactions
ADD COLUMN IF NOT EXISTS account TEXT;

-- Cria um índice para melhorar a performance em consultas filtradas por conta
CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account);

-- Comentário na coluna para documentação
COMMENT ON COLUMN transactions.account IS 'Banco ou conta associada à transação (ex: Nubank, Itaú, Carteira)';
