-- Fix delete behavior for existing foreign key constraints
-- This script only modifies the delete behavior without recreating constraints

-- First, let's see the current state of constraints
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
    LEFT JOIN information_schema.referential_constraints AS rc
      ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name IN ('preparation_steps', 'recipe_ingredients');

-- Drop only the problematic constraint with the space in the name
ALTER TABLE recipe_ingredients 
DROP CONSTRAINT IF EXISTS "recipe ingredients_recipe_id_fkey";

-- Recreate only that specific constraint with CASCADE DELETE
ALTER TABLE recipe_ingredients 
ADD CONSTRAINT "recipe ingredients_recipe_id_fkey" 
FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

-- Verify the fix
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