#!/usr/bin/env python3
"""
Glucko Recipe Upload Script
Automates uploading recipes to Supabase from CSV files
"""

import csv
import json
import requests
from typing import List, Dict, Any
import os
from datetime import datetime

class SupabaseRecipeUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def upload_recipe(self, recipe_data: Dict[str, Any]) -> bool:
        """Upload a single recipe to Supabase"""
        try:
            # First, upload the recipe
            recipe_payload = {
                'id': recipe_data['id'],
                'name': recipe_data['name'],
                'prep_minutes': recipe_data['prep_time'],
                'description': recipe_data['description'],
                'protein': recipe_data['protein'],
                'carbs': recipe_data['carbs'],
                'fats': recipe_data['fat'],
                'calories': recipe_data['calories'],
                'image_url': recipe_data.get('image_url'),
                'tags': recipe_data.get('tags', []),
                'created_at': datetime.now().isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            
            # Upload recipe
            recipe_response = requests.post(
                f'{self.supabase_url}/rest/v1/recipes',
                headers=self.headers,
                json=recipe_payload
            )
            
            if recipe_response.status_code not in [200, 201]:
                print(f"❌ Failed to upload recipe {recipe_data['name']}: {recipe_response.text}")
                return False
            
            recipe_id = recipe_data['id']
            
            # Upload ingredients
            for ingredient in recipe_data['ingredients']:
                ingredient_payload = {
                    'recipe_id': recipe_id,
                    'ingredient_id': ingredient['ingredient_id'],
                    'amount': ingredient['amount'],
                    'quantity_value': ingredient.get('quantity_value'),
                    'quantity_unit': ingredient.get('quantity_unit'),
                    'is_optional': ingredient.get('is_optional', False),
                    'show_in_list': ingredient.get('show_in_list', True)
                }
                
                ingredient_response = requests.post(
                    f'{self.supabase_url}/rest/v1/recipe_ingredients',
                    headers=self.headers,
                    json=ingredient_payload
                )
                
                if ingredient_response.status_code not in [200, 201]:
                    print(f"❌ Failed to upload ingredient {ingredient['name']} for recipe {recipe_data['name']}")
            
            # Upload preparation steps
            for i, instruction in enumerate(recipe_data['instructions'], 1):
                step_payload = {
                    'recipe_id': recipe_id,
                    'step_number': i,
                    'instruction': instruction
                }
                
                step_response = requests.post(
                    f'{self.supabase_url}/rest/v1/preparation_steps',
                    headers=self.headers,
                    json=step_payload
                )
                
                if step_response.status_code not in [200, 201]:
                    print(f"❌ Failed to upload step {i} for recipe {recipe_data['name']}")
            
            print(f"✅ Successfully uploaded recipe: {recipe_data['name']}")
            return True
            
        except Exception as e:
            print(f"❌ Error uploading recipe {recipe_data['name']}: {str(e)}")
            return False
    
    def upload_from_csv(self, csv_file_path: str) -> Dict[str, int]:
        """Upload recipes from CSV file"""
        results = {'success': 0, 'failed': 0}
        
        with open(csv_file_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            
            for row in reader:
                # Parse ingredients from CSV (assuming comma-separated)
                ingredients = []
                if row.get('ingredients'):
                    ingredient_list = row['ingredients'].split('|')
                    for ingredient_str in ingredient_list:
                        # Parse ingredient format: "name:amount:quantity_value:quantity_unit:is_optional:show_in_list"
                        parts = ingredient_str.strip().split(':')
                        if len(parts) >= 2:
                            ingredient = {
                                'ingredient_id': self._get_or_create_ingredient_id(parts[0].strip()),
                                'amount': parts[1].strip(),
                                'quantity_value': float(parts[2]) if len(parts) > 2 and parts[2] else None,
                                'quantity_unit': parts[3] if len(parts) > 3 and parts[3] else None,
                                'is_optional': parts[4].lower() == 'true' if len(parts) > 4 else False,
                                'show_in_list': parts[5].lower() != 'false' if len(parts) > 5 else True
                            }
                            ingredients.append(ingredient)
                
                # Parse instructions from CSV
                instructions = []
                if row.get('instructions'):
                    instructions = [step.strip() for step in row['instructions'].split('|')]
                
                # Parse tags from CSV
                tags = []
                if row.get('tags'):
                    tags = [tag.strip() for tag in row['tags'].split(',')]
                
                recipe_data = {
                    'id': row['id'],
                    'name': row['name'],
                    'prep_time': int(row['prep_time']),
                    'description': row['description'],
                    'protein': int(row['protein']),
                    'carbs': int(row['carbs']),
                    'fat': int(row['fat']),
                    'calories': int(row['calories']),
                    'image_url': row.get('image_url'),
                    'ingredients': ingredients,
                    'instructions': instructions,
                    'tags': tags
                }
                
                if self.upload_recipe(recipe_data):
                    results['success'] += 1
                else:
                    results['failed'] += 1
        
        return results
    
    def _get_or_create_ingredient_id(self, ingredient_name: str) -> str:
        """Get or create ingredient ID for a given name"""
        # First, try to find existing ingredient
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
            raise Exception(f"Failed to create ingredient: {ingredient_name}")

def create_csv_template():
    """Create a CSV template for recipe uploads"""
    template = """id,name,prep_time,description,protein,carbs,fat,calories,image_url,ingredients,instructions,tags
ea194339-6c1c-4dd3-a304-97c3c3a798e9,Quick Chickpea Stew,10,A hearty and nutritious chickpea stew with tomatoes and yogurt,12,45,8,320,https://example.com/chickpea-stew.png,"Chickpeas:400g canned:400:g:false:true|Tomatoes:2 medium:2:medium:false:true|Red onion:1 small:1:small:false:true|Garlic:2 cloves:2:cloves:false:true|Yogurt:2 tablespoons:2:tablespoons:false:true|Olive oil:1 tablespoon:1:tablespoon:false:true","Heat oil and sauté onion and garlic|Add tomatoes and chickpeas|Simmer for 10 minutes|Serve with yogurt","Vegetarian,High Fiber,Quick"
"""
    
    with open('recipes_template.csv', 'w', encoding='utf-8') as file:
        file.write(template)
    
    print("✅ Created recipes_template.csv")

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    uploader = SupabaseRecipeUploader(SUPABASE_URL, SUPABASE_KEY)
    
    # Create template if it doesn't exist
    if not os.path.exists('recipes_template.csv'):
        create_csv_template()
        print("📝 Please fill in the recipes_template.csv file with your recipe data")
        print("📝 Then run this script again with: python recipe_upload_script.py recipes_template.csv")
        return
    
    # Upload recipes
    csv_file = 'recipes_template.csv'  # or sys.argv[1] if you want to pass as argument
    print(f"🚀 Starting upload from {csv_file}...")
    
    results = uploader.upload_from_csv(csv_file)
    
    print(f"\n📊 Upload Results:")
    print(f"✅ Successful: {results['success']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"📈 Total: {results['success'] + results['failed']}")

if __name__ == "__main__":
    main() 