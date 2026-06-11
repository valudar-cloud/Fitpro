-- ══════════════════════════════════════════════════════════
-- FITPRO — Schéma Supabase complet
-- À exécuter dans : Supabase Dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Recherche texte sur exercices

-- ══════════════════════════════════════════════════════════
-- 1. PROFILES
-- ══════════════════════════════════════════════════════════

CREATE TABLE profiles (
  id                   UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email                TEXT NOT NULL,
  full_name            TEXT,
  avatar_url           TEXT,
  language             TEXT DEFAULT 'fr'   CHECK (language IN ('fr','en')),
  goal                 TEXT                CHECK (goal IN ('renforcement','perte_gras','prise_muscle')),
  workout_location     TEXT DEFAULT 'both' CHECK (workout_location IN ('gym','home','both')),
  fitness_level        TEXT DEFAULT 'beginner' CHECK (fitness_level IN ('beginner','intermediate','advanced')),
  age                  SMALLINT            CHECK (age BETWEEN 10 AND 100),
  weight_kg            DECIMAL(5,2),
  height_cm            DECIMAL(5,2),
  gender               TEXT                CHECK (gender IN ('male','female','other')),
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at           TIMESTAMPTZ DEFAULT NOW(),
  updated_at           TIMESTAMPTZ DEFAULT NOW()
);

-- ══════════════════════════════════════════════════════════
-- 2. BLESSURES / DOULEURS
-- ══════════════════════════════════════════════════════════

