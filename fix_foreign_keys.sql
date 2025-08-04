-- Fix foreign key constraints to enable cascading deletes
-- This script will update the existing foreign key constraints to properly handle cascading deletes

-- First, drop the existing foreign key constraints
ALTER TABLE preparation_steps 
DROP CONSTRAINT IF EXISTS preparation_steps_recipe_id_fkey;

ALTER TABLE recipe_ingredients 
DROP CONSTRAINT IF EXISTS recipe_ingredients_recipe_id_fkey;

ALTER TABLE recipe_ingredients 
DROP CONSTRAINT IF EXISTS recipe_ingredients_ingredient_id_fkey;

-- Recreate the foreign key constraints with CASCADE DELETE
ALTER TABLE preparation_steps 
ADD CONSTRAINT preparation_steps_recipe_id_fkey 
FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

ALTER TABLE recipe_ingredients 
ADD CONSTRAINT recipe_ingredients_recipe_id_fkey 
FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

ALTER TABLE recipe_ingredients 
ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey 
FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE;

-- Verify the constraints are properly set up
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    JOIN information_schema.referential_constraints AS rc
      ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name IN ('preparation_steps', 'recipe_ingredients'); 