-- =====================================================
-- TABELA: profiles
-- Descrição: Armazena informações de perfil dos usuários
-- =====================================================

-- Criar tabela profiles
CREATE TABLE IF NOT EXISTS public.profiles (
    -- Identificação
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Informações pessoais
    full_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    birth_date TIMESTAMPTZ,
    tax_id TEXT,
    bio TEXT,

    -- Estatísticas (JSONB para flexibilidade)
    stats JSONB DEFAULT '{
        "totalTasks": 0,
        "completedTasks": 0,
        "totalCompanies": 0,
        "totalTransactions": 0,
        "totalBalance": 0.0,
        "daysActive": 0,
        "dailyStreak": 0,
        "achievements": []
    }'::jsonb,

    -- Configurações (JSONB para flexibilidade)
    settings JSONB DEFAULT '{
        "theme": "auto",
        "fontSize": "medium",
        "pushNotificationsEnabled": true,
        "emailNotificationsEnabled": true,
        "taskRemindersEnabled": true,
        "financeAlertsEnabled": true,
        "dailyReminderTime": "09:00",
        "language": "pt-BR",
        "biometricsEnabled": false,
        "autoBackupEnabled": true,
        "autoSyncEnabled": true,
        "analyticsEnabled": true,
        "showTutorial": true,
        "developerMode": false
    }'::jsonb,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES
-- =====================================================

-- Índice para busca por telefone
CREATE INDEX IF NOT EXISTS idx_profiles_phone
ON public.profiles(phone);

-- Índice para busca por tax_id (CPF/CNPJ)
CREATE INDEX IF NOT EXISTS idx_profiles_tax_id
ON public.profiles(tax_id);

-- Índice GIN para busca eficiente em JSONB stats
CREATE INDEX IF NOT EXISTS idx_profiles_stats
ON public.profiles USING GIN (stats);

-- Índice GIN para busca eficiente em JSONB settings
CREATE INDEX IF NOT EXISTS idx_profiles_settings
ON public.profiles USING GIN (settings);

-- =====================================================
-- RLS (Row Level Security)
-- =====================================================

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem visualizar apenas seu próprio perfil
CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

-- Política: Usuários podem atualizar apenas seu próprio perfil
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id);

-- Política: Usuários podem inserir apenas seu próprio perfil
CREATE POLICY "Users can insert own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Política: Usuários podem deletar apenas seu próprio perfil
CREATE POLICY "Users can delete own profile"
ON public.profiles
FOR DELETE
USING (auth.uid() = id);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Função para criar perfil automaticamente quando usuário é criado
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- STORAGE BUCKET para avatars
-- =====================================================

-- Criar bucket para profiles (avatars)
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Política: Usuários podem fazer upload de seus avatares
CREATE POLICY "Users can upload own avatar"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profiles'
    AND (storage.foldername(name))[1] = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[2]
);

-- Política: Usuários podem atualizar seus avatares
CREATE POLICY "Users can update own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'profiles'
    AND (storage.foldername(name))[1] = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[2]
);

-- Política: Usuários podem deletar seus avatares
CREATE POLICY "Users can delete own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'profiles'
    AND (storage.foldername(name))[1] = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[2]
);

-- Política: Todos podem ver avatares públicos
CREATE POLICY "Public avatars are viewable by everyone"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'profiles' AND (storage.foldername(name))[1] = 'avatars');

-- =====================================================
-- COMENTÁRIOS
-- =====================================================

COMMENT ON TABLE public.profiles IS 'Perfis dos usuários do sistema';
COMMENT ON COLUMN public.profiles.id IS 'ID do usuário (referência para auth.users)';
COMMENT ON COLUMN public.profiles.full_name IS 'Nome completo do usuário';
COMMENT ON COLUMN public.profiles.avatar_url IS 'URL da foto de perfil';
COMMENT ON COLUMN public.profiles.phone IS 'Telefone de contato';
COMMENT ON COLUMN public.profiles.birth_date IS 'Data de nascimento';
COMMENT ON COLUMN public.profiles.tax_id IS 'CPF ou CNPJ';
COMMENT ON COLUMN public.profiles.bio IS 'Biografia/descrição do usuário';
COMMENT ON COLUMN public.profiles.stats IS 'Estatísticas do usuário em formato JSON';
COMMENT ON COLUMN public.profiles.settings IS 'Configurações do usuário em formato JSON';
COMMENT ON COLUMN public.profiles.created_at IS 'Data de criação do perfil';
COMMENT ON COLUMN public.profiles.updated_at IS 'Data da última atualização';
