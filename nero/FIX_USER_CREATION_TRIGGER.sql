-- =====================================================
-- FIX: Criar usuários automaticamente em public.users
-- =====================================================
--
-- PROBLEMA:
-- Usuários se autenticam via Supabase Auth (auth.users)
-- mas não são criados automaticamente em public.users,
-- causando erro 409 ao criar empresas.
--
-- SOLUÇÃO:
-- 1. Criar função para copiar usuário de auth.users para public.users
-- 2. Criar trigger que executa essa função automaticamente
-- 3. Inserir usuários existentes que ainda não estão em public.users
-- =====================================================

-- 1. Criar a função que copia o usuário para public.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, avatar_url, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'avatar_url',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING; -- Se já existir, não faz nada

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Criar o trigger que executa após INSERT em auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 3. Inserir usuários existentes do auth.users que ainda não estão em public.users
INSERT INTO public.users (id, email, name, avatar_url, created_at, updated_at)
SELECT
  au.id,
  au.email,
  au.raw_user_meta_data->>'name' as name,
  au.raw_user_meta_data->>'avatar_url' as avatar_url,
  au.created_at,
  NOW() as updated_at
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL; -- Apenas usuários que ainda não existem em public.users

-- 4. Verificar o resultado
SELECT
  'Trigger criado com sucesso!' as status,
  COUNT(*) as total_users_in_public
FROM public.users;

-- 5. Mostrar usuários em public.users
SELECT
  id,
  email,
  name,
  created_at
FROM public.users
ORDER BY created_at DESC;