CREATE TABLE user_injuries (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  injury_zone TEXT NOT NULL CHECK (injury_zone IN (
    'neck','shoulder_left','shoulder_right',
    'elbow_left','elbow_right',
    'wrist_left','wrist_right',
    'back_upper','back_lower','hip',
    'knee_left','knee_right',
    'ankle_left','ankle_right','other'
  )),
  severity    TEXT DEFAULT 'mild' CHECK (severity IN ('mild','moderate','severe')),
  description TEXT,
  is_active   BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ══════════════════════════════════════════════════════════
-- 3. EXERCICES
-- ══════════════════════════════════════════════════════════

CREATE TABLE exercises (
  id                  UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name_fr             TEXT NOT NULL,
  name_en             TEXT NOT NULL,
  description_fr      TEXT,
  description_en      TEXT,
  instructions_fr     TEXT[],
  instructions_en     TEXT[],
  muscle_groups       TEXT[] NOT NULL,
  secondary_muscles   TEXT[],
  goals               TEXT[] NOT NULL,
  locations           TEXT[] NOT NULL,
  difficulty          TEXT DEFAULT 'beginner' CHECK (difficulty IN ('beginner','intermediate','advanced')),
  equipment           TEXT[],
  gif_url             TEXT,
  thumbnail_url       TEXT,
  contraindications   TEXT[],
  duration_seconds    INTEGER,
  sets_recommended    SMALLINT DEFAULT 3,
  reps_recommended    TEXT DEFAULT '10-12',
  rest_seconds        SMALLINT DEFAULT 60,
  calories_per_minute DECIMAL(4,2),
  is_premium          BOOLEAN DEFAULT FALSE,
  is_active           BOOLEAN DEFAULT TRUE,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Index recherche texte
CREATE INDEX idx_exercises_name_fr ON exercises USING gin(to_tsvector('french', name_fr));
CREATE INDEX idx_exercises_goals   ON exercises USING GIN(goals);
CREATE INDEX idx_exercises_locs    ON exercises USING GIN(locations);
CREATE INDEX idx_exercises_muscles ON exercises USING GIN(muscle_groups);

-- ══════════════════════════════════════════════════════════
-- 4. PROGRAMMES D'ENTRAÎNEMENT
-- ══════════════════════════════════════════════════════════

CREATE TABLE workout_programs (
  id             UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id        UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name           TEXT NOT NULL,
  description    TEXT,
  goal           TEXT CHECK (goal IN ('renforcement','perte_gras','prise_muscle')),
  duration_weeks SMALLINT DEFAULT 4,
  days_per_week  SMALLINT DEFAULT 3,
  is_active      BOOLEAN DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE workout_days (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  program_id  UUID REFERENCES workout_programs(id) ON DELETE CASCADE NOT NULL,
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  day_of_week SMALLINT CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Lundi
  week_number SMALLINT DEFAULT 1,
  name        TEXT,
  is_rest_day BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE workout_day_exercises (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  workout_day_id  UUID REFERENCES workout_days(id) ON DELETE CASCADE NOT NULL,
  exercise_id     UUID REFERENCES exercises(id) NOT NULL,
  order_index     SMALLINT DEFAULT 0,
  sets            SMALLINT DEFAULT 3,
  reps            TEXT DEFAULT '10',
  rest_seconds    SMALLINT DEFAULT 60,
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ══════════════════════════════════════════════════════════
-- 5. SESSIONS (HISTORIQUE)
-- ══════════════════════════════════════════════════════════

CREATE TABLE workout_sessions (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  workout_day_id  UUID REFERENCES workout_days(id),
  date            DATE NOT NULL DEFAULT CURRENT_DATE,
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  duration_seconds INTEGER,
  notes           TEXT,
  rating          SMALLINT CHECK (rating BETWEEN 1 AND 5),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE session_exercises (
  id               UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  session_id       UUID REFERENCES workout_sessions(id) ON DELETE CASCADE NOT NULL,
  exercise_id      UUID REFERENCES exercises(id) NOT NULL,
  sets_completed   SMALLINT DEFAULT 0,
  reps_completed   TEXT,
  weight_kg        DECIMAL(5,2),
  duration_seconds INTEGER,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Index optimisé pour le calendrier
CREATE INDEX idx_sessions_user_date ON workout_sessions(user_id, date DESC);

-- ══════════════════════════════════════════════════════════
-- 6. JOURS DE REPOS
-- ══════════════════════════════════════════════════════════

CREATE TABLE rest_days (
  id                  UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id             UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  date                DATE NOT NULL,
  is_active_recovery  BOOLEAN DEFAULT FALSE, -- Étirements, yoga, marche...
  notes               TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

CREATE INDEX idx_rest_days_user_date ON rest_days(user_id, date DESC);

-- ══════════════════════════════════════════════════════════
-- 7. ABONNEMENTS
-- ══════════════════════════════════════════════════════════

CREATE TABLE subscriptions (
  id                      UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id                 UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
  plan                    TEXT NOT NULL DEFAULT 'free'
                            CHECK (plan IN ('free','premium_monthly','premium_annual')),
  status                  TEXT NOT NULL DEFAULT 'active'
                            CHECK (status IN ('active','inactive','cancelled','expired','trial')),
  stripe_customer_id      TEXT,
  stripe_subscription_id  TEXT,
  revenuecat_customer_id  TEXT,
  trial_ends_at           TIMESTAMPTZ,
  current_period_start    TIMESTAMPTZ,
  current_period_end      TIMESTAMPTZ,
  cancelled_at            TIMESTAMPTZ,
  created_at              TIMESTAMPTZ DEFAULT NOW(),
  updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ══════════════════════════════════════════════════════════
-- 8. RPG — PROFIL XP & NIVEAUX
-- ══════════════════════════════════════════════════════════

CREATE TABLE rpg_profiles (
  user_id          UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  total_xp         INTEGER DEFAULT 0 CHECK (total_xp >= 0),
  current_level    SMALLINT DEFAULT 1 CHECK (current_level BETWEEN 1 AND 50),
  rank             TEXT DEFAULT 'initie',
  current_streak   INTEGER DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak   INTEGER DEFAULT 0 CHECK (longest_streak >= 0),
  total_sessions   INTEGER DEFAULT 0 CHECK (total_sessions >= 0),
  total_rest_days  INTEGER DEFAULT 0 CHECK (total_rest_days >= 0),
  quests_completed INTEGER DEFAULT 0 CHECK (quests_completed >= 0),
  unlocked_badges  TEXT[] DEFAULT '{}',
  last_session_at  TIMESTAMPTZ DEFAULT NOW(),
  last_rest_day_at TIMESTAMPTZ,
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Historique des gains XP
CREATE TABLE xp_history (
  id         UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id    UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  amount     INTEGER NOT NULL CHECK (amount > 0),
  source     TEXT NOT NULL,   -- 'complete_session', 'quest_daily', etc.
  quest_id   TEXT,
  earned_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_xp_history_user ON xp_history(user_id, earned_at DESC);

-- ══════════════════════════════════════════════════════════
-- 9. QUÊTES UTILISATEUR
-- ══════════════════════════════════════════════════════════

CREATE TABLE user_quests (
  id            UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id       UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  quest_id      TEXT NOT NULL,
  quest_type    TEXT NOT NULL CHECK (quest_type IN ('daily','weekly','monthly','achievement')),
  quest_category TEXT,
  current_value INTEGER DEFAULT 0,
  target_value  INTEGER NOT NULL,
  status        TEXT DEFAULT 'available'
                  CHECK (status IN ('locked','available','in_progress','completed','claimed','failed')),
  period_start  TIMESTAMPTZ,  -- Début de la période (daily/weekly)
  expires_at    TIMESTAMPTZ,
  completed_at  TIMESTAMPTZ,
  claimed_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, quest_id, period_start)
);

CREATE INDEX idx_user_quests_active ON user_quests(user_id, status)
  WHERE status IN ('available','in_progress','completed');

-- ══════════════════════════════════════════════════════════
-- 10. ROW LEVEL SECURITY (RLS)
-- Chaque utilisateur ne voit QUE ses propres données
-- ══════════════════════════════════════════════════════════

-- profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- user_injuries
ALTER TABLE user_injuries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "injuries_all_own" ON user_injuries FOR ALL USING (auth.uid() = user_id);

-- exercises (lecture publique, écriture service_role uniquement)
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "exercises_read_active" ON exercises FOR SELECT USING (is_active = TRUE);

-- workout_programs
ALTER TABLE workout_programs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "programs_all_own" ON workout_programs FOR ALL USING (auth.uid() = user_id);

-- workout_days
ALTER TABLE workout_days ENABLE ROW LEVEL SECURITY;
CREATE POLICY "days_all_own" ON workout_days FOR ALL USING (auth.uid() = user_id);

-- workout_day_exercises
ALTER TABLE workout_day_exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "day_exercises_all_own" ON workout_day_exercises FOR ALL
  USING (
    workout_day_id IN (
      SELECT id FROM workout_days WHERE user_id = auth.uid()
    )
  );

-- workout_sessions
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sessions_all_own" ON workout_sessions FOR ALL USING (auth.uid() = user_id);

-- session_exercises
ALTER TABLE session_exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "session_ex_all_own" ON session_exercises FOR ALL
  USING (
    session_id IN (
      SELECT id FROM workout_sessions WHERE user_id = auth.uid()
    )
  );

-- rest_days
ALTER TABLE rest_days ENABLE ROW LEVEL SECURITY;
CREATE POLICY "rest_days_all_own" ON rest_days FOR ALL USING (auth.uid() = user_id);

-- subscriptions
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "subs_select_own"  ON subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "subs_service_role" ON subscriptions FOR ALL
  USING (auth.role() = 'service_role');

-- rpg_profiles
ALTER TABLE rpg_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "rpg_all_own" ON rpg_profiles FOR ALL USING (auth.uid() = user_id);

-- xp_history
ALTER TABLE xp_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "xp_all_own" ON xp_history FOR ALL USING (auth.uid() = user_id);

-- user_quests
ALTER TABLE user_quests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "quests_all_own" ON user_quests FOR ALL USING (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════════
-- 11. FONCTIONS & TRIGGERS
-- ══════════════════════════════════════════════════════════

-- Trigger : auto-créer profil + abonnement + profil RPG à l'inscription
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Athlète')
  );

  INSERT INTO subscriptions (user_id, plan, status)
  VALUES (NEW.id, 'free', 'active');

  INSERT INTO rpg_profiles (user_id, total_xp, current_level, rank)
  VALUES (NEW.id, 0, 1, 'initie');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Trigger : updated_at automatique
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_programs_updated_at
  BEFORE UPDATE ON workout_programs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_subs_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_rpg_updated_at
  BEFORE UPDATE ON rpg_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Fonctions RPC appelées depuis Flutter ─────────────────

-- Incrémenter le total de séances
CREATE OR REPLACE FUNCTION increment_total_sessions(uid UUID)
RETURNS VOID AS $$
  UPDATE rpg_profiles
  SET total_sessions = total_sessions + 1
  WHERE user_id = uid;
$$ LANGUAGE sql SECURITY DEFINER;

-- Incrémenter les jours de repos
CREATE OR REPLACE FUNCTION increment_rest_days(uid UUID)
RETURNS VOID AS $$
  UPDATE rpg_profiles
  SET total_rest_days = total_rest_days + 1
  WHERE user_id = uid;
$$ LANGUAGE sql SECURITY DEFINER;

-- Incrémenter les quêtes complétées
CREATE OR REPLACE FUNCTION increment_quests_completed(uid UUID)
RETURNS VOID AS $$
  UPDATE rpg_profiles
  SET quests_completed = quests_completed + 1
  WHERE user_id = uid;
$$ LANGUAGE sql SECURITY DEFINER;

-- Ajouter de l'XP et mettre à jour le niveau
CREATE OR REPLACE FUNCTION add_xp(uid UUID, amount INTEGER)
RETURNS INTEGER AS $$
DECLARE
  new_xp INTEGER;
BEGIN
  UPDATE rpg_profiles
  SET total_xp = total_xp + amount
  WHERE user_id = uid
  RETURNING total_xp INTO new_xp;

  RETURN new_xp;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mise à jour de la progression des quêtes selon un trigger
CREATE OR REPLACE FUNCTION update_quest_progress(
  uid UUID,
  trigger_name TEXT,
  increment_by INTEGER
)
RETURNS VOID AS $$
BEGIN
  -- Quêtes liées à session_completed
  IF trigger_name = 'session_completed' THEN
    UPDATE user_quests
    SET
      current_value = LEAST(current_value + increment_by, target_value),
      status = CASE
        WHEN current_value + increment_by >= target_value THEN 'completed'
        ELSE 'in_progress'
      END
    WHERE user_id = uid
      AND quest_id IN ('daily_session','weekly_sessions_3','weekly_sessions_5',
                       'ach_sessions_10','ach_sessions_50','ach_sessions_100','ach_sessions_365')
      AND status IN ('available','in_progress');
  END IF;

  -- Quêtes liées à rest_day_taken
  IF trigger_name = 'rest_day_taken' THEN
    UPDATE user_quests
    SET
      current_value = LEAST(current_value + increment_by, target_value),
      status = CASE
        WHEN current_value + increment_by >= target_value THEN 'completed'
        ELSE 'in_progress'
      END
    WHERE user_id = uid
      AND quest_id IN ('daily_rest','weekly_rest_days','ach_rest_master')
      AND status IN ('available','in_progress');
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ══════════════════════════════════════════════════════════
-- 12. RÉINITIALISATION AUTO DES QUÊTES DAILY/WEEKLY
-- (à appeler via Supabase Edge Function ou cron pg_cron)
-- ══════════════════════════════════════════════════════════

-- Extension cron (activer dans Supabase Dashboard → Database → Extensions)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Réinitialisation des quêtes quotidiennes à minuit
-- SELECT cron.schedule('reset-daily-quests', '0 0 * * *', $$
--   UPDATE user_quests
--   SET current_value = 0,
--       status = 'available',
--       period_start = NOW()
--   WHERE quest_type = 'daily'
--     AND status IN ('available','in_progress','failed');
-- $$);

-- Réinitialisation des quêtes hebdomadaires le lundi
-- SELECT cron.schedule('reset-weekly-quests', '0 0 * * 1', $$
--   UPDATE user_quests
--   SET current_value = 0,
--       status = 'available',
--       period_start = NOW()
--   WHERE quest_type = 'weekly'
--     AND status IN ('available','in_progress','failed');
-- $$);

-- ══════════════════════════════════════════════════════════
-- 13. INDEXES SUPPLÉMENTAIRES
-- ══════════════════════════════════════════════════════════

CREATE INDEX idx_sessions_date    ON workout_sessions(date DESC);
CREATE INDEX idx_rest_days_date   ON rest_days(date DESC);
CREATE INDEX idx_xp_source        ON xp_history(source);
CREATE INDEX idx_subs_plan_status ON subscriptions(plan, status);

-- ══════════════════════════════════════════════════════════
-- 14. COMPTEUR DE PAS QUOTIDIEN
-- ══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS daily_steps (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  date         DATE NOT NULL DEFAULT CURRENT_DATE,
  steps        INTEGER DEFAULT 0 CHECK (steps >= 0),
  calories     DECIMAL(8,2) DEFAULT 0,
  distance_km  DECIMAL(6,3) DEFAULT 0,
  updated_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

ALTER TABLE daily_steps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "steps_all_own" ON daily_steps FOR ALL USING (auth.uid() = user_id);

CREATE INDEX idx_daily_steps_user_date ON daily_steps(user_id, date DESC);

-- ══════════════════════════════════════════════════════════
-- 15. ABSTINENCES
-- ══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS abstinence_trackers (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name        TEXT NOT NULL,
  icon        TEXT DEFAULT '🚫',
  category    TEXT DEFAULT 'custom',
  start_date  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active   BOOLEAN DEFAULT TRUE,
  custom_note TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE abstinence_trackers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "abstinence_own" ON abstinence_trackers
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX idx_abstinence_user ON abstinence_trackers(user_id, is_active);

-- ══════════════════════════════════════════════════════════
-- 16. NUTRITION
-- ══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS meal_logs (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  food_id    TEXT NOT NULL,
  food_name  TEXT NOT NULL,
  food_icon  TEXT DEFAULT '🍽️',
  grams      DECIMAL(7,2) DEFAULT 100,
  calories   DECIMAL(8,2) DEFAULT 0,
  proteins   DECIMAL(7,2) DEFAULT 0,
  carbs      DECIMAL(7,2) DEFAULT 0,
  lipids     DECIMAL(7,2) DEFAULT 0,
  meal_type  TEXT DEFAULT 'lunch'
               CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
  date       DATE NOT NULL DEFAULT CURRENT_DATE,
  logged_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE meal_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "meal_logs_own" ON meal_logs
  FOR ALL USING (auth.uid() = user_id);

CREATE INDEX idx_meal_logs_user_date ON meal_logs(user_id, date DESC);

CREATE TABLE IF NOT EXISTS custom_recipes (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name         TEXT NOT NULL,
  icon         TEXT DEFAULT '🍽️',
  goal         TEXT DEFAULT 'les_deux',
  servings     SMALLINT DEFAULT 1,
  calories     DECIMAL(8,2) DEFAULT 0,
  proteins     DECIMAL(7,2) DEFAULT 0,
  carbs        DECIMAL(7,2) DEFAULT 0,
  lipids       DECIMAL(7,2) DEFAULT 0,
  instructions TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE custom_recipes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "recipes_own" ON custom_recipes
  FOR ALL USING (auth.uid() = user_id);
