#!/usr/bin/env python3
"""
Supabase Database Schema Setup and Recipe Upload Script
Creates the necessary tables and uploads all recipe data
"""

import requests
import json
import os
from datetime import datetime
from typing import List, Dict, Any

class SupabaseSetup:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def create_tables(self):
        """Create the necessary database tables using SQL"""
        print("🔧 Setting up database schema...")
        
        # SQL commands to create tables
        sql_commands = [
            # Create ingredients table
            """
            CREATE TABLE IF NOT EXISTS ingredients (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                name TEXT UNIQUE NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
            """,
            
            # Create preparation_steps table
            """
            CREATE TABLE IF NOT EXISTS preparation_steps (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
                step_number INTEGER NOT NULL,
                instruction TEXT NOT NULL,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                UNIQUE(recipe_id, step_number)
            );
            """,
            
            # Create recipe_ingredients table
            """
            CREATE TABLE IF NOT EXISTS recipe_ingredients (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
                ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE,
                amount TEXT NOT NULL,
                quantity_value FLOAT,
                quantity_unit TEXT,
                is_optional BOOLEAN DEFAULT FALSE,
                show_in_list BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                UNIQUE(recipe_id, ingredient_id)
            );
            """
        ]
        
        for i, sql in enumerate(sql_commands, 1):
            try:
                response = requests.post(
                    f'{self.supabase_url}/rest/v1/rpc/exec_sql',
                    headers=self.headers,
                    json={'sql': sql}
                )
                
                if response.status_code in [200, 201]:
                    print(f"✅ Created table {i}")
                else:
                    print(f"⚠️  Table {i} might already exist or error: {response.status_code}")
                    
            except Exception as e:
                print(f"⚠️  Error creating table {i}: {str(e)}")
    
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
    
    def upload_complete_recipe(self, recipe: Dict[str, Any]) -> bool:
        """Upload a complete recipe with all components"""
        try:
            # First, get the recipe ID from the database
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe["name"]}',
                headers=self.headers
            )
            
            if response.status_code != 200 or not response.json():
                print(f"❌ Recipe {recipe['name']} not found in database")
                return False
            
            recipe_id = response.json()[0]['id']
            print(f"📝 Processing recipe: {recipe['name']} (ID: {recipe_id})")
            
            # Upload ingredients
            if 'ingredients' in recipe and recipe['ingredients']:
                print(f"  🥕 Uploading {len(recipe['ingredients'])} ingredients...")
                self.upload_ingredients_for_recipe(recipe_id, recipe['ingredients'])
            
            # Upload instructions
            if 'instructions' in recipe and recipe['instructions']:
                print(f"  📋 Uploading {len(recipe['instructions'])} instructions...")
                self.upload_instructions_for_recipe(recipe_id, recipe['instructions'])
            
            return True
            
        except Exception as e:
            print(f"❌ Error processing recipe {recipe['name']}: {str(e)}")
            return False
    
    def upload_all_recipe_components(self, recipes_file: str = "recipes.json") -> Dict[str, int]:
        """Upload all recipe components (ingredients and instructions)"""
        try:
            with open(recipes_file, 'r') as f:
                recipes = json.load(f)
            
            print(f"📁 Loaded {len(recipes)} recipes from {recipes_file}")
            print("🚀 Uploading recipe components...")
            
            successful = 0
            failed = 0
            
            for recipe in recipes:
                if self.upload_complete_recipe(recipe):
                    successful += 1
                else:
                    failed += 1
            
            return {
                'successful': successful,
                'failed': failed,
                'total': len(recipes)
            }
            
        except Exception as e:
            print(f"❌ Error processing recipes: {str(e)}")
            return {'successful': 0, 'failed': 0, 'total': 0}

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    print("🔧 Supabase Database Setup and Recipe Component Upload")
    print("=" * 60)
    
    setup = SupabaseSetup(SUPABASE_URL, SUPABASE_KEY)
    
    # Step 1: Create tables
    setup.create_tables()
    
    print("\n" + "=" * 60)
    
    # Step 2: Upload recipe components
    results = setup.upload_all_recipe_components()
    
    print("\n" + "=" * 60)
    print("📊 Upload Results:")
    print(f"✅ Successful: {results['successful']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"📈 Total: {results['total']}")
    
    if results['successful'] > 0:
        print(f"\n🎉 Successfully processed {results['successful']} recipes!")
        print("All recipe components (ingredients and instructions) are now in Supabase.")
    
    if results['failed'] > 0:
        print(f"\n⚠️  {results['failed']} recipes failed to process.")
        print("Check the error messages above for details.")

if __name__ == "__main__":
    main() 