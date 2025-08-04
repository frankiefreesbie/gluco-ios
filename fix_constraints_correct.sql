-- Fix foreign key constraints with the correct constraint names
-- The constraint name has a space, not an underscore

-- Drop the existing constraints with the correct names
ALTER TABLE preparation_steps 
DROP CONSTRAINT IF EXISTS preparation_steps_recipe_id_fkey;

ALTER TABLE recipe_ingredients 
DROP CONSTRAINT IF EXISTS "recipe ingredients_recipe_id_fkey";

ALTER TABLE recipe_ingredients 
DROP CONSTRAINT IF EXISTS "recipe ingredients_ingredient_id_fkey";

-- Recreate with CASCADE DELETE
ALTER TABLE preparation_steps 
ADD CONSTRAINT preparation_steps_recipe_id_fkey 
FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

ALTER TABLE recipe_ingredients 
ADD CONSTRAINT "recipe ingredients_recipe_id_fkey" 
FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

ALTER TABLE recipe_ingredients 
ADD CONSTRAINT "recipe ingredients_ingredient_id_fkey" 
FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE; 