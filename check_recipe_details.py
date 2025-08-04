#!/usr/bin/env python3
"""
Check Recipe Details
Check if a recipe has ingredients and preparation steps
"""
import requests
import json

def check_recipe_details(recipe_name, recipe_id):
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    print(f"🔍 Checking recipe: {recipe_name} (ID: {recipe_id})")
    print("=" * 50)
    
    # Check ingredients
    ingredients_url = f"{SUPABASE_URL}/rest/v1/recipe_ingredients?select=amount,quantity_value,quantity_unit,is_optional,show_in_list,ingredients(name)&recipe_id=eq.{recipe_id}"
    ingredients_response = requests.get(ingredients_url, headers=headers)
    
    if ingredients_response.status_code == 200:
        ingredients_data = ingredients_response.json()
        print(f"📝 Ingredients found: {len(ingredients_data)}")
        for i, ingredient in enumerate(ingredients_data, 1):
            if 'ingredients' in ingredient and ingredient['ingredients']:
                name = ingredient['ingredients']['name']
                amount = ingredient.get('amount', 'N/A')
                print(f"  {i}. {name}: {amount}")
            else:
                print(f"  {i}. [No ingredient name found]")
    else:
        print(f"❌ Failed to fetch ingredients: {ingredients_response.status_code}")
    
    print()
    
    # Check preparation steps
    steps_url = f"{SUPABASE_URL}/rest/v1/preparation_steps?select=step_number,instruction&recipe_id=eq.{recipe_id}&order=step_number.asc"
    steps_response = requests.get(steps_url, headers=headers)
    
    if steps_response.status_code == 200:
        steps_data = steps_response.json()
        print(f"📋 Preparation steps found: {len(steps_data)}")
        for i, step in enumerate(steps_data, 1):
            instruction = step.get('instruction', 'N/A')
            print(f"  {i}. {instruction}")
    else:
        print(f"❌ Failed to fetch preparation steps: {steps_response.status_code}")

def main():
    # Check Spinach & Sausage recipe
    check_recipe_details("Spinach & Sausage", "3b00cf7b-fc53-4c59-bf95-0a4d3f13330b")
    
    print("\n" + "=" * 50)
    
    # Also check Quick Chickpea Stew for comparison
    check_recipe_details("Quick Chickpea Stew", "ea194339-6c1c-4dd3-a304-97c3c3a798e9")

if __name__ == "__main__":
    main() 