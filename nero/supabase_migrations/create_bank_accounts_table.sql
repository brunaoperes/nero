-- Tabela de contas bancárias
-- Armazena informações sobre contas/bancos do usuário com seus saldos

CREATE TABLE IF NOT EXISTS bank_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  color TEXT, -- Cor para identificação visual da conta
  icon TEXT, -- Nome do ícone (opcional)
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar a performance
CREATE INDEX IF NOT EXISTS idx_bank_accounts_user_id ON bank_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_bank_accounts_is_active ON bank_accounts(is_active);
CREATE INDEX IF NOT EXISTS idx_bank_accounts_user_active ON bank_accounts(user_id, is_active);

-- Row Level Security (RLS)
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver apenas suas próprias contas
CREATE POLICY "Users can view their own bank accounts"
  ON bank_accounts FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Usuários podem inserir suas próprias contas
CREATE POLICY "Users can insert their own bank accounts"
  ON bank_accounts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem atualizar suas próprias contas
CREATE POLICY "Users can update their own bank accounts"
  ON bank_accounts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem deletar suas próprias contas
CREATE POLICY "Users can delete their own bank accounts"
  ON bank_accounts FOR DELETE
  USING (auth.uid() = user_id);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_bank_accounts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
CREATE TRIGGER update_bank_accounts_updated_at
  BEFORE UPDATE ON bank_accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_bank_accounts_updated_at();

-- Comentários para documentação
COMMENT ON TABLE bank_accounts IS 'Armazena as contas bancárias dos usuários com seus saldos';
COMMENT ON COLUMN bank_accounts.id IS 'Identificador único da conta';
COMMENT ON COLUMN bank_accounts.user_id IS 'ID do usuário dono da conta';
COMMENT ON COLUMN bank_accounts.name IS 'Nome da conta (ex: Nubank, Itaú, Carteira)';
COMMENT ON COLUMN bank_accounts.balance IS 'Saldo atual da conta';
COMMENT ON COLUMN bank_accounts.color IS 'Cor para identificação visual';
COMMENT ON COLUMN bank_accounts.icon IS 'Nome do ícone para a conta';
COMMENT ON COLUMN bank_accounts.is_active IS 'Indica se a conta está ativa';
