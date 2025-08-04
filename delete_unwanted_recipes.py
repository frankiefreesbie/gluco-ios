#!/usr/bin/env python3
"""
Glucko Recipe Deletion Script
Deletes unwanted recipes from the database
"""

import requests
import json

class UnwantedRecipeDeleter:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def delete_recipe_by_name(self, recipe_name: str) -> bool:
        """Delete a recipe by name"""
        try:
            # First, find the recipe ID
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers
            )
            
            if response.status_code == 200:
                recipes = response.json()
                if recipes:
                    recipe_id = recipes[0]['id']
                    print(f"🗑️  Deleting recipe: {recipe_name} (ID: {recipe_id})")
                    
                    # Delete the recipe (cascade will handle ingredients and steps)
                    delete_response = requests.delete(
                        f'{self.supabase_url}/rest/v1/recipes?id=eq.{recipe_id}',
                        headers=self.headers
                    )
                    
                    if delete_response.status_code in [200, 204]:
                        print(f"✅ Successfully deleted: {recipe_name}")
                        return True
                    else:
                        print(f"❌ Failed to delete {recipe_name}: {delete_response.text}")
                        return False
                else:
                    print(f"❌ Recipe not found: {recipe_name}")
                    return False
            else:
                print(f"❌ Error finding recipe {recipe_name}: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error deleting recipe {recipe_name}: {str(e)}")
            return False
    
    def delete_unwanted_recipes(self, recipe_names: list) -> dict:
        """Delete multiple unwanted recipes by name"""
        results = {'success': 0, 'failed': 0}
        
        for name in recipe_names:
            if self.delete_recipe_by_name(name):
                results['success'] += 1
            else:
                results['failed'] += 1
        
        return results

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    deleter = UnwantedRecipeDeleter(SUPABASE_URL, SUPABASE_KEY)
    
    # List of unwanted recipes to delete
    unwanted_recipes = [
        "Grilled Chicken Salad",
        "Toast with Savory Jam", 
        "Muesli Without Spikes",
        "My OMELETTE",
        "Happy Halloumi",
        "Comforting Quiche",
        "Egg Muffins"
    ]
    
    print(f"🗑️  Deleting {len(unwanted_recipes)} unwanted recipes...")
    print("=" * 50)
    
    results = deleter.delete_unwanted_recipes(unwanted_recipes)
    
    print("=" * 50)
    print(f"📊 Deletion Results:")
    print(f"✅ Successfully deleted: {results['success']}")
    print(f"❌ Failed to delete: {results['failed']}")

if __name__ == "__main__":
    main() 