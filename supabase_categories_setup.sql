-- ============================================
-- NERO - Tabela de Categorias
-- ============================================
-- Este script cria a tabela de categorias de transações
-- Execute ANTES do script de Open Finance se ainda não tiver criado
-- ============================================

-- Tabela de categorias
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type);
CREATE INDEX IF NOT EXISTS idx_categories_is_system ON categories(is_system);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
DROP POLICY IF EXISTS "Users can view system categories" ON categories;
CREATE POLICY "Users can view system categories"
  ON categories FOR SELECT
  USING (is_system = true OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view their own categories" ON categories;
CREATE POLICY "Users can view their own categories"
  ON categories FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own categories" ON categories;
CREATE POLICY "Users can insert their own categories"
  ON categories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own categories" ON categories;
CREATE POLICY "Users can update their own categories"
  ON categories FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own categories" ON categories;
CREATE POLICY "Users can delete their own categories"
  ON categories FOR DELETE
  USING (auth.uid() = user_id AND is_system = false);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
CREATE TRIGGER update_categories_updated_at
  BEFORE UPDATE ON categories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- CATEGORIAS PADRÃO DO SISTEMA
-- ============================================

-- Despesas
INSERT INTO categories (name, icon, color, type, is_system) VALUES
  ('Alimentação', '🍽️', '#FF5252', 'expense', true),
  ('Transporte', '🚗', '#FF9800', 'expense', true),
  ('Moradia', '🏠', '#9C27B0', 'expense', true),
  ('Saúde', '💊', '#F06292', 'expense', true),
  ('Educação', '📚', '#3F51B5', 'expense', true),
  ('Lazer', '🎮', '#00BCD4', 'expense', true),
  ('Compras', '🛍️', '#E91E63', 'expense', true),
  ('Contas', '📄', '#607D8B', 'expense', true),
  ('Investimentos', '💰', '#4CAF50', 'expense', true),
  ('Outros', '📦', '#9E9E9E', 'expense', true)
ON CONFLICT DO NOTHING;

-- Receitas
INSERT INTO categories (name, icon, color, type, is_system) VALUES
  ('Salário', '💵', '#4CAF50', 'income', true),
  ('Freelance', '💼', '#00BCD4', 'income', true),
  ('Investimentos', '📈', '#2196F3', 'income', true),
  ('Vendas', '🛒', '#FF9800', 'income', true),
  ('Prêmios', '🏆', '#FFC107', 'income', true),
  ('Outros', '💸', '#9E9E9E', 'income', true)
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICAÇÃO
-- ============================================

SELECT
  COUNT(*) as total_categories,
  COUNT(CASE WHEN is_system = true THEN 1 END) as system_categories,
  COUNT(CASE WHEN type = 'expense' THEN 1 END) as expense_categories,
  COUNT(CASE WHEN type = 'income' THEN 1 END) as income_categories
FROM categories;
