#!/usr/bin/env python3
"""
Add Dressed Apple Recipe to Supabase
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

def add_recipe():
    # Recipe data
    recipe_data = {
        'name': 'Dressed Apple',
        'prep_minutes': 5,
        'description': 'A light and refreshing plate of crisp apple slices paired with sharp cheddar and crunchy walnuts. Finished with a touch of lemon juice for a bright, tangy twist.',
        'protein': 7,
        'carbs': 18,
        'fats': 14,
        'calories': 220,
        'image_url': 'https://your-image-url.com/dressed-apple.png'
    }
    
    print("🍎 Adding Dressed Apple recipe...")
    
    # Add recipe
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/recipes',
        headers=HEADERS,
        data=json.dumps(recipe_data)
    )
    
    print(f"Recipe creation status: {response.status_code}")
    
    if response.status_code in (200, 201):
        # Try to get the recipe ID
        fetch_response = requests.get(
            f'{SUPABASE_URL}/rest/v1/recipes?name=eq.Dressed Apple',
            headers=HEADERS
        )
        
        if fetch_response.status_code == 200 and fetch_response.json():
            recipe_id = fetch_response.json()[0]['id']
            print(f'✅ Recipe added with ID: {recipe_id}')
            return recipe_id
    
    print("❌ Failed to add recipe")
    return None

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

def add_ingredients(recipe_id):
    """Add ingredients for the recipe"""
    ingredients_data = [
        {
            'name': 'Apple',
            'amount': '1 apple',
            'quantity_value': 1,
            'quantity_unit': 'apple',
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Lemon juice',
            'amount': 'Juice of 1/4 lemon',
            'quantity_value': 0.25,
            'quantity_unit': 'lemon',
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Cheddar cheese',
            'amount': '40g',
            'quantity_value': 40,
            'quantity_unit': 'g',
            'is_optional': False,
            'show_in_list': True
        },
        {
            'name': 'Crushed walnuts',
            'amount': 'A handful',
            'quantity_value': None,
            'quantity_unit': None,
            'is_optional': False,
            'show_in_list': True
        }
    ]
    
    print("\n📝 Adding ingredients...")
    for ingredient in ingredients_data:
        ingredient_id = ensure_ingredient(ingredient['name'])
        if ingredient_id:
            data = {
                'recipe_id': recipe_id,
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

def add_instructions(recipe_id):
    """Add preparation steps for the recipe"""
    instructions = [
        "Squeeze the lemon over the apple slices to prevent browning.",
        "Arrange the apple slices on a plate with the cheddar and walnuts."
    ]
    
    print("\n📋 Adding preparation steps...")
    for i, step in enumerate(instructions, 1):
        data = {
            'recipe_id': recipe_id,
            'step_number': i,
            'instruction': step
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/preparation_steps',
            headers=HEADERS,
            data=json.dumps(data)
        )
        
        if response.status_code in (200, 201):
            print(f'  ✅ Added instruction {i}: {step[:50]}...')
        else:
            print(f'  ❌ Failed to add instruction {i}: {response.status_code}')

def main():
    print("=" * 50)
    
    # Add recipe
    recipe_id = add_recipe()
    if not recipe_id:
        print("❌ Failed to add recipe. Exiting.")
        return
    
    # Add ingredients
    add_ingredients(recipe_id)
    
    # Add instructions
    add_instructions(recipe_id)
    
    print(f"\n🎉 Recipe 'Dressed Apple' successfully added!")
    print("=" * 50)

if __name__ == "__main__":
    main() 