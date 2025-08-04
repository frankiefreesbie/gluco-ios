#!/usr/bin/env python3
"""
Test Ingredients Query
Test if ingredients can be fetched after fixing constraints
"""

import requests
import json

def test_ingredients_query():
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
    }
    
    print("🧪 Testing ingredients query...")
    
    # First, get a recipe
    recipes_response = requests.get(f'{SUPABASE_URL}/rest/v1/recipes?name=eq.Dressed Apple', headers=headers)
    if recipes_response.status_code == 200:
        recipes = recipes_response.json()
        if recipes:
            recipe = recipes[0]
            recipe_id = recipe['id']
            print(f"✅ Found recipe: {recipe['name']} (ID: {recipe_id})")
            
            # Test the ingredients query
            ingredients_query = f"{SUPABASE_URL}/rest/v1/recipe_ingredients?recipe_id=eq.{recipe_id}&select=*,ingredients(name)"
            ingredients_response = requests.get(ingredients_query, headers=headers)
            
            if ingredients_response.status_code == 200:
                recipe_ingredients = ingredients_response.json()
                print(f"✅ SUCCESS! Found {len(recipe_ingredients)} ingredients:")
                for ri in recipe_ingredients:
                    ingredient_name = ri.get('ingredients', {}).get('name', 'Unknown')
                    amount = ri.get('amount', 'No amount')
                    print(f"   • {amount} - {ingredient_name}")
                
                print("\n🎉 The ingredients query is now working!")
                print("Your iOS app should now be able to fetch and display ingredients.")
            else:
                print(f"❌ Still getting error: {ingredients_response.text}")
        else:
            print("❌ Recipe not found")
    else:
        print(f"❌ Error fetching recipe: {recipes_response.text}")

if __name__ == "__main__":
    test_ingredients_query() 