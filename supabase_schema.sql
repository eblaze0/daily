-- Users (handled by Supabase Auth, but we'll extend with profiles)
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    age INTEGER,
    gender TEXT,
    height_cm REAL,
    weight_kg REAL,
    fitness_goal TEXT,
    experience_level TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Equipment
CREATE TABLE equipment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    specifications JSONB,
    is_available BOOLEAN DEFAULT true,
    gym_location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Muscle Groups (reference table)
CREATE TABLE muscle_groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL, -- legs, back, chest, shoulders, arms
    subcategory TEXT -- calves, hamstrings, upper, mid, etc.
);

-- Exercises
CREATE TABLE exercises (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    name TEXT NOT NULL,
    instructions TEXT,
    video_url TEXT,
    movement_pattern TEXT,
    is_custom BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise Equipment Junction
CREATE TABLE exercise_equipment (
    exercise_id UUID REFERENCES exercises,
    equipment_id UUID REFERENCES equipment,
    is_primary BOOLEAN DEFAULT true,
    PRIMARY KEY (exercise_id, equipment_id)
);

-- Exercise Muscle Groups Junction
CREATE TABLE exercise_muscle_groups (
    exercise_id UUID REFERENCES exercises,
    muscle_group_id UUID REFERENCES muscle_groups,
    is_primary BOOLEAN DEFAULT true,
    PRIMARY KEY (exercise_id, muscle_group_id)
);

-- Workout Sessions
CREATE TABLE workout_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    date DATE NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    pre_workout_mobility INTEGER CHECK (pre_workout_mobility BETWEEN 1 AND 5),
    post_workout_soreness INTEGER CHECK (post_workout_soreness BETWEEN 1 AND 5),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise Sets
CREATE TABLE exercise_sets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workout_session_id UUID REFERENCES workout_sessions,
    exercise_id UUID REFERENCES exercises,
    set_number INTEGER NOT NULL,
    reps INTEGER,
    weight_kg REAL,
    effort_rating INTEGER CHECK (effort_rating BETWEEN 1 AND 5),
    rest_duration_seconds INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Personal Records
CREATE TABLE personal_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    exercise_id UUID REFERENCES exercises,
    record_type TEXT NOT NULL, -- max_weight, max_reps, max_volume
    value REAL NOT NULL,
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Chat History
CREATE TABLE ai_chat_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    message TEXT NOT NULL,
    is_user_message BOOLEAN NOT NULL,
    context_data JSONB, -- workout data context
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;

-- Policies (users can only access their own data)
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own equipment" ON equipment
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own exercises" ON exercises
    FOR ALL USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Users can view public exercises" ON exercises
    FOR SELECT USING (is_public = true);

CREATE POLICY "Users can manage own workout sessions" ON workout_sessions
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own exercise sets" ON exercise_sets
    FOR ALL USING (
        workout_session_id IN (
            SELECT id FROM workout_sessions WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage own personal records" ON personal_records
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own chat history" ON ai_chat_history
    FOR ALL USING (auth.uid() = user_id);

-- Populate the muscle groups reference table
INSERT INTO muscle_groups (name, category, subcategory) VALUES
-- Legs
('Calves', 'legs', 'Calves'),
('Hamstrings', 'legs', 'Hamstrings'),
('Quads', 'legs', 'Quads'),
('Glutes', 'legs', 'Glutes'),
('Hip Flexors', 'legs', 'Hip Flexors'),

-- Back
('Upper Back', 'back', 'Upper Back (Traps/Rhomboids)'),
('Mid Back', 'back', 'Mid Back (Lats)'),
('Lower Back', 'back', 'Lower Back (Erector Spinae)'),

-- Chest
('Upper Chest', 'chest', 'Upper Chest'),
('Middle Chest', 'chest', 'Middle Chest'),
('Lower Chest', 'chest', 'Lower Chest'),

-- Shoulders
('Front Delt', 'shoulders', 'Front Delt'),
('Side Delt', 'shoulders', 'Side Delt'),
('Rear Delt', 'shoulders', 'Rear Delt'),

-- Arms
('Biceps - Long Head', 'arms', 'Biceps - Long Head'),
('Biceps - Short Head', 'arms', 'Biceps - Short Head'),
('Triceps - Long Head', 'arms', 'Triceps - Long Head'),
('Triceps - Lateral Head', 'arms', 'Triceps - Lateral Head'),
('Triceps - Medial Head', 'arms', 'Triceps - Medial Head'),
('Forearms', 'arms', 'Forearms'),

-- Core
('Abs - Upper', 'core', 'Abs - Upper'),
('Abs - Lower', 'core', 'Abs - Lower'),
('Obliques', 'core', 'Obliques'),
('Transverse Abdominis', 'core', 'Transverse Abdominis');

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to update the updated_at column
CREATE TRIGGER update_user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column(); 