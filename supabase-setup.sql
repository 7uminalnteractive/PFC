-- ════════════════════════════════════════════════════════════
-- BOLÃO+ — SETUP COMPLETO DO BANCO DE DADOS (SUPABASE)
-- Execute este script no SQL Editor do seu projeto Supabase
-- ════════════════════════════════════════════════════════════


-- ─────────────────────────────────────
-- 1. TABELA: profiles
--    Armazena nome e e-mail dos usuários
-- ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT,
  email       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Qualquer usuário autenticado pode ler todos os perfis (admin precisa)
CREATE POLICY "profiles_select" ON public.profiles
  FOR SELECT TO authenticated USING (true);

-- Cada usuário pode inserir/atualizar apenas o próprio perfil
CREATE POLICY "profiles_insert" ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update" ON public.profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id);


-- ─────────────────────────────────────
-- 2. TABELA: games
--    Jogos cadastrados pelo admin
-- ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.games (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  home_team    TEXT NOT NULL,
  away_team    TEXT NOT NULL,
  match_date   TIMESTAMPTZ,
  competition  TEXT,
  status       TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;

-- Qualquer autenticado pode ler os jogos
CREATE POLICY "games_select" ON public.games
  FOR SELECT TO authenticated USING (true);

-- Somente admin pode inserir, atualizar e deletar
-- (substitua pelo e-mail real do seu admin)
CREATE POLICY "games_insert" ON public.games
  FOR INSERT TO authenticated
  WITH CHECK (
    (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@bolao.com'
  );

CREATE POLICY "games_update" ON public.games
  FOR UPDATE TO authenticated
  USING (
    (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@bolao.com'
  );

CREATE POLICY "games_delete" ON public.games
  FOR DELETE TO authenticated
  USING (
    (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@bolao.com'
  );


-- ─────────────────────────────────────
-- 3. TABELA: guesses
--    Palpites de cada participante
-- ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guesses (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  game_id     UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
  home_score  INT NOT NULL DEFAULT 0 CHECK (home_score >= 0),
  away_score  INT NOT NULL DEFAULT 0 CHECK (away_score >= 0),
  created_at  TIMESTAMPTZ DEFAULT NOW(),

  -- Garante um palpite por usuário por jogo (upsert seguro)
  UNIQUE (user_id, game_id)
);

-- RLS
ALTER TABLE public.guesses ENABLE ROW LEVEL SECURITY;

-- Cada usuário pode ver apenas os próprios palpites
CREATE POLICY "guesses_select_own" ON public.guesses
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- Admin pode ver todos os palpites
CREATE POLICY "guesses_select_admin" ON public.guesses
  FOR SELECT TO authenticated
  USING (
    (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@bolao.com'
  );

-- Usuário pode inserir/atualizar os próprios palpites
CREATE POLICY "guesses_insert" ON public.guesses
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "guesses_update" ON public.guesses
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);


-- ─────────────────────────────────────
-- 4. TRIGGER: auto-criar perfil
--    Cria o registro em profiles quando
--    um usuário se registra via auth
-- ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ─────────────────────────────────────
-- 5. ÍNDICES para performance
-- ─────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_guesses_user_id ON public.guesses(user_id);
CREATE INDEX IF NOT EXISTS idx_guesses_game_id ON public.guesses(game_id);
CREATE INDEX IF NOT EXISTS idx_games_status    ON public.games(status);
CREATE INDEX IF NOT EXISTS idx_games_date      ON public.games(match_date);


-- ════════════════════════════════════════════════════════════
-- PRONTO! Banco configurado.
-- Lembre de substituir 'admin@bolao.com' pelo e-mail real
-- do admin em todas as policies e nos arquivos HTML.
-- ════════════════════════════════════════════════════════════
