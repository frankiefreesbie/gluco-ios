#!/usr/bin/env python3
"""
Update Recipe Names Script
Updates recipe names to match the image filenames
"""

import requests
import json
from datetime import datetime

class RecipeNameUpdater:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def update_recipe_name(self, old_name: str, new_name: str):
        """Update a recipe name in the database"""
        try:
            update_data = {
                'name': new_name,
                'updated_at': datetime.now().isoformat()
            }
            
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{old_name}',
                headers=self.headers,
                json=update_data
            )
            
            if response.status_code in [200, 201, 204]:
                print(f"✅ Updated: '{old_name}' → '{new_name}'")
                return True
            else:
                print(f"❌ Failed to update '{old_name}': {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ Error updating '{old_name}': {str(e)}")
            return False
    
    def update_all_recipe_names(self):
        """Update all recipe names to match image filenames"""
        # Mapping of current recipe names to image-based names
        name_mapping = {
            "Quick Chickpea Stew": "Quick Chickpea Stew",
            "Grilled Chicken Salad": "Grilled Chicken Salad", 
            "Toast with Savory Jam": "Toast with Savory Jam",
            "Muesli Without Spikes": "Muesli with Pumpkin Seeds",
            "My OMELETTE": "Omelette with Feta",
            "Happy Halloumi": "Halloumi with Spinach",
            "Comforting Quiche": "Quiche with Peas and Cheese",
            "Californian Quesadilla": "Californian Quesadilla",
            "Egg Muffins": "Muffin with Mushrooms",
            "Salmon Toast": "Salmon Toast",
            "Spinach & Sausage": "Spinach and Sausage",
            "Avocado Toast with prosciutto": "Avocado Toast with Prosciutto"
        }
        
        print("📝 Updating Recipe Names to Match Images")
        print("=" * 50)
        
        successful = 0
        failed = 0
        
        for old_name, new_name in name_mapping.items():
            if self.update_recipe_name(old_name, new_name):
                successful += 1
            else:
                failed += 1
        
        print("\n" + "=" * 50)
        print("📊 Update Results:")
        print(f"✅ Successful: {successful}")
        print(f"❌ Failed: {failed}")
        print(f"📈 Total: {len(name_mapping)}")
        
        if successful > 0:
            print(f"\n🎉 Successfully updated {successful} recipe names!")
            print("Recipe names now match the image filenames.")

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    updater = RecipeNameUpdater(SUPABASE_URL, SUPABASE_KEY)
    updater.update_all_recipe_names()

if __name__ == "__main__":
    main() 