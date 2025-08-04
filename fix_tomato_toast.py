#!/usr/bin/env python3
"""
Fix Tomato Toast & Burrata ingredients
"""

import requests
import json

def fix_tomato_toast_ingredients():
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
    }
    
    # First, find the recipe
    response = requests.get(
        f'{SUPABASE_URL}/rest/v1/recipes?name=ilike.*Tomato*Burrata*',
        headers=headers
    )
    
    if response.status_code == 200:
        recipes = response.json()
        if recipes:
            recipe = recipes[0]
            recipe_id = recipe['id']
            print(f"Found recipe: {recipe['name']} (ID: {recipe_id})")
            
            # Ingredients for Tomato Toast & Burrata
            ingredients = [
                {"name": "Naturally leavened bread", "amount": "1 slice", "quantity_value": 1, "quantity_unit": "slice"},
                {"name": "Arugula (rocket)", "amount": "1 handful", "quantity_value": 1, "quantity_unit": "handful"},
                {"name": "Burrata", "amount": "½ burrata", "quantity_value": 0.5, "quantity_unit": "burrata"},
                {"name": "Sun-dried tomatoes in oil", "amount": "3 pieces", "quantity_value": 3, "quantity_unit": "pieces"},
                {"name": "Basil pesto", "amount": "1 tablespoon", "quantity_value": 1, "quantity_unit": "tablespoon"},
                {"name": "Extra virgin olive oil", "amount": "½ tablespoon", "quantity_value": 0.5, "quantity_unit": "tablespoon"},
                {"name": "Salt and pepper", "amount": "To taste", "quantity_value": None, "quantity_unit": None}
            ]
            
            # Add each ingredient
            for ingredient in ingredients:
                # Ensure ingredient exists
                ing_response = requests.get(
                    f'{SUPABASE_URL}/rest/v1/ingredients?name=eq.{ingredient["name"]}',
                    headers=headers
                )
                
                if ing_response.status_code == 200:
                    existing_ingredients = ing_response.json()
                    if existing_ingredients:
                        ingredient_id = existing_ingredients[0]['id']
                    else:
                        # Create ingredient
                        create_response = requests.post(
                            f'{SUPABASE_URL}/rest/v1/ingredients',
                            headers=headers,
                            json={'name': ingredient['name']}
                        )
                        if create_response.status_code in [200, 201]:
                            ingredient_id = create_response.json()[0]['id']
                        else:
                            print(f"Failed to create ingredient: {ingredient['name']}")
                            continue
                else:
                    print(f"Failed to check ingredient: {ingredient['name']}")
                    continue
                
                # Add recipe ingredient
                payload = {
                    'recipe_id': recipe_id,
                    'ingredient_id': ingredient_id,
                    'amount': ingredient['amount'],
                    'quantity_value': ingredient['quantity_value'],
                    'quantity_unit': ingredient['quantity_unit'],
                    'is_optional': False,
                    'show_in_list': True
                }
                
                add_response = requests.post(
                    f'{SUPABASE_URL}/rest/v1/recipe_ingredients',
                    headers=headers,
                    json=payload
                )
                
                if add_response.status_code in [200, 201]:
                    print(f"✅ Added: {ingredient['name']}")
                else:
                    print(f"❌ Failed to add: {ingredient['name']}")
            
            print("✅ Done fixing Tomato Toast & Burrata ingredients!")
        else:
            print("❌ Recipe not found")
    else:
        print(f"❌ Error finding recipe: {response.text}")

if __name__ == "__main__":
    fix_tomato_toast_ingredients() 