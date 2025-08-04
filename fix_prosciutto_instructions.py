#!/usr/bin/env python3
"""
Fix Prosciutto, Ricotta & Figs Recipe Instructions
"""
import requests
import json

SUPABASE_URL = "https://paafbaftnlwhboshwwxf.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"

HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

RECIPE_ID = "ec323764-7a28-42c8-8b0b-c161309a7e14"

def add_instructions():
    """Add preparation steps for the recipe"""
    instructions = [
        "Place the ricotta in a bowl and season with salt and pepper.",
        "Mash it with a fork until smooth, then transfer it to a plate.",
        "Add the prosciutto and fig wedges.",
        "Drizzle with a little olive oil and season with more pepper if desired."
    ]
    
    print("📋 Adding preparation steps...")
    for i, step in enumerate(instructions, 1):
        data = {
            'recipe_id': RECIPE_ID,
            'step_number': i,
            'instruction': step
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/preparation_steps',
            headers=HEADERS,
            data=json.dumps(data)
        )
        
        if response.status_code in (200, 201):
            print(f'  ✅ Added instruction {i}: {step[:50]}...')
        else:
            print(f'  ❌ Failed to add instruction {i}: {response.status_code}')

def main():
    print("🍳 Fixing Prosciutto, Ricotta & Figs recipe instructions...")
    print("=" * 50)
    print(f"Recipe ID: {RECIPE_ID}")
    
    # Add instructions
    add_instructions()
    
    print(f"\n🎉 Recipe instructions completed!")
    print("=" * 50)

if __name__ == "__main__":
    main() 