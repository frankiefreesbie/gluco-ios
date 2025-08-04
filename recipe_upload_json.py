#!/usr/bin/env python3
"""
Glucko Recipe Upload Script (JSON Version)
Simpler JSON-based uploader for smaller batches
"""

import json
import requests
from typing import List, Dict, Any
from datetime import datetime
import uuid

class SimpleRecipeUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def check_recipe_exists(self, recipe_name: str) -> bool:
        """Check if a recipe with the given name already exists"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers
            )
            
            if response.status_code == 200:
                existing_recipes = response.json()
                return len(existing_recipes) > 0
            return False
            
        except Exception as e:
            print(f"❌ Error checking if recipe exists: {str(e)}")
            return False
    
    def upload_recipe_batch(self, recipes: List[Dict[str, Any]]) -> Dict[str, int]:
        """Upload a batch of recipes"""
        results = {'success': 0, 'failed': 0, 'skipped': 0}
        
        for recipe in recipes:
            if self.check_recipe_exists(recipe['name']):
                print(f"⏭️  Skipping existing recipe: {recipe['name']}")
                results['skipped'] += 1
            elif self.upload_single_recipe(recipe):
                results['success'] += 1
            else:
                results['failed'] += 1
        
        return results
    
    def upload_single_recipe(self, recipe: Dict[str, Any]) -> bool:
        """Upload a single recipe"""
        try:
            # Generate UUID if not provided
            if 'id' not in recipe:
                recipe['id'] = str(uuid.uuid4())
            
            # Upload recipe - adjusted to match actual schema
            recipe_payload = {
                'id': recipe['id'],
                'name': recipe['name'],
                'prep_minutes': recipe['prep_time'],
                'description': recipe['description'],
                'protein': recipe['protein'],
                'carbs': recipe['carbs'],
                'fats': recipe['fat'],
                'calories': recipe['calories'],
                'image_url': recipe.get('image_url'),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/recipes',
                headers=self.headers,
                json=recipe_payload
            )
            
            if response.status_code not in [200, 201]:
                print(f"❌ Failed to upload recipe {recipe['name']}: {response.text}")
                return False
            
            # Upload ingredients
            for ingredient in recipe['ingredients']:
                self.upload_ingredient(recipe['id'], ingredient)
            
            # Upload instructions
            for i, instruction in enumerate(recipe['instructions'], 1):
                self.upload_instruction(recipe['id'], i, instruction)
            
            print(f"✅ Successfully uploaded: {recipe['name']}")
            return True
            
        except Exception as e:
            print(f"❌ Error uploading recipe {recipe['name']}: {str(e)}")
            return False
    
    def upload_ingredient(self, recipe_id: str, ingredient: Dict[str, Any]):
        """Upload a single ingredient"""
        try:
            # First, ensure ingredient exists
            ingredient_id = self.ensure_ingredient_exists(ingredient['name'])
            
            payload = {
                'recipe_id': recipe_id,
                'ingredient_id': ingredient_id,
                'amount': ingredient['amount'],
                'quantity_value': ingredient.get('quantity_value'),
                'quantity_unit': ingredient.get('quantity_unit'),
                'is_optional': ingredient.get('is_optional', False),
                'show_in_list': ingredient.get('show_in_list', True)
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/recipe_ingredients',
                headers=self.headers,
                json=payload
            )
            
            if response.status_code not in [200, 201]:
                print(f"❌ Failed to upload ingredient {ingredient['name']}")
                
        except Exception as e:
            print(f"❌ Error uploading ingredient {ingredient['name']}: {str(e)}")
    
    def upload_instruction(self, recipe_id: str, step_number: int, instruction: str):
        """Upload a single instruction step"""
        try:
            payload = {
                'recipe_id': recipe_id,
                'step_number': step_number,
                'instruction': instruction
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/preparation_steps',
                headers=self.headers,
                json=payload
            )
            
            if response.status_code not in [200, 201]:
                print(f"❌ Failed to upload instruction step {step_number}")
                
        except Exception as e:
            print(f"❌ Error uploading instruction step {step_number}: {str(e)}")
    
    def ensure_ingredient_exists(self, ingredient_name: str) -> str:
        """Ensure ingredient exists, create if it doesn't"""
        # Check if ingredient exists
        response = requests.get(
            f'{self.supabase_url}/rest/v1/ingredients?name=eq.{ingredient_name}',
            headers=self.headers
        )
        
        if response.status_code == 200 and response.json():
            return response.json()[0]['id']
        
        # Create new ingredient
        payload = {
            'name': ingredient_name,
            'created_at': datetime.now().isoformat()
        }
        
        response = requests.post(
            f'{self.supabase_url}/rest/v1/ingredients',
            headers=self.headers,
            json=payload
        )
        
        if response.status_code in [200, 201]:
            return response.json()[0]['id']
        else:
            raise Exception(f"Failed to create ingredient: {ingredient_name}")

