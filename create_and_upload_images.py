#!/usr/bin/env python3
import requests
import json
import os
from PIL import Image, ImageDraw, ImageFont
import io
import time

class SupabaseImageUploader:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
    
    def create_placeholder_image(self, recipe_name: str, filename: str) -> bytes:
        """Create a placeholder image for a recipe"""
        # Create a 400x300 image with a nice background
        width, height = 400, 300
        image = Image.new('RGB', (width, height), color='#f8f9fa')
        draw = ImageDraw.Draw(image)
        
        # Add a border
        draw.rectangle([(0, 0), (width-1, height-1)], outline='#dee2e6', width=2)
        
        # Add recipe name text
        try:
            # Try to use a default font
            font = ImageFont.load_default()
        except:
            font = None
        
        # Split recipe name into lines if it's too long
        words = recipe_name.split()
        lines = []
        current_line = ""
        
        for word in words:
            test_line = current_line + " " + word if current_line else word
            if len(test_line) > 25:  # Approximate character limit
                if current_line:
                    lines.append(current_line)
                    current_line = word
                else:
                    lines.append(word)
            else:
                current_line = test_line
        
        if current_line:
            lines.append(current_line)
        
        # Draw text lines
        text_color = '#495057'
        y_position = height // 2 - (len(lines) * 20) // 2
        
        for line in lines:
            # Get text size
            if font:
                bbox = draw.textbbox((0, 0), line, font=font)
                text_width = bbox[2] - bbox[0]
            else:
                text_width = len(line) * 8  # Approximate
            
            x_position = (width - text_width) // 2
            
            # Draw text with shadow
            draw.text((x_position + 1, y_position + 1), line, fill='#adb5bd', font=font)
            draw.text((x_position, y_position), line, fill=text_color, font=font)
            y_position += 25
        
        # Add "Recipe Image" text at bottom
        bottom_text = "Recipe Image"
        if font:
            bbox = draw.textbbox((0, 0), bottom_text, font=font)
            text_width = bbox[2] - bbox[0]
        else:
            text_width = len(bottom_text) * 8
        
        x_position = (width - text_width) // 2
        y_position = height - 40
        
        draw.text((x_position, y_position), bottom_text, fill='#6c757d', font=font)
        
        # Convert to bytes
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        return img_byte_arr.getvalue()
    
    def upload_image_to_supabase(self, image_data: bytes, filename: str) -> bool:
        """Upload image data to Supabase storage"""
        try:
            # Use the correct Supabase storage API endpoint
            storage_url = f"{self.supabase_url}/storage/v1/object/recipe-images/{filename}"
            
            upload_headers = {
                'Authorization': f'Bearer {self.supabase_key}',
                'Content-Type': 'image/png'
            }
            
            print(f"📤 Uploading {filename} to Supabase...")
            upload_response = requests.post(
                storage_url,
                headers=upload_headers,
                data=image_data,
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
        """Create and upload placeholder images for all recipes"""
        try:
            with open(recipes_file, 'r') as f:
                recipes = json.load(f)
            
            print(f"📁 Loaded {len(recipes)} recipes from {recipes_file}")
            print("🚀 Creating and uploading placeholder images...")
            
            successful = 0
            failed = 0
            
            for recipe in recipes:
                recipe_name = recipe['name']
                
                # Create filename from recipe name
                filename = f"{recipe_name.lower().replace(' ', '_').replace('&', 'and').replace('(', '').replace(')', '')}.png"
                
                # Create placeholder image
                print(f"🎨 Creating placeholder for: {recipe_name}")
                image_data = self.create_placeholder_image(recipe_name, filename)
                
                # Upload to Supabase
                if self.upload_image_to_supabase(image_data, filename):
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
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzAsImV4cCI6MjA1MDU0ODk3MH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8"
    
    print("🖼️  Recipe Image Creator and Uploader for Supabase")
    print("=" * 60)
    
    uploader = SupabaseImageUploader(SUPABASE_URL, SUPABASE_KEY)
    
    # Create and upload all images
    results = uploader.upload_all_recipe_images()
    
    print("\n" + "=" * 60)
    print("📊 Upload Results:")
    print(f"✅ Successful: {results['successful']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"📈 Total: {results['total']}")
    
    if results['successful'] > 0:
        print(f"\n🎉 Successfully uploaded {results['successful']} placeholder images!")
        print("You can now view them in your Supabase Dashboard under Storage > recipe-images")
        print("You can replace these placeholder images with actual recipe photos later.")
    
    if results['failed'] > 0:
        print(f"\n⚠️  {results['failed']} images failed to upload.")
        print("Check the error messages above for details.")

if __name__ == "__main__":
    main() 