#!/usr/bin/env python3
"""
Fix Spinach and Sausage Recipe
Updates the recipe with correct ingredients and instructions
"""
import requests
import json
from datetime import datetime
from typing import List, Dict, Any

class RecipeFixer:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': self.supabase_key,
            'Authorization': f'Bearer {self.supabase_key}',
            'Content-Type': 'application/json'
        }

    def get_recipe_id(self, recipe_name: str) -> str:
        response = requests.get(
            f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
            headers=self.headers
        )
        if response.status_code == 200 and response.json():
            return response.json()[0]['id']
        else:
            print(f'❌ Recipe "{recipe_name}" not found!')
            return None

    def clear_recipe_data(self, recipe_id: str):
        # Delete existing recipe_ingredients
        requests.delete(
            f'{self.supabase_url}/rest/v1/recipe_ingredients?recipe_id=eq.{recipe_id}',
            headers=self.headers
        )
        # Delete existing preparation_steps
        requests.delete(
            f'{self.supabase_url}/rest/v1/preparation_steps?recipe_id=eq.{recipe_id}',
            headers=self.headers
        )

    def ensure_ingredient_exists(self, ingredient: Dict[str, Any]) -> str:
        # Check if ingredient exists
        name = ingredient['name']
        response = requests.get(
            f'{self.supabase_url}/rest/v1/ingredients?name=eq.{name}',
            headers=self.headers
        )
        if response.status_code == 200 and response.json():
            return response.json()[0]['id']
        # Create ingredient
        data = {
            'name': name
        }
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

    def upload_ingredients_for_recipe(self, recipe_id: str, ingredients: List[Dict[str, Any]]):
        for idx, ingredient in enumerate(ingredients):
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
            requests.post(
                f'{self.supabase_url}/rest/v1/recipe_ingredients',
                headers=self.headers,
                data=json.dumps(data)
            )

    def upload_instructions_for_recipe(self, recipe_id: str, instructions: List[str]):
        for idx, step in enumerate(instructions):
            data = {
                'recipe_id': recipe_id,
                'step_number': idx + 1,
                'instruction': step
            }
            requests.post(
                f'{self.supabase_url}/rest/v1/preparation_steps',
                headers=self.headers,
                data=json.dumps(data)
            )

    def fix_recipe(self, recipe_name: str, recipe_data: Dict[str, Any]):
        recipe_id = self.get_recipe_id(recipe_name)
        if not recipe_id:
            return
        print(f'🔄 Clearing old data for "{recipe_name}"...')
        self.clear_recipe_data(recipe_id)
        print(f'✅ Old data cleared.')
        print(f'⬆️ Uploading new ingredients...')
        self.upload_ingredients_for_recipe(recipe_id, recipe_data['ingredients'])
        print(f'⬆️ Uploading new instructions...')
        self.upload_instructions_for_recipe(recipe_id, recipe_data['instructions'])
        print(f'🎉 Recipe "{recipe_name}" fixed!')

def main():
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"

    # Use the known UUID for 'Spinach & Sausage'
    SPINACH_SAUSAGE_ID = "3b00cf7b-fc53-4c59-bf95-0a4d3f13330b"

    spinach_sausage_data = {
        "name": "Spinach & Sausage",
        "ingredients": [
            {
                "name": "Sausage",
                "amount": "2 good-quality sausages (about 60g each), cut into 1 cm pieces",
                "quantity_value": 120,
                "quantity_unit": "grams",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Garlic",
                "amount": "2 cloves",
                "quantity_value": 2,
                "quantity_unit": "cloves",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Fresh spinach",
                "amount": "200g",
                "quantity_value": 200,
                "quantity_unit": "grams",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Extra virgin olive oil",
                "amount": "1 tablespoon",
                "quantity_value": 1,
                "quantity_unit": "tablespoon",
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
                "name": "Black pepper",
                "amount": "To taste",
                "quantity_value": None,
                "quantity_unit": None,
                "is_optional": False,
                "show_in_list": True
            }
        ],
        "instructions": [
            "Heat olive oil in a pan over medium heat.",
            "Add sausage pieces and cook for 5 minutes, turning occasionally until browned. Remove and keep warm.",
            "Add garlic to the same pan and sauté for 30 seconds.",
            "Add spinach and cook until wilted but still vibrant green.",
            "Plate the spinach, add the sausage on top, and season with salt and pepper."
        ]
    }
    fixer = RecipeFixer(SUPABASE_URL, SUPABASE_KEY)
    # Directly use the known UUID
    print(f'🔄 Clearing old data for "Spinach & Sausage" (ID: {SPINACH_SAUSAGE_ID})...')
    fixer.clear_recipe_data(SPINACH_SAUSAGE_ID)
    print(f'✅ Old data cleared.')
    print(f'⬆️ Uploading new ingredients...')
    fixer.upload_ingredients_for_recipe(SPINACH_SAUSAGE_ID, spinach_sausage_data['ingredients'])
    print(f'⬆️ Uploading new instructions...')
    fixer.upload_instructions_for_recipe(SPINACH_SAUSAGE_ID, spinach_sausage_data['instructions'])
    print(f'🎉 Recipe "Spinach & Sausage" fixed!')

if __name__ == "__main__":
    main() 