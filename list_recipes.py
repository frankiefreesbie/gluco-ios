#!/usr/bin/env python3
"""
List All Recipes in Supabase
Shows all recipes currently in the database
"""

import requests
import json

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    try:
        print("📋 Fetching all recipes from database...")
        print("=" * 50)
        
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/recipes?select=id,name,description,prep_minutes',
            headers=headers
        )
        
        if response.status_code == 200:
            recipes = response.json()
            
            if recipes:
                print(f"Found {len(recipes)} recipes:")
                print("-" * 50)
                
                for i, recipe in enumerate(recipes, 1):
                    name = recipe.get('name', 'Unknown')
                    recipe_id = recipe.get('id', 'Unknown')
                    prep_time = recipe.get('prep_minutes', 'N/A')
                    description = recipe.get('description', 'N/A')
                    
                    if description and len(description) > 60:
                        description = description[:60] + "..."
                    
                    print(f"{i:2d}. {name}")
                    print(f"     ID: {recipe_id}")
                    print(f"     Prep Time: {prep_time} minutes")
                    print(f"     Description: {description}")
                    print()
            else:
                print("No recipes found in the database.")
                
        else:
            print(f"❌ Error fetching recipes: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

if __name__ == "__main__":
    main() 