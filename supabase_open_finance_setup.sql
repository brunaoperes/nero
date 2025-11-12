-- ============================================
-- NERO - Open Finance (Pluggy) Database Setup
-- ============================================
-- Este script cria as tabelas necessárias para
-- integração com Pluggy (Open Finance)
-- ============================================

-- Tabela de conexões bancárias
CREATE TABLE IF NOT EXISTS bank_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  pluggy_item_id TEXT NOT NULL UNIQUE,
  connector_id INTEGER NOT NULL,
  connector_name TEXT NOT NULL,
  connector_image_url TEXT,
  status TEXT NOT NULL DEFAULT 'UPDATING'
    CHECK (status IN ('UPDATED', 'UPDATING', 'LOGIN_ERROR', 'OUTDATED')),
  last_sync_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para bank_connections
CREATE INDEX idx_bank_connections_user_id ON bank_connections(user_id);
CREATE INDEX idx_bank_connections_status ON bank_connections(status);
CREATE INDEX idx_bank_connections_pluggy_item ON bank_connections(pluggy_item_id);

-- Tabela de contas bancárias
CREATE TABLE IF NOT EXISTS bank_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES bank_connections(id) ON DELETE CASCADE,
  pluggy_account_id TEXT NOT NULL UNIQUE,
  account_type TEXT NOT NULL CHECK (account_type IN ('BANK', 'CREDIT')),
  account_subtype TEXT NOT NULL,
  account_number TEXT NOT NULL,
  account_name TEXT NOT NULL,
  balance DECIMAL(12, 2) NOT NULL DEFAULT 0,
  currency_code TEXT NOT NULL DEFAULT 'BRL',
  credit_limit DECIMAL(12, 2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para bank_accounts
CREATE INDEX idx_bank_accounts_connection ON bank_accounts(connection_id);
CREATE INDEX idx_bank_accounts_pluggy_id ON bank_accounts(pluggy_account_id);
CREATE INDEX idx_bank_accounts_type ON bank_accounts(account_type);

-- Tabela de transações sincronizadas
CREATE TABLE IF NOT EXISTS synced_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id UUID NOT NULL REFERENCES bank_accounts(id) ON DELETE CASCADE,
  pluggy_transaction_id TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  category_id UUID,  -- Removida a referência FK temporariamente
  category_suggestion TEXT,
  category_confidence DECIMAL(3, 2),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'posted')),
  synced_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para synced_transactions
CREATE INDEX idx_synced_transactions_account ON synced_transactions(account_id);
CREATE INDEX idx_synced_transactions_pluggy_id ON synced_transactions(pluggy_transaction_id);
CREATE INDEX idx_synced_transactions_date ON synced_transactions(date DESC);
CREATE INDEX idx_synced_transactions_type ON synced_transactions(type);
CREATE INDEX idx_synced_transactions_category ON synced_transactions(category_id);

-- Tabela de log de sincronizações
CREATE TABLE IF NOT EXISTS sync_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES bank_connections(id) ON DELETE CASCADE,
  sync_type TEXT NOT NULL CHECK (sync_type IN ('manual', 'automatic', 'scheduled')),
  status TEXT NOT NULL CHECK (status IN ('started', 'success', 'error')),
  accounts_synced INTEGER DEFAULT 0,
  transactions_synced INTEGER DEFAULT 0,
  error_message TEXT,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Índice para sync_logs
CREATE INDEX idx_sync_logs_connection ON sync_logs(connection_id);
CREATE INDEX idx_sync_logs_started_at ON sync_logs(started_at DESC);

-- ============================================
-- RLS (Row Level Security)
-- ============================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE bank_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE synced_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_logs ENABLE ROW LEVEL SECURITY;

-- Políticas para bank_connections
CREATE POLICY "Users can view their own bank connections"
  ON bank_connections FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own bank connections"
  ON bank_connections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bank connections"
  ON bank_connections FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own bank connections"
  ON bank_connections FOR DELETE
  USING (auth.uid() = user_id);

-- Políticas para bank_accounts
CREATE POLICY "Users can view their own bank accounts"
  ON bank_accounts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bank_connections bc
      WHERE bc.id = bank_accounts.connection_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own bank accounts"
  ON bank_accounts FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bank_connections bc
      WHERE bc.id = bank_accounts.connection_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own bank accounts"
  ON bank_accounts FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM bank_connections bc
      WHERE bc.id = bank_accounts.connection_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own bank accounts"
  ON bank_accounts FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM bank_connections bc
      WHERE bc.id = bank_accounts.connection_id
      AND bc.user_id = auth.uid()
    )
  );

