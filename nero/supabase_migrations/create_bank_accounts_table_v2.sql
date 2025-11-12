-- Tabela de contas bancárias
-- Versão simplificada sem foreign key constraint

-- Primeiro, dropar a tabela se existir (para começar do zero)
DROP TABLE IF EXISTS bank_accounts CASCADE;

-- Criar a tabela
CREATE TABLE bank_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  color TEXT,
  icon TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices
CREATE INDEX idx_bank_accounts_user_id ON bank_accounts(user_id);
CREATE INDEX idx_bank_accounts_is_active ON bank_accounts(is_active);
CREATE INDEX idx_bank_accounts_user_active ON bank_accounts(user_id, is_active);

-- Habilitar RLS
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Users can view own accounts"
  ON bank_accounts FOR SELECT
  USING (user_id::text = auth.uid()::text);

CREATE POLICY "Users can insert own accounts"
  ON bank_accounts FOR INSERT
  WITH CHECK (user_id::text = auth.uid()::text);

CREATE POLICY "Users can update own accounts"
  ON bank_accounts FOR UPDATE
  USING (user_id::text = auth.uid()::text)
  WITH CHECK (user_id::text = auth.uid()::text);

CREATE POLICY "Users can delete own accounts"
  ON bank_accounts FOR DELETE
  USING (user_id::text = auth.uid()::text);

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_bank_accounts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
CREATE TRIGGER trigger_update_bank_accounts_updated_at
  BEFORE UPDATE ON bank_accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_bank_accounts_updated_at();

-- Comentários
COMMENT ON TABLE bank_accounts IS 'Armazena as contas bancárias dos usuários';
COMMENT ON COLUMN bank_accounts.id IS 'ID único da conta';
COMMENT ON COLUMN bank_accounts.user_id IS 'ID do usuário proprietário';
COMMENT ON COLUMN bank_accounts.name IS 'Nome da conta (Nubank, Itaú, etc)';
COMMENT ON COLUMN bank_accounts.balance IS 'Saldo atual da conta';
COMMENT ON COLUMN bank_accounts.color IS 'Cor para identificação visual';
COMMENT ON COLUMN bank_accounts.icon IS 'Ícone da conta';
COMMENT ON COLUMN bank_accounts.is_active IS 'Indica se a conta está ativa';
