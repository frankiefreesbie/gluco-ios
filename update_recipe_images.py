#!/usr/bin/env python3
"""
Update Recipe Image URLs Script
Updates the image_url field in recipes after manual upload to Supabase storage
"""

import requests
import json
from datetime import datetime

class RecipeImageUpdater:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def update_recipe_image_url(self, recipe_name: str, image_filename: str):
        """Update the image_url for a specific recipe"""
        try:
            # Construct the Supabase storage URL
            image_url = f"{self.supabase_url}/storage/v1/object/public/recipe-images/{image_filename}"
            
            # Update the recipe in the database
            update_data = {
                'image_url': image_url,
                'updated_at': datetime.now().isoformat()
            }
            
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/recipes?name=eq.{recipe_name}',
                headers=self.headers,
                json=update_data
            )
            
            if response.status_code in [200, 201, 204]:
                print(f"✅ Updated image URL for: {recipe_name}")
                print(f"   📸 URL: {image_url}")
                return True
            else:
                print(f"❌ Failed to update {recipe_name}: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ Error updating {recipe_name}: {str(e)}")
            return False
    
    def update_all_recipe_images(self):
        """Update all recipe image URLs"""
        # Recipe name to filename mapping
        recipe_images = {
            "Quick Chickpea Stew": "quick_chickpea_stew.png",
            "Grilled Chicken Salad": "grilled_chicken_salad.png",
            "Toast with Savory Jam": "toast_with_savory_jam.png",
            "Muesli Without Spikes": "musli_with_pumpkin_seeds.png",
            "My OMELETTE": "omelette-with_feta.png",
            "Happy Halloumi": "halloumi_with_spinach.png",
            "Comforting Quiche": "quiche_with_peas_cheese.png",
            "Californian Quesadilla": "californian_quesadilla.png",
            "Egg Muffins": "muffin_with_mushrooms.png",
            "Salmon Toast": "salmon_toast.png",
            "Spinach & Sausage": "spinach_and_sausage.png",
            "Avocado Toast with prosciutto": "avocado_toast_with_prosciutto.png"
        }
        
        print("🖼️  Updating Recipe Image URLs")
        print("=" * 50)
        
        successful = 0
        failed = 0
        
        for recipe_name, filename in recipe_images.items():
            if self.update_recipe_image_url(recipe_name, filename):
                successful += 1
            else:
                failed += 1
        
        print("\n" + "=" * 50)
        print("📊 Update Results:")
        print(f"✅ Successful: {successful}")
        print(f"❌ Failed: {failed}")
        print(f"📈 Total: {len(recipe_images)}")
        
        if successful > 0:
            print(f"\n🎉 Successfully updated {successful} recipe image URLs!")
            print("Your recipes should now display images in the app.")

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    updater = RecipeImageUpdater(SUPABASE_URL, SUPABASE_KEY)
    updater.update_all_recipe_images()

if __name__ == "__main__":
    main() 