#!/usr/bin/env python3
"""
Glucko Database Constraint Fix Script
Fixes foreign key constraints to enable cascading deletes
"""

import requests
import json

class DatabaseFixer:
    def __init__(self, supabase_url: str, supabase_key: str):
        self.supabase_url = supabase_url.rstrip('/')
        self.supabase_key = supabase_key
        self.headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
        }
    
    def run_sql(self, sql: str) -> bool:
        """Execute SQL commands via Supabase REST API"""
        try:
            # Note: This requires the pg_net extension to be enabled in Supabase
            # For now, we'll use the REST API approach
            
            # Split SQL into individual statements
            statements = [stmt.strip() for stmt in sql.split(';') if stmt.strip()]
            
            for statement in statements:
                if statement.startswith('--') or not statement:
                    continue
                    
                print(f"🔧 Executing: {statement[:50]}...")
                
                # For now, we'll just print what would be executed
                # You'll need to run this in your Supabase SQL editor
                print(f"   SQL: {statement}")
            
            return True
            
        except Exception as e:
            print(f"❌ Error executing SQL: {str(e)}")
            return False
    
    def fix_constraints(self):
        """Fix the foreign key constraints"""
        print("🔧 Fixing foreign key constraints...")
        
        sql_commands = """
        -- Drop existing constraints
        ALTER TABLE preparation_steps 
        DROP CONSTRAINT IF EXISTS preparation_steps_recipe_id_fkey;

        ALTER TABLE recipe_ingredients 
        DROP CONSTRAINT IF EXISTS recipe_ingredients_recipe_id_fkey;

        ALTER TABLE recipe_ingredients 
        DROP CONSTRAINT IF EXISTS recipe_ingredients_ingredient_id_fkey;

        -- Recreate with CASCADE DELETE
        ALTER TABLE preparation_steps 
        ADD CONSTRAINT preparation_steps_recipe_id_fkey 
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

        ALTER TABLE recipe_ingredients 
        ADD CONSTRAINT recipe_ingredients_recipe_id_fkey 
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

        ALTER TABLE recipe_ingredients 
        ADD CONSTRAINT recipe_ingredients_ingredient_id_fkey 
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE;
        """
        
        print("📋 SQL Commands to run in Supabase SQL Editor:")
        print("=" * 50)
        print(sql_commands)
        print("=" * 50)
        print("\n📝 Instructions:")
        print("1. Go to your Supabase dashboard")
        print("2. Navigate to the SQL Editor")
        print("3. Copy and paste the SQL commands above")
        print("4. Click 'Run' to execute")
        print("5. After running, you should be able to delete recipes manually")

def main():
    # Your Supabase credentials
    SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
    SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    fixer = DatabaseFixer(SUPABASE_URL, SUPABASE_KEY)
    fixer.fix_constraints()

if __name__ == "__main__":
    main() 