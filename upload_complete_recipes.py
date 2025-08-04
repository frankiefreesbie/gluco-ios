#!/usr/bin/env python3
"""
Upload Complete Recipes Script
Uploads recipes with ingredients and instructions to Supabase
"""

import requests
import json
from datetime import datetime
from typing import List, Dict, Any

class CompleteRecipeUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
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
                
                if response.status_code not in [200, 201]:
                    print(f"❌ Failed to link ingredient {ingredient['name']} to recipe")
                    
            except Exception as e:
                print(f"❌ Error uploading ingredient {ingredient['name']}: {str(e)}")
    
    def upload_instructions_for_recipe(self, recipe_id: str, instructions: List[str]):
        """Upload preparation steps for a specific recipe"""
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
                
                if response.status_code not in [200, 201]:
                    print(f"❌ Failed to upload instruction step {i}")
                    
            except Exception as e:
                print(f"❌ Error uploading instruction step {i}: {str(e)}")
    
    def update_recipe_data(self, recipe_name: str, recipe_data: Dict[str, Any]):
        """Update recipe with new data and upload ingredients/instructions"""
        try:
            # First, get the recipe ID from the database
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers
            )
            
            if response.status_code != 200 or not response.json():
                print(f"❌ Recipe {recipe_name} not found in database")
                return False
            
            recipe_id = response.json()[0]['id']
            print(f"📝 Processing recipe: {recipe_name} (ID: {recipe_id})")
            
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
            
            if update_response.status_code not in [200, 201, 204]:
                print(f"❌ Failed to update recipe data for {recipe_name}")
            
            # Upload ingredients
            if 'ingredients' in recipe_data and recipe_data['ingredients']:
                print(f"  🥕 Uploading {len(recipe_data['ingredients'])} ingredients...")
                self.upload_ingredients_for_recipe(recipe_id, recipe_data['ingredients'])
            
            # Upload instructions
            if 'instructions' in recipe_data and recipe_data['instructions']:
                print(f"  📋 Uploading {len(recipe_data['instructions'])} instructions...")
                self.upload_instructions_for_recipe(recipe_id, recipe_data['instructions'])
            
            return True
            
        except Exception as e:
            print(f"❌ Error processing recipe {recipe_name}: {str(e)}")
            return False
    
    def upload_all_recipes(self, recipes_data: List[Dict[str, Any]]):
        """Upload all recipes with their ingredients and instructions"""
        print("🚀 Uploading Complete Recipe Data")
        print("=" * 50)
        
        successful = 0
        failed = 0
        
        for recipe in recipes_data:
            if self.update_recipe_data(recipe['name'], recipe):
                successful += 1
            else:
                failed += 1
        
        print("\n" + "=" * 50)
        print("📊 Upload Results:")
        print(f"✅ Successful: {successful}")
        print(f"❌ Failed: {failed}")
        print(f"📈 Total: {len(recipes_data)}")
        
        if successful > 0:
            print(f"\n🎉 Successfully processed {successful} recipes!")
            print("All recipe components (ingredients and instructions) are now in Supabase.")

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    # Recipe data (excluding Grilled Chicken and Toast with Savory Jam)
    recipes_data = [
        {
            "name": "Muesli Without Spikes",
            "prep_time": 5,
            "description": "A blood-sugar-friendly muesli made with seeds, nuts, and yogurt.",
            "protein": 14,
            "carbs": 18,
            "fat": 11,
            "calories": 260,
            "ingredients": [
                {
                    "name": "Greek yogurt",
                    "amount": "3/4 cup",
                    "quantity_value": 0.75,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Chia seeds",
                    "amount": "1 tablespoon",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Ground flaxseeds",
                    "amount": "1 tablespoon",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Cinnamon",
                    "amount": "1/2 teaspoon",
                    "quantity_value": 0.5,
                    "quantity_unit": "teaspoon",
                    "is_optional": True,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Combine all ingredients in a bowl.",
                "Stir well and let sit for a few minutes before eating."
            ]
        },
        {
            "name": "My OMELETTE",
            "prep_time": 10,
            "description": "A satisfying omelette filled with veggies and protein-rich eggs.",
            "protein": 20,
            "carbs": 4,
            "fat": 18,
            "calories": 260,
            "ingredients": [
                {
                    "name": "Eggs",
                    "amount": "2",
                    "quantity_value": 2,
                    "quantity_unit": "eggs",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Spinach",
                    "amount": "1 cup",
                    "quantity_value": 1,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Cherry tomatoes",
                    "amount": "1/2 cup",
                    "quantity_value": 0.5,
                    "quantity_unit": "cup",
                    "is_optional": True,
                    "show_in_list": True
                },
                {
                    "name": "Olive oil",
                    "amount": "1 teaspoon",
                    "quantity_value": 1,
                    "quantity_unit": "teaspoon",
                    "is_optional": False,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Heat oil in a pan and sauté veggies.",
                "Add beaten eggs and cook until set.",
                "Fold and serve hot."
            ]
        },
        {
            "name": "Happy Halloumi",
            "prep_time": 12,
            "description": "Grilled halloumi paired with colorful veggies for a flavorful breakfast.",
            "protein": 17,
            "carbs": 8,
            "fat": 16,
            "calories": 270,
            "ingredients": [
                {
                    "name": "Halloumi cheese",
                    "amount": "100g",
                    "quantity_value": 100,
                    "quantity_unit": "g",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Zucchini",
                    "amount": "1/2",
                    "quantity_value": 0.5,
                    "quantity_unit": "zucchini",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Red bell pepper",
                    "amount": "1/2",
                    "quantity_value": 0.5,
                    "quantity_unit": "pepper",
                    "is_optional": True,
                    "show_in_list": True
                },
                {
                    "name": "Olive oil",
                    "amount": "1 teaspoon",
                    "quantity_value": 1,
                    "quantity_unit": "teaspoon",
                    "is_optional": False,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Grill sliced halloumi and vegetables until golden.",
                "Arrange on a plate and drizzle with olive oil."
            ]
        },
        {
            "name": "Comforting Quiche",
            "prep_time": 15,
            "description": "A crustless quiche packed with eggs, cheese, and spinach for a low-carb meal.",
            "protein": 19,
            "carbs": 7,
            "fat": 20,
            "calories": 290,
            "ingredients": [
                {
                    "name": "Eggs",
                    "amount": "3",
                    "quantity_value": 3,
                    "quantity_unit": "eggs",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Cheddar cheese",
                    "amount": "1/4 cup",
                    "quantity_value": 0.25,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Spinach",
                    "amount": "1 cup",
                    "quantity_value": 1,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Milk",
                    "amount": "1/4 cup",
                    "quantity_value": 0.25,
                    "quantity_unit": "cup",
                    "is_optional": True,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Whisk together eggs, milk, cheese, and spinach.",
                "Pour into a greased baking dish and bake at 180°C (350°F) for 25–30 minutes."
            ]
        },
        {
            "name": "Californian Quesadilla",
            "prep_time": 10,
            "description": "A cheesy quesadilla with avocado and beans, inspired by Californian flavors.",
            "protein": 15,
            "carbs": 28,
            "fat": 16,
            "calories": 340,
            "ingredients": [
                {
                    "name": "Whole wheat tortilla",
                    "amount": "1",
                    "quantity_value": 1,
                    "quantity_unit": "tortilla",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Cheddar cheese",
                    "amount": "1/4 cup",
                    "quantity_value": 0.25,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Black beans",
                    "amount": "1/4 cup",
                    "quantity_value": 0.25,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Avocado",
                    "amount": "1/4 avocado",
                    "quantity_value": 0.25,
                    "quantity_unit": "avocado",
                    "is_optional": True,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Layer all ingredients on one half of the tortilla.",
                "Fold and cook in a pan until cheese melts and tortilla is golden brown."
            ]
        },
        {
            "name": "Egg Muffins",
            "prep_time": 15,
            "description": "Mini oven-baked egg muffins perfect for meal prep and a protein-packed start.",
            "protein": 18,
            "carbs": 5,
            "fat": 14,
            "calories": 240,
            "ingredients": [
                {
                    "name": "Eggs",
                    "amount": "4",
                    "quantity_value": 4,
                    "quantity_unit": "eggs",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Bell pepper",
                    "amount": "1/2 cup",
                    "quantity_value": 0.5,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Spinach",
                    "amount": "1/2 cup",
                    "quantity_value": 0.5,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Preheat oven to 180°C (350°F).",
                "Whisk eggs and mix in chopped veggies.",
                "Pour into muffin tins and bake for 20 minutes."
            ]
        },
        {
            "name": "Salmon Toast",
            "prep_time": 5,
            "description": "A quick and elegant toast with smoked salmon, cream cheese, and capers.",
            "protein": 16,
            "carbs": 14,
            "fat": 17,
            "calories": 280,
            "ingredients": [
                {
                    "name": "Rye bread",
                    "amount": "1 slice",
                    "quantity_value": 1,
                    "quantity_unit": "slice",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Cream cheese",
                    "amount": "1 tbsp",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Smoked salmon",
                    "amount": "1 slice",
                    "quantity_value": 1,
                    "quantity_unit": "slice",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Capers",
                    "amount": "2 teaspoons",
                    "quantity_value": 2,
                    "quantity_unit": "teaspoons",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Lemon wedge",
                    "amount": "1 wedge",
                    "quantity_value": 1,
                    "quantity_unit": "wedge",
                    "is_optional": True,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Toast the bread. Spread with cream cheese.",
                "Top with salmon and capers.",
                "Season with lemon juice, salt, and pepper."
            ]
        },
        {
            "name": "Spinach & Sausage",
            "prep_time": 10,
            "description": "A hearty breakfast of sautéed spinach and browned sausage bites.",
            "protein": 19,
            "carbs": 6,
            "fat": 21,
            "calories": 310,
            "ingredients": [
                {
                    "name": "Sausage",
                    "amount": "2 links",
                    "quantity_value": 2,
                    "quantity_unit": "links",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Spinach",
                    "amount": "1 cup",
                    "quantity_value": 1,
                    "quantity_unit": "cup",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Olive oil",
                    "amount": "1 tbsp",
                    "quantity_value": 1,
                    "quantity_unit": "tablespoon",
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
                }
            ],
            "instructions": [
                "Cook sausage in a pan until browned.",
                "Add garlic and spinach and sauté until wilted.",
                "Serve hot, seasoned with salt and pepper."
            ]
        },
        {
            "name": "Avocado Toast with prosciutto",
            "prep_time": 7,
            "description": "A protein-rich twist on classic avocado toast with cooked prosciutto and spicy harissa.",
            "protein": 14,
            "carbs": 18,
            "fat": 21,
            "calories": 320,
            "ingredients": [
                {
                    "name": "Rye bread",
                    "amount": "1 slice",
                    "quantity_value": 1,
                    "quantity_unit": "slice",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Avocado",
                    "amount": "1/2 avocado",
                    "quantity_value": 0.5,
                    "quantity_unit": "avocado",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Prosciutto",
                    "amount": "2 slices",
                    "quantity_value": 2,
                    "quantity_unit": "slices",
                    "is_optional": False,
                    "show_in_list": True
                },
                {
                    "name": "Harissa",
                    "amount": "1/2 teaspoon",
                    "quantity_value": 0.5,
                    "quantity_unit": "teaspoon",
                    "is_optional": True,
                    "show_in_list": True
                },
                {
                    "name": "Lemon juice",
                    "amount": "1/2 lemon",
                    "quantity_value": 0.5,
                    "quantity_unit": "lemon",
                    "is_optional": True,
                    "show_in_list": True
                }
            ],
            "instructions": [
                "Toast the bread until golden brown.",
                "Mash avocado and spread on toast.",
                "Top with prosciutto and drizzle with harissa and lemon juice.",
                "Season with salt and pepper to taste."
            ]
        }
    ]
    
    uploader = CompleteRecipeUploader(SUPABASE_URL, SUPABASE_KEY)
    uploader.upload_all_recipes(recipes_data)

if __name__ == "__main__":
    main() 