-- Políticas para synced_transactions
CREATE POLICY "Users can view their own synced transactions"
  ON synced_transactions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bank_accounts ba
      JOIN bank_connections bc ON bc.id = ba.connection_id
      WHERE ba.id = synced_transactions.account_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own synced transactions"
  ON synced_transactions FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bank_accounts ba
      JOIN bank_connections bc ON bc.id = ba.connection_id
      WHERE ba.id = synced_transactions.account_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own synced transactions"
  ON synced_transactions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM bank_accounts ba
      JOIN bank_connections bc ON bc.id = ba.connection_id
      WHERE ba.id = synced_transactions.account_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own synced transactions"
  ON synced_transactions FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM bank_accounts ba
      JOIN bank_connections bc ON bc.id = ba.connection_id
      WHERE ba.id = synced_transactions.account_id
      AND bc.user_id = auth.uid()
    )
  );

-- Políticas para sync_logs
CREATE POLICY "Users can view their own sync logs"
  ON sync_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bank_connections bc
      WHERE bc.id = sync_logs.connection_id
      AND bc.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own sync logs"
  ON sync_logs FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bank_connections bc
      WHERE bc.id = sync_logs.connection_id
      AND bc.user_id = auth.uid()
    )
  );

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_bank_connections_updated_at
  BEFORE UPDATE ON bank_connections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bank_accounts_updated_at
  BEFORE UPDATE ON bank_accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS ÚTEIS
-- ============================================

-- View para obter todas as conexões com resumo de contas
CREATE OR REPLACE VIEW bank_connections_summary AS
SELECT
  bc.*,
  COUNT(DISTINCT ba.id) as accounts_count,
  COUNT(DISTINCT st.id) as transactions_count,
  COALESCE(SUM(CASE WHEN ba.account_type = 'BANK' THEN ba.balance ELSE 0 END), 0) as total_bank_balance,
  COALESCE(SUM(CASE WHEN ba.account_type = 'CREDIT' THEN ba.balance ELSE 0 END), 0) as total_credit_balance
FROM bank_connections bc
LEFT JOIN bank_accounts ba ON ba.connection_id = bc.id
LEFT JOIN synced_transactions st ON st.account_id = ba.id
GROUP BY bc.id;

-- View para estatísticas de sincronização
CREATE OR REPLACE VIEW sync_statistics AS
SELECT
  bc.id as connection_id,
  bc.connector_name,
  bc.status,
  bc.last_sync_at,
  COUNT(sl.id) as total_syncs,
  COUNT(CASE WHEN sl.status = 'success' THEN 1 END) as successful_syncs,
  COUNT(CASE WHEN sl.status = 'error' THEN 1 END) as failed_syncs,
  MAX(sl.completed_at) as last_successful_sync
FROM bank_connections bc
LEFT JOIN sync_logs sl ON sl.connection_id = bc.id
GROUP BY bc.id, bc.connector_name, bc.status, bc.last_sync_at;

-- ============================================
-- COMENTÁRIOS
-- ============================================

COMMENT ON TABLE bank_connections IS 'Armazena as conexões bancárias do usuário via Pluggy';
COMMENT ON TABLE bank_accounts IS 'Armazena as contas bancárias sincronizadas via Pluggy';
COMMENT ON TABLE synced_transactions IS 'Armazena as transações sincronizadas do Open Finance';
COMMENT ON TABLE sync_logs IS 'Log de todas as sincronizações realizadas';

-- ============================================
-- FIM DO SCRIPT
-- ============================================

-- ============================================
-- OPCIONAL: Adicionar Foreign Key para Categories
-- ============================================
-- Execute este comando DEPOIS de criar a tabela 'categories'
--
-- ALTER TABLE synced_transactions
--   ADD CONSTRAINT fk_synced_transactions_category
--   FOREIGN KEY (category_id) REFERENCES categories(id);

-- ============================================
-- VERIFICAÇÃO
-- ============================================

-- Para verificar se tudo foi criado corretamente:
SELECT
  'bank_connections' as table_name,
  COUNT(*) as row_count
FROM bank_connections
UNION ALL
SELECT
  'bank_accounts' as table_name,
  COUNT(*) as row_count
FROM bank_accounts
UNION ALL
SELECT
  'synced_transactions' as table_name,
  COUNT(*) as row_count
FROM synced_transactions
UNION ALL
SELECT
  'sync_logs' as table_name,
  COUNT(*) as row_count
FROM sync_logs;