def create_sample_recipes():
    """Create sample recipes for testing"""
    return [
        {
            "name": "Quick Chickpea Stew",
            "prep_time": 10,
            "description": "A hearty and nutritious chickpea stew with tomatoes and yogurt",
            "protein": 12,
            "carbs": 45,
            "fat": 8,
            "calories": 320,
            "image_url": "https://paafbaftnlwhboshwwxf.supabase.co/storage/v1/object/public/recipe-images/quick-chickpea-stew.png",
            "ingredients": [
                {
                    "name": "Chickpeas",
                    "amount": "400g canned",
                    "quantity_value": 400,
                    "quantity_unit": "g",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Tomatoes",
                    "amount": "2 medium",
                    "quantity_value": 2,
                    "quantity_unit": "medium",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Red onion",
                    "amount": "1 small",
                    "quantity_value": 1,
                    "quantity_unit": "small",
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
                    "name": "Yogurt",
                    "amount": "2 tablespoons",
                    "quantity_value": 2,
                    "quantity_unit": "tablespoons",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Olive oil",
                    "amount": "1 tablespoon",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
                    "is_optional": False,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Heat oil in a large pot over medium heat",
                "Sauté onion and garlic until fragrant",
                "Add tomatoes and chickpeas",
                "Simmer for 10 minutes until thickened",
                "Serve with yogurt on top"
            ]
        },
        {
            "name": "Grilled Chicken Salad",
            "prep_time": 15,
            "description": "Fresh and healthy grilled chicken salad with mixed greens",
            "protein": 25,
            "carbs": 8,
            "fat": 12,
            "calories": 280,
            "image_url": "https://paafbaftnlwhboshwwxf.supabase.co/storage/v1/object/public/recipe-images/grilled-chicken-salad.png",
            "ingredients": [
                {
                    "name": "Chicken breast",
                    "amount": "200g",
                    "quantity_value": 200,
                    "quantity_unit": "g",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Mixed greens",
                    "amount": "100g",
                    "quantity_value": 100,
                    "quantity_unit": "g",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Cherry tomatoes",
                    "amount": "1 cup",
                    "quantity_value": 1,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Olive oil",
                    "amount": "1 tablespoon",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Lemon juice",
                    "amount": "1 tablespoon",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
                    "is_optional": False,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Season chicken breast with salt and pepper",
                "Grill chicken for 6-8 minutes per side until cooked through",
                "Let chicken rest for 5 minutes, then slice",
                "Toss mixed greens with olive oil and lemon juice",
                "Top with sliced chicken and cherry tomatoes"
            ]
        }
    ]

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    uploader = SimpleRecipeUploader(SUPABASE_URL, SUPABASE_KEY)
    
    # Load recipes from JSON file or use sample recipes
    try:
        with open('recipes.json', 'r', encoding='utf-8') as file:
            recipes = json.load(file)
        print("📁 Loaded recipes from recipes.json")
    except FileNotFoundError:
        recipes = create_sample_recipes()
        # Save sample recipes to file
        with open('recipes.json', 'w', encoding='utf-8') as file:
            json.dump(recipes, file, indent=2, ensure_ascii=False)
        print("📝 Created recipes.json with sample recipes")
    
    print(f"🚀 Starting upload of {len(recipes)} recipes...")
    
    results = uploader.upload_recipe_batch(recipes)
    
    print(f"\n📊 Upload Results:")
    print(f"✅ Successful: {results['success']}")
    print(f"⏭️  Skipped (already exist): {results['skipped']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"📈 Total: {results['success'] + results['failed'] + results['skipped']}")

if __name__ == "__main__":
    main() 