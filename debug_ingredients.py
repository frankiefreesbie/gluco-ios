#!/usr/bin/env python3
"""
Debug Ingredients Issue
Detailed diagnostic to see what's happening with ingredients
"""

import requests
import json

def debug_ingredients():
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
    }
    
    print("🔍 DEBUGGING INGREDIENTS ISSUE")
    print("=" * 50)
    
    # 1. Check all recipes
    print("1. Checking all recipes...")
    recipes_response = requests.get(f'{SUPABASE_URL}/rest/v1/recipes', headers=headers)
    if recipes_response.status_code == 200:
        recipes = recipes_response.json()
        print(f"   Found {len(recipes)} recipes")
        for recipe in recipes:
            print(f"   • {recipe['name']} (ID: {recipe['id']})")
    else:
        print(f"   ❌ Error fetching recipes: {recipes_response.text}")
        return
    
    print()
    
    # 2. Check all ingredients
    print("2. Checking all ingredients...")
    ingredients_response = requests.get(f'{SUPABASE_URL}/rest/v1/ingredients', headers=headers)
    if ingredients_response.status_code == 200:
        ingredients = ingredients_response.json()
        print(f"   Found {len(ingredients)} ingredients")
        for ingredient in ingredients[:10]:  # Show first 10
            print(f"   • {ingredient['name']} (ID: {ingredient['id']})")
        if len(ingredients) > 10:
            print(f"   ... and {len(ingredients) - 10} more")
    else:
        print(f"   ❌ Error fetching ingredients: {ingredients_response.text}")
        return
    
    print()
    
    # 3. Check recipe_ingredients table
    print("3. Checking recipe_ingredients table...")
    recipe_ingredients_response = requests.get(f'{SUPABASE_URL}/rest/v1/recipe_ingredients', headers=headers)
    if recipe_ingredients_response.status_code == 200:
        recipe_ingredients = recipe_ingredients_response.json()
        print(f"   Found {len(recipe_ingredients)} recipe-ingredient relationships")
        
        # Group by recipe
        recipe_ingredient_count = {}
        for ri in recipe_ingredients:
            recipe_id = ri['recipe_id']
            if recipe_id not in recipe_ingredient_count:
                recipe_ingredient_count[recipe_id] = 0
            recipe_ingredient_count[recipe_id] += 1
        
        print("   Recipe ingredient counts:")
        for recipe_id, count in recipe_ingredient_count.items():
            # Find recipe name
            recipe_name = "Unknown"
            for recipe in recipes:
                if recipe['id'] == recipe_id:
                    recipe_name = recipe['name']
                    break
            print(f"   • {recipe_name}: {count} ingredients")
    else:
        print(f"   ❌ Error fetching recipe_ingredients: {recipe_ingredients_response.text}")
        return
    
    print()
    
    # 4. Test a specific recipe with ingredients
    print("4. Testing specific recipe with ingredients...")
    test_recipe = None
    for recipe in recipes:
        if "Dressed Apple" in recipe['name']:
            test_recipe = recipe
            break
    
    if test_recipe:
        print(f"   Testing recipe: {test_recipe['name']}")
        
        # Get ingredients for this recipe
        ingredients_query = f"{SUPABASE_URL}/rest/v1/recipe_ingredients?recipe_id=eq.{test_recipe['id']}&select=*,ingredients(name)"
        ingredients_response = requests.get(ingredients_query, headers=headers)
        
        if ingredients_response.status_code == 200:
            recipe_ingredients = ingredients_response.json()
            print(f"   Found {len(recipe_ingredients)} ingredients:")
            for ri in recipe_ingredients:
                print(f"   • {ri.get('amount', 'No amount')} - {ri.get('ingredients', {}).get('name', 'Unknown ingredient')}")
        else:
            print(f"   ❌ Error fetching ingredients: {ingredients_response.text}")
    else:
        print("   ❌ Could not find test recipe")
    
    print()
    
    # 5. Check if there are any foreign key issues
    print("5. Checking for potential issues...")
    
    # Check if any recipe_ingredients have null recipe_id or ingredient_id
    null_check_response = requests.get(
        f'{SUPABASE_URL}/rest/v1/recipe_ingredients?or=(recipe_id.is.null,ingredient_id.is.null)',
        headers=headers
    )
    
    if null_check_response.status_code == 200:
        null_records = null_check_response.json()
        if null_records:
            print(f"   ⚠️  Found {len(null_records)} recipe_ingredients with null values")
        else:
            print("   ✅ No null values found in recipe_ingredients")
    else:
        print(f"   ❌ Error checking for null values: {null_check_response.text}")

if __name__ == "__main__":
    debug_ingredients() 