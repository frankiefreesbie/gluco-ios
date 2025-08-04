-- Create ingredients table
CREATE TABLE IF NOT EXISTS ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create preparation_steps table
CREATE TABLE IF NOT EXISTS preparation_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(recipe_id, step_number)
);

-- Create recipe_ingredients table
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE,
    amount TEXT NOT NULL,
    quantity_value FLOAT,
    quantity_unit TEXT,
    is_optional BOOLEAN DEFAULT FALSE,
    show_in_list BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(recipe_id, ingredient_id)
);

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE preparation_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY;

-- Create policies to allow all operations (for development)
CREATE POLICY "Allow all operations on ingredients" ON ingredients FOR ALL USING (true);
CREATE POLICY "Allow all operations on preparation_steps" ON preparation_steps FOR ALL USING (true);
CREATE POLICY "Allow all operations on recipe_ingredients" ON recipe_ingredients FOR ALL USING (true); 