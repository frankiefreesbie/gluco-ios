#!/usr/bin/env python3
"""
Simple Image Upload Script for Supabase
Uploads recipe images to Supabase storage
"""

import requests
import os
from pathlib import Path

class SimpleImageUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/octet-stream'
        }
    
    def upload_image(self, image_path: str, filename: str) -> bool:
        """Upload a single image to Supabase storage"""
        try:
            if not os.path.exists(image_path):
                print(f"❌ Image file not found: {image_path}")
                return False
            
            # Read the image file
            with open(image_path, 'rb') as f:
                image_data = f.read()
            
            # Upload to Supabase storage
            storage_url = f"{self.supabase_url}/storage/v1/object/recipe-images/{filename}"
            
            print(f"📤 Uploading {filename}...")
            response = requests.post(
                storage_url,
                headers=self.headers,
                data=image_data,
                timeout=30
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ Successfully uploaded: {filename}")
                return True
            else:
                print(f"❌ Failed to upload {filename}: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error uploading {filename}: {str(e)}")
            return False
    
    def upload_all_images(self):
        """Upload all recipe images"""
        # Recipe name to filename mapping
        recipe_images = {
            "quick_chickpea_stew.png": "quick_chickpea_stew.png",
            "grilled_chicken_salad.png": "grilled_chicken_salad.png",
            "toast_with_savory_jam.png": "toast_with_savory_jam.png",
            "musli_with_pumpkin_seeds.png": "musli_with_pumpkin_seeds.png",
            "omelette-with_feta.png": "omelette-with_feta.png",
            "halloumi_with_spinach.png": "halloumi_with_spinach.png",
            "quiche_with_peas_cheese.png": "quiche_with_peas_cheese.png",
            "californian_quesadilla.png": "californian_quesadilla.png",
            "muffin_with_mushrooms.png": "muffin_with_mushrooms.png",
            "salmon_toast.png": "salmon_toast.png",
            "spinach_and_sausage.png": "spinach_and_sausage.png",
            "avocado_toast_with_prosciutto.png": "avocado_toast_with_prosciutto.png"
        }
        
        print("🖼️  Simple Image Uploader for Supabase")
        print("=" * 50)
        
        successful = 0
        failed = 0
        
        for filename in recipe_images.keys():
            image_path = f"recipe_images/{filename}"
            if self.upload_image(image_path, filename):
                successful += 1
            else:
                failed += 1
        
        print("\n" + "=" * 50)
        print("📊 Upload Results:")
        print(f"✅ Successful: {successful}")
        print(f"❌ Failed: {failed}")
        print(f"📈 Total: {len(recipe_images)}")
        
        if successful > 0:
            print(f"\n🎉 Successfully uploaded {successful} images!")
            print("You can now update the recipe image URLs.")

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    uploader = SimpleImageUploader(SUPABASE_URL, SUPABASE_KEY)
    uploader.upload_all_images()

if __name__ == "__main__":
    main() 