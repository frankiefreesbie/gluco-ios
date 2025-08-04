#!/usr/bin/env python3
"""
Debug Recipe Fix
Debug what's happening when fixing the Spinach & Sausage recipe
"""
import requests
import json

def debug_recipe_fix():
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    recipe_id = "3b00cf7b-fc53-4c59-bf95-0a4d3f13330b"
    
    print("🔍 Debugging recipe fix for Spinach & Sausage")
    print("=" * 50)
    
    # Check if ingredients exist
    print("1. Checking if ingredients exist...")
    ingredients_to_check = ['Sausage', 'Garlic', 'Fresh spinach', 'Extra virgin olive oil', 'Salt', 'Black pepper']
    
    ingredient_ids = {}
    for ingredient_name in ingredients_to_check:
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/ingredients?name=eq.{ingredient_name}',
            headers=headers
        )
        
        if response.status_code == 200:
            try:
                data = response.json()
                if data:
                    ingredient_ids[ingredient_name] = data[0]['id']
                    print(f"   ✅ {ingredient_name}: {data[0]['id']}")
                else:
                    print(f"   ❌ {ingredient_name}: Not found")
            except:
                print(f"   ❌ {ingredient_name}: Error parsing response")
        else:
            print(f"   ❌ {ingredient_name}: HTTP {response.status_code}")
    
    # Test recipe_ingredients creation
    print("\n2. Testing recipe_ingredients creation...")
    if 'Sausage' in ingredient_ids:
        recipe_ingredient = {
            'recipe_id': recipe_id,
            'ingredient_id': ingredient_ids['Sausage'],
            'amount': '2 good-quality sausages (about 60g each), cut into 1 cm pieces',
            'quantity_value': 120,
            'quantity_unit': 'grams',
            'is_optional': False,
            'show_in_list': True,
            'order': 0
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/recipe_ingredients',
            headers=headers,
            data=json.dumps(recipe_ingredient)
        )
        
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
    
    # Test preparation_steps creation
    print("\n3. Testing preparation_steps creation...")
    step = {
        'recipe_id': recipe_id,
        'step': 'Heat olive oil in a pan over medium heat.',
        'order': 0
    }
    
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/preparation_steps',
        headers=headers,
        data=json.dumps(step)
    )
    
    print(f"   Status: {response.status_code}")
    print(f"   Response: {response.text}")

if __name__ == "__main__":
    debug_recipe_fix() 