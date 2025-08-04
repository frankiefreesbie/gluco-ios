#!/usr/bin/env python3
"""
Add Prosciutto, Ricotta & Figs Recipe to Supabase
"""
import requests
import json
from typing import Dict, Any, List

SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"

HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

class RecipeAdder:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
    
    def add_recipe(self, recipe_data: Dict[str, Any]) -> str:
        """Add a new recipe and return its ID"""
        # Prepare recipe data for insertion with correct column names
        recipe_insert = {
            'name': recipe_data['name'],
            'prep_minutes': recipe_data['prep_time'],
            'description': recipe_data.get('description'),
            'protein': recipe_data.get('protein'),
            'carbs': recipe_data.get('carbs'),
            'fats': recipe_data.get('fat'),
            'calories': recipe_data.get('calories'),
            'image_url': recipe_data.get('image_url')
        }
        
        # Remove None values
        recipe_insert = {k: v for k, v in recipe_insert.items() if v is not None}
        
        response = requests.post(
            f'{self.supabase_url}/rest/v1/recipes',
            headers=self.headers,
            data=json.dumps(recipe_insert)
        )
        
        if response.status_code in (200, 201):
            try:
                if response.text.strip():  # Check if response has content
                    recipe_id = response.json()[0]['id']
                    print(f'✅ Recipe "{recipe_data["name"]}" added with ID: {recipe_id}')
                    return recipe_id
                else:
                    # If response is empty but status is success, try to fetch the recipe ID
                    fetch_response = requests.get(
                        f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_data["name"]}',
                        headers=self.headers
                    )
                    if fetch_response.status_code == 200 and fetch_response.json():
                        recipe_id = fetch_response.json()[0]['id']
                        print(f'✅ Recipe "{recipe_data["name"]}" added with ID: {recipe_id}')
                        return recipe_id
            except (KeyError, IndexError, requests.exceptions.JSONDecodeError):
                # If response is empty but status is success, try to fetch the recipe ID
                fetch_response = requests.get(
                    f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_data["name"]}',
                    headers=self.headers
                )
                if fetch_response.status_code == 200 and fetch_response.json():
                    recipe_id = fetch_response.json()[0]['id']
                    print(f'✅ Recipe "{recipe_data["name"]}" added with ID: {recipe_id}')
                    return recipe_id
        
        print(f'❌ Failed to add recipe: {response.status_code} - {response.text}')
        return None
    
    def ensure_ingredient_exists(self, ingredient: Dict[str, Any]) -> str:
        """Ensure ingredient exists, create if it doesn't"""
        name = ingredient['name']
        response = requests.get(
            f'{self.supabase_url}/rest/v1/ingredients?name=eq.{name}',
            headers=self.headers
        )
        if response.status_code == 200 and response.json():
            return response.json()[0]['id']
        
        # Create ingredient
        data = {'name': name}
        response = requests.post(
            f'{self.supabase_url}/rest/v1/ingredients',
            headers=self.headers,
            data=json.dumps(data)
        )
        try:
            if response.status_code in (200, 201) and response.json():
                return response.json()[0]['id']
        except Exception:
            # If response is empty, try fetching again
            fetch_response = requests.get(
                f'{self.supabase_url}/rest/v1/ingredients?name=eq.{name}',
                headers=self.headers
            )
            if fetch_response.status_code == 200 and fetch_response.json():
                return fetch_response.json()[0]['id']
        
        print(f'❌ Failed to create ingredient: {name}')
        return None
    
    def add_ingredients_for_recipe(self, recipe_id: str, ingredients: List[Dict[str, Any]]):
        """Add ingredients for a recipe"""
        for ingredient in ingredients:
            ingredient_id = self.ensure_ingredient_exists(ingredient)
            if not ingredient_id:
                continue
            
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
                f'{self.supabase_url}/rest/v1/recipe_ingredients',
                headers=self.headers,
                data=json.dumps(data)
            )
            
            if response.status_code in (200, 201):
                print(f'  ✅ Added ingredient: {ingredient["name"]}')
            else:
                print(f'  ❌ Failed to add ingredient {ingredient["name"]}: {response.status_code}')
    
    def add_instructions_for_recipe(self, recipe_id: str, instructions: List[str]):
        """Add preparation steps for a recipe"""
        for step in instructions:
            data = {
                'recipe_id': recipe_id,
                'step': step
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/preparation_steps',
                headers=self.headers,
                data=json.dumps(data)
            )
            
            if response.status_code in (200, 201):
                print(f'  ✅ Added instruction: {step[:50]}...')
            else:
                print(f'  ❌ Failed to add instruction: {response.status_code}')

def main():
    # Recipe data
    prosciutto_ricotta_figs = {
        "name": "Prosciutto, Ricotta & Figs",
        "prep_time": 5,
        "description": "A dream breakfast: creamy ricotta meets smoky prosciutto and sweet figs. High in protein, naturally sweet, and deliciously balanced. Gluten-free.",
        "protein": 18,
        "carbs": 10,
        "fat": 20,
        "calories": 280,
        "image_url": "https://your-image-url.com/prosciutto-ricotta-figs.png",
        "ingredients": [
            {
                "name": "Ricotta",
                "amount": "50g",
                "quantity_value": 50,
                "quantity_unit": "grams",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Cured prosciutto",
                "amount": "3 slices",
                "quantity_value": 3,
                "quantity_unit": "slices",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Fig",
                "amount": "1 fig, cut into 8 wedges",
                "quantity_value": 1,
                "quantity_unit": "fig",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Salt",
                "amount": "To taste",
                "quantity_value": None,
                "quantity_unit": None,
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Pepper",
                "amount": "To taste",
                "quantity_value": None,
                "quantity_unit": None,
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Extra virgin olive oil (EVOO)",
                "amount": "A drizzle",
                "quantity_value": None,
                "quantity_unit": None,
                "is_optional": False,
                "show_in_list": True
            }
        ],
        "instructions": [
            "Place the ricotta in a bowl and season with salt and pepper.",
            "Mash it with a fork until smooth, then transfer it to a plate.",
            "Add the prosciutto and fig wedges.",
            "Drizzle with a little olive oil and season with more pepper if desired."
        ]
    }
    
    print("🍳 Adding Prosciutto, Ricotta & Figs recipe...")
    print("=" * 50)
    
    adder = RecipeAdder(SUPABASE_URL, SUPABASE_KEY)
    
    # Add the recipe
    recipe_id = adder.add_recipe(prosciutto_ricotta_figs)
    if not recipe_id:
        print("❌ Failed to add recipe. Exiting.")
        return
    
    # Add ingredients
    print(f"\n📝 Adding ingredients...")
    adder.add_ingredients_for_recipe(recipe_id, prosciutto_ricotta_figs['ingredients'])
    
    # Add instructions
    print(f"\n📋 Adding preparation steps...")
    adder.add_instructions_for_recipe(recipe_id, prosciutto_ricotta_figs['instructions'])
    
    print(f"\n🎉 Recipe '{prosciutto_ricotta_figs['name']}' successfully added!")
    print("=" * 50)

if __name__ == "__main__":
    main() 