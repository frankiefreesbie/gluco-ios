#!/usr/bin/env python3
import json
import os
from PIL import Image, ImageDraw, ImageFont
import io

class RecipeImageCreator:
    def __init__(self):
        self.output_dir = "recipe_images"
        
        # Create output directory if it doesn't exist
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
    
    def create_placeholder_image(self, recipe_name: str, filename: str) -> str:
        """Create a placeholder image for a recipe and save it locally"""
        # Create a 1024x1024 image with a nice background
        width, height = 1024, 1024
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
            if len(test_line) > 35:  # Increased character limit for larger image
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
        y_position = height // 2 - (len(lines) * 60) // 2  # Increased spacing for larger image
        
        for line in lines:
            # Get text size
            if font:
                bbox = draw.textbbox((0, 0), line, font=font)
                text_width = bbox[2] - bbox[0]
            else:
                text_width = len(line) * 20  # Increased for larger image
            
            x_position = (width - text_width) // 2
            
            # Draw text with shadow
            draw.text((x_position + 2, y_position + 2), line, fill='#adb5bd', font=font)
            draw.text((x_position, y_position), line, fill=text_color, font=font)
            y_position += 60  # Increased line spacing
        
        # Add "Recipe Image" text at bottom
        bottom_text = "Recipe Image"
        if font:
            bbox = draw.textbbox((0, 0), bottom_text, font=font)
            text_width = bbox[2] - bbox[0]
        else:
            text_width = len(bottom_text) * 20  # Increased for larger image
        
        x_position = (width - text_width) // 2
        y_position = height - 100  # Adjusted for larger image
        
        draw.text((x_position, y_position), bottom_text, fill='#6c757d', font=font)
        
        # Save the image
        filepath = os.path.join(self.output_dir, filename)
        image.save(filepath, format='PNG')
        
        return filepath
    
    def create_all_recipe_images(self, recipes_file: str = "recipes.json") -> dict:
        """Create placeholder images for all recipes"""
        try:
            with open(recipes_file, 'r') as f:
                recipes = json.load(f)
            
            print(f"📁 Loaded {len(recipes)} recipes from {recipes_file}")
            print(f"🚀 Creating placeholder images in '{self.output_dir}' directory...")
            
            successful = 0
            failed = 0
            created_files = []
            
            for recipe in recipes:
                recipe_name = recipe['name']
                
                # Create filename from recipe name with custom mapping
                filename_mapping = {
                    "Quick Chickpea Stew": "quick_chickpea_stew.png",
                    "Grilled Chicken Salad": "grilled_chicken_salad.png",
                    "Toast with Savory Jam": "toast_with_savory_jam.png",
                    "Muesli Without Spikes": "musli_with_pumpkin_seeds.png",
                    "My OMELETTE": "omelette-with-feta.png",
                    "Happy Halloumi": "halloumi_with_spinach.png",
                    "Comforting Quiche": "quiche_with_peas_cheese.png",
                    "Californian Quesadilla": "californian_quesadilla.png",
                    "Egg Muffins": "muffin_with_mushrooms.png",
                    "Salmon Toast": "salmon_toast.png",
                    "Spinach & Sausage": "spinach_and_sausage.png",
                    "Avocado Toast with prosciutto": "avocado_toast_with_prosciutto.png"
                }
                
                filename = filename_mapping.get(recipe_name, f"{recipe_name.lower().replace(' ', '_').replace('&', 'and').replace('(', '').replace(')', '')}.png")
                
                # Create placeholder image
                print(f"🎨 Creating placeholder for: {recipe_name}")
                try:
                    filepath = self.create_placeholder_image(recipe_name, filename)
                    created_files.append(filepath)
                    successful += 1
                    print(f"✅ Created: {filepath}")
                except Exception as e:
                    print(f"❌ Failed to create image for {recipe_name}: {str(e)}")
                    failed += 1
            
            return {
                'successful': successful,
                'failed': failed,
                'total': len(recipes),
                'files': created_files
            }
            
        except Exception as e:
            print(f"❌ Error processing recipes: {str(e)}")
            return {'successful': 0, 'failed': 0, 'total': 0, 'files': []}

def main():
    print("🖼️  Recipe Image Creator")
    print("=" * 40)
    
    creator = RecipeImageCreator()
    
    # Create all images
    results = creator.create_all_recipe_images()
    
    print("\n" + "=" * 40)
    print("📊 Creation Results:")
    print(f"✅ Successful: {results['successful']}")
    print(f"❌ Failed: {results['failed']}")
    print(f"📈 Total: {results['total']}")
    
    if results['successful'] > 0:
        print(f"\n🎉 Successfully created {results['successful']} placeholder images!")
        print(f"📁 Images saved in: {creator.output_dir}/")
        print("\n📋 Next steps:")
        print("1. Go to your Supabase Dashboard")
        print("2. Navigate to Storage > recipe-images bucket")
        print("3. Upload the generated images manually")
        print("4. The images will then be accessible via the URLs in your recipes.json")
        
        print(f"\n📁 Created files:")
        for filepath in results['files']:
            print(f"   - {os.path.basename(filepath)}")
    
    if results['failed'] > 0:
        print(f"\n⚠️  {results['failed']} images failed to create.")
        print("Check the error messages above for details.")

if __name__ == "__main__":
    main() 