#!/usr/bin/env python3
"""
Glucko Missing Ingredients Fix Script
Fixes missing ingredients for specific recipes
"""

import requests
import json

class MissingIngredientsFixer:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def get_recipe_by_name(self, recipe_name: str):
        """Get recipe by name (with fuzzy matching)"""
        try:
            # Try exact match first
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers
            )
            
            if response.status_code == 200:
                recipes = response.json()
                if recipes:
                    return recipes[0]
            
            # Try partial match
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=ilike.*{recipe_name}*',
                headers=self.headers
            )
            
            if response.status_code == 200:
                recipes = response.json()
                if recipes:
                    return recipes[0]
            
            return None
                
        except Exception as e:
            print(f"❌ Error finding recipe {recipe_name}: {str(e)}")
            return None
    
    def ensure_ingredient_exists(self, ingredient_name: str) -> str:
        """Ensure ingredient exists, create if it doesn't"""
        try:
            # Check if ingredient exists
            response = requests.get(
                f'{self.supabase_url}/rest/v1/ingredients?name=eq.{ingredient_name}',
                headers=self.headers
            )
            
            if response.status_code == 200:
                ingredients = response.json()
                if ingredients:
                    return ingredients[0]['id']
            
            # Create ingredient if it doesn't exist
            create_response = requests.post(
                f'{self.supabase_url}/rest/v1/ingredients',
                headers=self.headers,
                json={'name': ingredient_name}
            )
            
            if create_response.status_code in [200, 201]:
                return create_response.json()[0]['id']
            else:
                print(f"❌ Failed to create ingredient {ingredient_name}: {create_response.text}")
                return None
                
        except Exception as e:
            print(f"❌ Error ensuring ingredient exists {ingredient_name}: {str(e)}")
            return None
    
    def upload_ingredient(self, recipe_id: str, ingredient: dict):
        """Upload a single ingredient"""
        try:
            # First, ensure ingredient exists
            ingredient_id = self.ensure_ingredient_exists(ingredient['name'])
            
            if not ingredient_id:
                print(f"❌ Could not create ingredient: {ingredient['name']}")
                return False
            
            payload = {
                'recipe_id': recipe_id,
                'ingredient_id': ingredient_id,
                'amount': ingredient['amount'],
                'quantity_value': ingredient.get('quantity_value'),
                'quantity_unit': ingredient.get('quantity_unit'),
                'is_optional': ingredient.get('is_optional', False),
                'show_in_list': ingredient.get('show_in_list', True)
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/recipe_ingredients',
                headers=self.headers,
                json=payload
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ Added ingredient: {ingredient['name']}")
                return True
            else:
                print(f"❌ Failed to add ingredient {ingredient['name']}: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error adding ingredient {ingredient['name']}: {str(e)}")
            return False
    
    def fix_recipe_ingredients(self, recipe_name: str, ingredients: list):
        """Fix ingredients for a specific recipe"""
        print(f"🔧 Fixing ingredients for: {recipe_name}")
        
        # Find the recipe
        recipe = self.get_recipe_by_name(recipe_name)
        
        if not recipe:
            print(f"❌ Recipe not found: {recipe_name}")
            return False
        
        recipe_id = recipe['id']
        print(f"📝 Found recipe ID: {recipe_id}")
        
        # Upload each ingredient
        success_count = 0
        for ingredient in ingredients:
            if self.upload_ingredient(recipe_id, ingredient):
                success_count += 1
        
        print(f"✅ Successfully added {success_count}/{len(ingredients)} ingredients for {recipe_name}")
        return success_count == len(ingredients)

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    fixer = MissingIngredientsFixer(SUPABASE_URL, SUPABASE_KEY)
    
    # Load recipes from JSON to get the correct ingredients
    with open('recipes.json', 'r', encoding='utf-8') as file:
        recipes = json.load(file)
    
    # Find the recipes that need fixing
    recipes_to_fix = {
        "Avocado with hummus and lemon": None,
        "Tomato Toast & Burrata": None
    }
    
    for recipe in recipes:
        if recipe['name'] in recipes_to_fix:
            recipes_to_fix[recipe['name']] = recipe['ingredients']
    
    print("🔧 Fixing missing ingredients...")
    print("=" * 50)
    
    for recipe_name, ingredients in recipes_to_fix.items():
        if ingredients:
            fixer.fix_recipe_ingredients(recipe_name, ingredients)
            print()
        else:
            print(f"❌ Recipe not found in JSON: {recipe_name}")
    
    print("✅ Done! Check the ingredients again.")

if __name__ == "__main__":
    main() 