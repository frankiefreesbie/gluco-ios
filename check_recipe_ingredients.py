#!/usr/bin/env python3
"""
Glucko Recipe Ingredients Check Script
Checks which recipes have ingredients and which are missing them
"""

import requests
import json

class RecipeIngredientChecker:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def get_all_recipes(self):
        """Get all recipes from the database"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes',
                headers=self.headers
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                print(f"❌ Failed to fetch recipes: {response.text}")
                return []
                
        except Exception as e:
            print(f"❌ Error fetching recipes: {str(e)}")
            return []
    
    def get_recipe_ingredients(self, recipe_id: str):
        """Get ingredients for a specific recipe"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipe_ingredients?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                print(f"❌ Failed to fetch ingredients for recipe {recipe_id}: {response.text}")
                return []
                
        except Exception as e:
            print(f"❌ Error fetching ingredients for recipe {recipe_id}: {str(e)}")
            return []
    
    def check_all_recipes(self):
        """Check all recipes for missing ingredients"""
        print("🔍 Checking recipes for ingredients...")
        print("=" * 50)
        
        recipes = self.get_all_recipes()
        
        if not recipes:
            print("❌ No recipes found in database")
            return
        
        print(f"📊 Found {len(recipes)} recipes in database")
        print()
        
        recipes_with_ingredients = []
        recipes_without_ingredients = []
        
        for recipe in recipes:
            recipe_name = recipe['name']
            recipe_id = recipe['id']
            
            ingredients = self.get_recipe_ingredients(recipe_id)
            
            if ingredients:
                recipes_with_ingredients.append(recipe_name)
                print(f"✅ {recipe_name}: {len(ingredients)} ingredients")
            else:
                recipes_without_ingredients.append(recipe_name)
                print(f"❌ {recipe_name}: NO INGREDIENTS")
        
        print()
        print("=" * 50)
        print(f"📊 Summary:")
        print(f"✅ Recipes with ingredients: {len(recipes_with_ingredients)}")
        print(f"❌ Recipes without ingredients: {len(recipes_without_ingredients)}")
        
        if recipes_without_ingredients:
            print(f"\n❌ Recipes missing ingredients:")
            for recipe in recipes_without_ingredients:
                print(f"  • {recipe}")
        
        return recipes_without_ingredients

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    checker = RecipeIngredientChecker(SUPABASE_URL, SUPABASE_KEY)
    missing_ingredients = checker.check_all_recipes()
    
    if missing_ingredients:
        print(f"\n🔧 Next step: Run the upload script to add missing ingredients")

if __name__ == "__main__":
    main() 