#!/usr/bin/env python3
"""
Fix Halloumi with Spinach Recipe
Updates the recipe with correct ingredients and instructions
"""

import requests
import json
from datetime import datetime
from typing import List, Dict, Any

class RecipeFixer:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def get_recipe_id(self, recipe_name: str) -> str:
        """Get recipe ID by name"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers
            )
            
            if response.status_code == 200 and response.json():
                return response.json()[0]['id']
            else:
                print(f"❌ Recipe {recipe_name} not found")
                return None
                
        except Exception as e:
            print(f"❌ Error getting recipe ID: {str(e)}")
            return None
    
    def clear_recipe_data(self, recipe_id: str):
        """Clear existing ingredients and instructions for a recipe"""
        try:
            print(f"🧹 Clearing existing data for recipe ID: {recipe_id}")
            
            # Delete existing recipe ingredients
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/recipe_ingredients?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            if response.status_code in [200, 201, 204]:
                print("✅ Cleared existing recipe ingredients")
            else:
                print(f"⚠️ Could not clear recipe ingredients: {response.status_code}")
            
            # Delete existing preparation steps
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/preparation_steps?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            if response.status_code in [200, 201, 204]:
                print("✅ Cleared existing preparation steps")
            else:
                print(f"⚠️ Could not clear preparation steps: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error clearing recipe data: {str(e)}")
    
    def ensure_ingredient_exists(self, ingredient_name: str) -> str:
        """Ensure ingredient exists, create if it doesn't"""
        try:
            # Check if ingredient exists
            response = requests.get(
                f'{self.supabase_url}/rest/v1/ingredients?name=eq.{ingredient_name}',
                headers=self.headers
            )
            
            if response.status_code == 200 and response.json():
                return response.json()[0]['id']
            
            # Create new ingredient if not found
            ingredient_payload = {
                'name': ingredient_name,
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/ingredients',
                headers=self.headers,
                json=ingredient_payload
            )
            
            if response.status_code in [200, 201]:
                return response.json()[0]['id']
            else:
                print(f"❌ Failed to create ingredient: {ingredient_name}")
                return None
                
        except Exception as e:
            print(f"❌ Error with ingredient {ingredient_name}: {str(e)}")
            return None
    
    def upload_ingredients_for_recipe(self, recipe_id: str, ingredients: List[Dict[str, Any]]):
        """Upload ingredients for a specific recipe"""
        print(f"🥕 Uploading {len(ingredients)} ingredients...")
        
        for ingredient in ingredients:
            try:
                # Ensure ingredient exists
                ingredient_id = self.ensure_ingredient_exists(ingredient['name'])
                if not ingredient_id:
                    continue
                
                # Create recipe-ingredient relationship
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
                
                if response.status_code in [200, 201]:
                    print(f"  ✅ Added ingredient: {ingredient['name']}")
                else:
                    print(f"  ❌ Failed to link ingredient {ingredient['name']}")
                    
            except Exception as e:
                print(f"  ❌ Error uploading ingredient {ingredient['name']}: {str(e)}")
    
    def upload_instructions_for_recipe(self, recipe_id: str, instructions: List[str]):
        """Upload preparation steps for a specific recipe"""
        print(f"📋 Uploading {len(instructions)} instructions...")
        
        for i, instruction in enumerate(instructions, 1):
            try:
                payload = {
                    'recipe_id': recipe_id,
                    'step_number': i,
                    'instruction': instruction
                }
                
                response = requests.post(
                    f'{self.supabase_url}/rest/v1/preparation_steps',
                    headers=self.headers,
                    json=payload
                )
                
                if response.status_code in [200, 201]:
                    print(f"  ✅ Added instruction {i}: {instruction[:50]}...")
                else:
                    print(f"  ❌ Failed to upload instruction step {i}")
                    
            except Exception as e:
                print(f"  ❌ Error uploading instruction step {i}: {str(e)}")
    
    def fix_recipe(self, recipe_name: str, recipe_data: Dict[str, Any]):
        """Fix a recipe by clearing existing data and uploading correct data"""
        try:
            print(f"🔧 Fixing recipe: {recipe_name}")
            
            # Get recipe ID
            recipe_id = self.get_recipe_id(recipe_name)
            if not recipe_id:
                return False
            
            # Clear existing data
            self.clear_recipe_data(recipe_id)
            
            # Update recipe data
            update_payload = {
                'description': recipe_data['description'],
                'prep_minutes': recipe_data['prep_time'],
                'protein': recipe_data['protein'],
                'carbs': recipe_data['carbs'],
                'fats': recipe_data['fat'],
                'calories': recipe_data['calories'],
                'updated_at': datetime.now().isoformat()
            }
            
            update_response = requests.patch(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers,
                json=update_payload
            )
            
            if update_response.status_code in [200, 201, 204]:
                print("✅ Updated recipe data")
            else:
                print(f"❌ Failed to update recipe data: {update_response.status_code}")
            
            # Upload ingredients
            if 'ingredients' in recipe_data and recipe_data['ingredients']:
                self.upload_ingredients_for_recipe(recipe_id, recipe_data['ingredients'])
            
            # Upload instructions
            if 'instructions' in recipe_data and recipe_data['instructions']:
                self.upload_instructions_for_recipe(recipe_id, recipe_data['instructions'])
            
            print(f"🎉 Successfully fixed recipe: {recipe_name}")
            return True
            
        except Exception as e:
            print(f"❌ Error fixing recipe {recipe_name}: {str(e)}")
            return False

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    # Correct Halloumi with Spinach data
    halloumi_data = {
        "name": "Halloumi with spinach",
        "prep_time": 12,
        "description": "Grilled halloumi paired with spiced spinach for a flavorful breakfast.",
        "protein": 17,
        "carbs": 8,
        "fat": 16,
        "calories": 270,
        "ingredients": [
            {
                "name": "Halloumi cheese",
                "amount": "70g sliced",
                "quantity_value": 70,
                "quantity_unit": "grams",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Garlic",
                "amount": "1 clove, chopped",
                "quantity_value": 1,
                "quantity_unit": "clove",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Fresh ginger",
                "amount": "2.5 cm piece, chopped",
                "quantity_value": 2.5,
                "quantity_unit": "cm",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Garam masala or curry powder",
                "amount": "1 teaspoon",
                "quantity_value": 1,
                "quantity_unit": "teaspoon",
                "is_optional": False,
                "show_in_list": True
            },
            {
                "name": "Chili powder (optional)",
                "amount": "1/4 teaspoon",
                "quantity_value": 0.25,
                "quantity_unit": "teaspoon",
                "is_optional": True,
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
            "Heat a drizzle of olive oil in a pan and sear the halloumi slices on both sides until golden. Set aside.",
            "In the same pan, lower the heat and sauté chopped garlic and ginger for 30 seconds.",
            "Add garam masala (and chili powder if using), stir well.",
            "Add spinach and sauté until wilted and flavorful.",
            "Plate the spiced spinach and top with crispy halloumi. Season with salt and pepper and serve."
        ]
    }
    
    fixer = RecipeFixer(SUPABASE_URL, SUPABASE_KEY)
    fixer.fix_recipe("Halloumi with spinach", halloumi_data)

if __name__ == "__main__":
    main() 