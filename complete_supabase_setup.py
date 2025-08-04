#!/usr/bin/env python3
"""
Complete Supabase Setup Guide
This script will help you set up your Supabase database properly
"""

import requests
import json
import os
from datetime import datetime

class SupabaseSetupGuide:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def check_current_status(self):
        """Check what's currently in the database"""
        print("🔍 Checking current database status...")
        
        # Check recipes table
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?select=count',
                headers=self.headers
            )
            if response.status_code == 200:
                print("✅ Recipes table exists")
            else:
                print("❌ Recipes table not found")
        except:
            print("❌ Cannot access recipes table")
        
        # Check ingredients table
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/ingredients?select=count',
                headers=self.headers
            )
            if response.status_code == 200:
                print("✅ Ingredients table exists")
            else:
                print("❌ Ingredients table not found")
        except:
            print("❌ Cannot access ingredients table")
        
        # Check preparation_steps table
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/preparation_steps?select=count',
                headers=self.headers
            )
            if response.status_code == 200:
                print("✅ Preparation_steps table exists")
            else:
                print("❌ Preparation_steps table not found")
        except:
            print("❌ Cannot access preparation_steps table")
        
        # Check recipe_ingredients table
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipe_ingredients?select=count',
                headers=self.headers
            )
            if response.status_code == 200:
                print("✅ Recipe_ingredients table exists")
            else:
                print("❌ Recipe_ingredients table not found")
        except:
            print("❌ Cannot access recipe_ingredients table")
    
    def print_setup_instructions(self):
        """Print step-by-step setup instructions"""
        print("\n" + "=" * 60)
        print("📋 COMPLETE SETUP INSTRUCTIONS")
        print("=" * 60)
        
        print("\n🔧 STEP 1: Create Database Tables")
        print("-" * 40)
        print("1. Go to your Supabase Dashboard: https://supabase.com/dashboard")
        print("2. Select your project")
        print("3. Go to SQL Editor (left sidebar)")
        print("4. Copy and paste the SQL from 'create_tables.sql'")
        print("5. Click 'Run' to execute")
        
        print("\n🖼️  STEP 2: Upload Recipe Images")
        print("-" * 40)
        print("1. Go to Storage in your Supabase Dashboard")
        print("2. Create a bucket called 'recipe-images' (if it doesn't exist)")
        print("3. Set the bucket to public")
        print("4. Upload these 12 images from your recipe_images/ folder:")
        
        images = [
            "quick_chickpea_stew.png",
            "grilled_chicken_salad.png", 
            "toast_with_savory_jam.png",
            "musli_with_pumpkin_seeds.png",
            "omelette-with_feta.png",
            "halloumi_with_spinach.png",
            "quiche_with_peas_cheese.png",
            "californian_quesadilla.png",
            "muffin_with_mushrooms.png",
            "salmon_toast.png",
            "spinach_and_sausage.png",
            "avocado_toast_with_prosciutto.png"
        ]
        
        for i, image in enumerate(images, 1):
            print(f"   {i:2d}. {image}")
        
        print("\n📝 STEP 3: Upload Recipe Components")
        print("-" * 40)
        print("After creating the tables, run:")
        print("   python3 setup_supabase_schema.py")
        
        print("\n🔄 STEP 4: Update Image URLs")
        print("-" * 40)
        print("After uploading images, run:")
        print("   python3 update_recipe_images.py")
        
        print("\n✅ STEP 5: Test Your Setup")
        print("-" * 40)
        print("Run this script again to verify everything is working:")
        print("   python3 complete_supabase_setup.py")
    
    def test_image_urls(self):
        """Test if recipe image URLs are working"""
        print("\n🖼️  Testing Recipe Image URLs...")
        
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recipes?select=name,image_url',
                headers=self.headers
            )
            
            if response.status_code == 200:
                recipes = response.json()
                working_urls = 0
                total_recipes = len(recipes)
                
                for recipe in recipes:
                    if recipe.get('image_url'):
                        # Test if the image URL is accessible
                        try:
                            img_response = requests.head(recipe['image_url'], timeout=5)
                            if img_response.status_code == 200:
                                print(f"✅ {recipe['name']}: Image accessible")
                                working_urls += 1
                            else:
                                print(f"❌ {recipe['name']}: Image not accessible (Status: {img_response.status_code})")
                        except:
                            print(f"❌ {recipe['name']}: Image URL error")
                    else:
                        print(f"⚠️  {recipe['name']}: No image URL")
                
                print(f"\n📊 Image URL Results: {working_urls}/{total_recipes} working")
            else:
                print("❌ Cannot fetch recipes")
                
        except Exception as e:
            print(f"❌ Error testing image URLs: {str(e)}")

def main():
    # Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    print("🔧 Supabase Setup Guide")
    print("=" * 60)
    
    guide = SupabaseSetupGuide(SUPABASE_URL, SUPABASE_KEY)
    
    # Check current status
    guide.check_current_status()
    
    # Print instructions
    guide.print_setup_instructions()
    
    # Test image URLs if tables exist
    guide.test_image_urls()
    
    print("\n" + "=" * 60)
    print("🎯 Next Steps:")
    print("1. Follow the instructions above")
    print("2. Run this script again to verify everything works")
    print("3. Test your iOS app with the Supabase data")

if __name__ == "__main__":
    main() 