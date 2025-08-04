#!/usr/bin/env python3
"""
Glucko Recipe Duplicate Cleanup Script
Removes duplicate recipes from the Supabase database
"""

import requests
import json
from typing import List, Dict, Any
from collections import defaultdict

class DuplicateCleaner:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def get_all_recipes(self) -> List[Dict[str, Any]]:
        """Fetch all recipes from the database"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes',
                headers=self.headers
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                print(f"❌ Failed to fetch recipes: {response.text}")
                return []
                
        except Exception as e:
            print(f"❌ Error fetching recipes: {str(e)}")
            return []
    
    def find_duplicates(self, recipes: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
        """Find duplicate recipes by name"""
        duplicates = defaultdict(list)
        
        for recipe in recipes:
            name = recipe['name']
            duplicates[name].append(recipe)
        
        # Filter to only include names with duplicates
        return {name: recipes for name, recipes in duplicates.items() if len(recipes) > 1}
    
    def delete_recipe(self, recipe_id: str) -> bool:
        """Delete a recipe and its related data"""
        try:
            # Delete recipe ingredients
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/recipe_ingredients?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            # Delete preparation steps
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/preparation_steps?recipe_id=eq.{recipe_id}',
                headers=self.headers
            )
            
            # Delete the recipe itself
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/recipes?id=eq.{recipe_id}',
                headers=self.headers
            )
            
            return response.status_code in [200, 204]
            
        except Exception as e:
            print(f"❌ Error deleting recipe {recipe_id}: {str(e)}")
            return False
    
    def cleanup_duplicates(self, dry_run: bool = True) -> Dict[str, int]:
        """Clean up duplicate recipes"""
        print("🔍 Fetching all recipes from database...")
        recipes = self.get_all_recipes()
        
        if not recipes:
            print("❌ No recipes found in database")
            return {'total': 0, 'duplicates': 0, 'deleted': 0}
        
        print(f"📊 Found {len(recipes)} total recipes")
        
        duplicates = self.find_duplicates(recipes)
        
        if not duplicates:
            print("✅ No duplicates found!")
            return {'total': len(recipes), 'duplicates': 0, 'deleted': 0}
        
        print(f"🔍 Found {len(duplicates)} recipes with duplicates:")
        for name, duplicate_recipes in duplicates.items():
            print(f"  • {name}: {len(duplicate_recipes)} copies")
        
        if dry_run:
            print("\n🔍 DRY RUN MODE - No changes will be made")
            print("Run with dry_run=False to actually delete duplicates")
            return {'total': len(recipes), 'duplicates': len(duplicates), 'deleted': 0}
        
        print(f"\n🗑️  Starting cleanup...")
        deleted_count = 0
        
        for name, duplicate_recipes in duplicates.items():
            # Keep the first recipe, delete the rest
            recipes_to_delete = duplicate_recipes[1:]
            
            for recipe in recipes_to_delete:
                print(f"🗑️  Deleting duplicate: {name} (ID: {recipe['id']})")
                if self.delete_recipe(recipe['id']):
                    deleted_count += 1
                    print(f"✅ Deleted successfully")
                else:
                    print(f"❌ Failed to delete")
        
        return {'total': len(recipes), 'duplicates': len(duplicates), 'deleted': deleted_count}

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    cleaner = DuplicateCleaner(SUPABASE_URL, SUPABASE_KEY)
    
    # First, do a dry run to see what would be deleted
    print("🔍 DRY RUN - Checking for duplicates...")
    results = cleaner.cleanup_duplicates(dry_run=True)
    
    print(f"\n📊 Dry Run Results:")
    print(f"📈 Total recipes: {results['total']}")
    print(f"🔍 Duplicate recipes: {results['duplicates']}")
    print(f"🗑️  Would delete: {results['deleted']}")
    
    if results['duplicates'] > 0:
        print(f"\n⚠️  WARNING: This will delete {results['duplicates']} duplicate recipes!")
        print("🗑️  Proceeding with deletion...")
        results = cleaner.cleanup_duplicates(dry_run=False)
        
        print(f"\n📊 Cleanup Results:")
        print(f"📈 Total recipes: {results['total']}")
        print(f"🔍 Duplicate recipes: {results['duplicates']}")
        print(f"🗑️  Deleted: {results['deleted']}")
    else:
        print("✅ No cleanup needed!")

if __name__ == "__main__":
    main() 