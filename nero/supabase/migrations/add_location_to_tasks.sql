-- Adiciona campos de localização à tabela tasks
-- Execute este script no Supabase Dashboard > SQL Editor

-- Adicionar colunas de localização
ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS location_name TEXT,
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Comentários nas colunas
COMMENT ON COLUMN public.tasks.location_name IS 'Nome do local/endereço associado à tarefa';
COMMENT ON COLUMN public.tasks.latitude IS 'Latitude da localização (coordenadas geográficas)';
COMMENT ON COLUMN public.tasks.longitude IS 'Longitude da localização (coordenadas geográficas)';

-- Índice para buscas geoespaciais (opcional, mas recomendado)
CREATE INDEX IF NOT EXISTS tasks_location_idx ON public.tasks (latitude, longitude)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
