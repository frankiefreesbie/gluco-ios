#!/usr/bin/env python3
"""
Complete Prosciutto, Ricotta & Figs Recipe with Ingredients and Instructions
"""
import requests
import json

SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"

HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

RECIPE_ID = "ec323764-7a28-42c8-8b0b-c161309a7e14"

def ensure_ingredient(name):
    """Ensure ingredient exists, create if it doesn't"""
    # Check if ingredient exists
    response = requests.get(
        f'{SUPABASE_URL}/rest/v1/ingredients?name=eq.{name}',
        headers=HEADERS
    )
    
    if response.status_code == 200 and response.json():
        return response.json()[0]['id']
    
    # Create ingredient
    data = {'name': name}
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/ingredients',
        headers=HEADERS,
        data=json.dumps(data)
    )
    
    if response.status_code in (200, 201):
        # Fetch the created ingredient
        fetch_response = requests.get(
            f'{SUPABASE_URL}/rest/v1/ingredients?name=eq.{name}',
            headers=HEADERS
        )
        if fetch_response.status_code == 200 and fetch_response.json():
            return fetch_response.json()[0]['id']
    
    print(f'❌ Failed to create ingredient: {name}')
    return None

def add_ingredients():
    """Add ingredients for the recipe"""
    ingredients_data = [
        {
            'name': 'Ricotta',
            'amount': '50g',
            'quantity_value': 50,
            'quantity_unit': 'grams',
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Cured prosciutto',
            'amount': '3 slices',
            'quantity_value': 3,
            'quantity_unit': 'slices',
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Fig',
            'amount': '1 fig, cut into 8 wedges',
            'quantity_value': 1,
            'quantity_unit': 'fig',
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Salt',
            'amount': 'To taste',
            'quantity_value': None,
            'quantity_unit': None,
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Pepper',
            'amount': 'To taste',
            'quantity_value': None,
            'quantity_unit': None,
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Extra virgin olive oil (EVOO)',
            'amount': 'A drizzle',
            'quantity_value': None,
            'quantity_unit': None,
            'is_optional': False,
            'show_in_list': True
        }
    ]
    
    print("📝 Adding ingredients...")
    for ingredient in ingredients_data:
        ingredient_id = ensure_ingredient(ingredient['name'])
        if ingredient_id:
            data = {
                'recipe_id': RECIPE_ID,
                'ingredient_id': ingredient_id,
                'amount': ingredient['amount'],
                'quantity_value': ingredient['quantity_value'],
                'quantity_unit': ingredient['quantity_unit'],
                'is_optional': ingredient['is_optional'],
                'show_in_list': ingredient['show_in_list']
            }
            
            response = requests.post(
                f'{SUPABASE_URL}/rest/v1/recipe_ingredients',
                headers=HEADERS,
                data=json.dumps(data)
            )
            
            if response.status_code in (200, 201):
                print(f'  ✅ Added ingredient: {ingredient["name"]}')
            else:
                print(f'  ❌ Failed to add ingredient {ingredient["name"]}: {response.status_code}')

def add_instructions():
    """Add preparation steps for the recipe"""
    instructions = [
        "Place the ricotta in a bowl and season with salt and pepper.",
        "Mash it with a fork until smooth, then transfer it to a plate.",
        "Add the prosciutto and fig wedges.",
        "Drizzle with a little olive oil and season with more pepper if desired."
    ]
    
    print("\n📋 Adding preparation steps...")
    for step in instructions:
        data = {
            'recipe_id': RECIPE_ID,
            'step': step
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/preparation_steps',
            headers=HEADERS,
            data=json.dumps(data)
        )
        
        if response.status_code in (200, 201):
            print(f'  ✅ Added instruction: {step[:50]}...')
        else:
            print(f'  ❌ Failed to add instruction: {response.status_code}')

def main():
    print("🍳 Completing Prosciutto, Ricotta & Figs recipe...")
    print("=" * 50)
    print(f"Recipe ID: {RECIPE_ID}")
    
    # Add ingredients
    add_ingredients()
    
    # Add instructions
    add_instructions()
    
    print(f"\n🎉 Recipe 'Prosciutto, Ricotta & Figs' completed!")
    print("=" * 50)

if __name__ == "__main__":
    main() 