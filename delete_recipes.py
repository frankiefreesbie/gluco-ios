#!/usr/bin/env python3
"""
Delete Recipes from Supabase
Deletes specified recipes and all their related data
"""

import requests
from datetime import datetime

class RecipeDeleter:
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
                print(f"❌ Recipe '{recipe_name}' not found")
                return None
                
        except Exception as e:
            print(f"❌ Error getting recipe ID for '{recipe_name}': {str(e)}")
            return None
    
    def delete_recipe_data(self, recipe_id: str, recipe_name: str):
        """Delete all data related to a recipe"""
        try:
            print(f"🗑️ Deleting recipe: {recipe_name} (ID: {recipe_id})")
            
            # Delete recipe ingredients first
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/recipe_ingredients?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            if response.status_code in [200, 201, 204]:
                print(f"  ✅ Deleted recipe ingredients for: {recipe_name}")
            else:
                print(f"  ⚠️ Could not delete recipe ingredients: {response.status_code}")
            
            # Delete preparation steps
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/preparation_steps?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            if response.status_code in [200, 201, 204]:
                print(f"  ✅ Deleted preparation steps for: {recipe_name}")
            else:
                print(f"  ⚠️ Could not delete preparation steps: {response.status_code}")
            
            # Finally, delete the recipe itself
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/recipes?id=eq.{recipe_id}',
                headers=self.headers
            )
            
            if response.status_code in [200, 201, 204]:
                print(f"  ✅ Deleted recipe: {recipe_name}")
                return True
            else:
                print(f"  ❌ Could not delete recipe: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ Error deleting recipe {recipe_name}: {str(e)}")
            return False
    
    def delete_recipe(self, recipe_name: str):
        """Delete a recipe and all its related data"""
        try:
            print(f"🔍 Looking for recipe: {recipe_name}")
            
            # Get recipe ID
            recipe_id = self.get_recipe_id(recipe_name)
            if not recipe_id:
                print(f"❌ Cannot delete '{recipe_name}' - recipe not found")
                return False
            
            # Delete all recipe data
            success = self.delete_recipe_data(recipe_id, recipe_name)
            
            if success:
                print(f"🎉 Successfully deleted recipe: {recipe_name}")
            else:
                print(f"❌ Failed to delete recipe: {recipe_name}")
            
            return success
            
        except Exception as e:
            print(f"❌ Error deleting recipe {recipe_name}: {str(e)}")
            return False

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    # Recipes to delete (with correct names from database)
    recipes_to_delete = [
        "Grilled Chicken Salad",
        "Toast with Savory Jam"
    ]
    
    deleter = RecipeDeleter(SUPABASE_URL, SUPABASE_KEY)
    
    print("🗑️ Starting recipe deletion process...")
    print("=" * 50)
    
    successful_deletions = 0
    
    for recipe_name in recipes_to_delete:
        print(f"\n📋 Processing: {recipe_name}")
        print("-" * 30)
        
        if deleter.delete_recipe(recipe_name):
            successful_deletions += 1
        
        print("-" * 30)
    
    print("\n" + "=" * 50)
    print(f"📊 Deletion Summary:")
    print(f"✅ Successfully deleted: {successful_deletions}/{len(recipes_to_delete)} recipes")
    
    if successful_deletions == len(recipes_to_delete):
        print("🎉 All recipes deleted successfully!")
    else:
        print("⚠️ Some recipes could not be deleted. Check the logs above.")

if __name__ == "__main__":
    main() 