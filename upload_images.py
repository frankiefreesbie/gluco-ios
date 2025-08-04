#!/usr/bin/env python3
import requests
import json
import os
from urllib.parse import urlparse
import time

class SupabaseImageUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
    
    def upload_image_from_url(self, image_url: str, filename: str) -> bool:
        """Upload an image from URL to Supabase storage"""
        try:
            # Download the image from the URL
            print(f"📥 Downloading {filename} from {image_url}...")
            response = requests.get(image_url, timeout=30)
            response.raise_for_status()
            
            # Upload to Supabase storage
            storage_url = f"{self.supabase_url}/storage/v1/object/recipe-images/{filename}"
            
            upload_headers = {
                'Authorization': f'Bearer {self.supabase_key}',
                'Content-Type': 'image/png'  # Assuming PNG format
            }
            
            print(f"📤 Uploading {filename} to Supabase...")
            upload_response = requests.post(
                storage_url,
                headers=upload_headers,
                data=response.content,
                timeout=30
            )
            
            if upload_response.status_code in [200, 201]:
                print(f"✅ Successfully uploaded: {filename}")
                return True
            else:
                print(f"❌ Failed to upload {filename}: {upload_response.status_code} - {upload_response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error uploading {filename}: {str(e)}")
            return False
    
    def upload_all_recipe_images(self, recipes_file: str = "recipes.json") -> dict:
        """Upload all recipe images from the recipes.json file"""
        try:
            with open(recipes_file, 'r') as f:
                recipes = json.load(f)
            
            print(f"📁 Loaded {len(recipes)} recipes from {recipes_file}")
            print("🚀 Starting image uploads...")
            
            successful = 0
            failed = 0
            
            for recipe in recipes:
                recipe_name = recipe['name']
                image_url = recipe.get('image_url', '')
                
                if not image_url:
                    print(f"⚠️  No image URL for recipe: {recipe_name}")
                    continue
                
                # Extract filename from URL or create one
                parsed_url = urlparse(image_url)
                filename = os.path.basename(parsed_url.path)
                
                if not filename or '.' not in filename:
                    # Create filename from recipe name
                    filename = f"{recipe_name.lower().replace(' ', '_').replace('&', 'and')}.png"
                
                if self.upload_image_from_url(image_url, filename):
                    successful += 1
                else:
                    failed += 1
                
                # Small delay to avoid overwhelming the server
                time.sleep(1)
            
            return {
                'successful': successful,
                'failed': failed,
                'total': len(recipes)
            }
            
        except Exception as e:
            print(f"❌ Error processing recipes: {str(e)}")
            return {'successful': 0, 'failed': 0, 'total': 0}

def main():
    # Supabase credentials - replace with your actual values
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzAsImV4cCI6MjA1MDU0ODk3MH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8"
    
    print("🖼️  Recipe Image Uploader for Supabase")
    print("=" * 50)
    
    uploader = SupabaseImageUploader(SUPABASE_URL, SUPABASE_KEY)
    
    # Upload all images
    results = uploader.upload_all_recipe_images()
    
    print("\n" + "=" * 50)
    print("📊 Upload Results:")
    print(f"✅ Successful: {results['successful']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"📈 Total: {results['total']}")
    
    if results['successful'] > 0:
        print(f"\n🎉 Successfully uploaded {results['successful']} images!")
        print("You can now view them in your Supabase Dashboard under Storage > recipe-images")
    
    if results['failed'] > 0:
        print(f"\n⚠️  {results['failed']} images failed to upload.")
        print("Check the error messages above for details.")

if __name__ == "__main__":
    main() 