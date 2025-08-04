# 🍳 Glucko Recipe Upload Automation

This directory contains tools to automate uploading recipes to your Supabase database.

## 📋 Prerequisites

1. **Python 3.7+** installed on your system
2. **Required Python packages**:
   ```bash
   pip install requests
   ```

## 🚀 Upload Methods

### **Method 1: JSON Upload (Recommended for Small Batches)**

**Best for**: 1-50 recipes, testing, or when you have structured data

**Steps**:
1. **Run the script**:
   ```bash
   python recipe_upload_json.py
   ```

2. **Edit the generated `recipes.json`** file with your recipe data
3. **Run again** to upload your recipes

**JSON Format**:
```json
{
  "name": "Recipe Name",
  "prep_time": 15,
  "description": "Recipe description",
  "protein": 20,
  "carbs": 30,
  "fat": 10,
  "calories": 300,
  "image_url": "https://example.com/image.png",
  "ingredients": [
    {
      "name": "Ingredient Name",
      "amount": "2 tablespoons",
      "quantity_value": 2,
      "quantity_unit": "tablespoons",
      "is_optional": false,
      "show_in_list": true
    }
  ],
  "instructions": [
    "Step 1: Do this",
    "Step 2: Do that"
  ]
}
```

### **Method 2: CSV Upload (Recommended for Large Batches)**

**Best for**: 50+ recipes, bulk imports, or when you have data in spreadsheet format

**Steps**:
1. **Run the script**:
   ```bash
   python recipe_upload_script.py
   ```

2. **Edit the generated `recipes_template.csv`** file
3. **Run again** to upload your recipes

**CSV Format**:
```csv
id,name,prep_time,description,protein,carbs,fat,calories,image_url,ingredients,instructions,tags
uuid,Recipe Name,15,Description,20,30,10,300,https://example.com/image.png,"Ingredient1:amount1:value1:unit1:false:true|Ingredient2:amount2:value2:unit2:false:true","Step 1|Step 2|Step 3","Tag1,Tag2,Tag3"
```

## 📊 Database Schema

The uploaders work with this Supabase schema:

### **Tables**:
- `recipes` - Main recipe information
- `ingredients` - Ingredient master list
- `recipe_ingredients` - Recipe-ingredient relationships with quantities
- `preparation_steps` - Cooking instructions

### **Key Fields**:
- `quantity_value` - Numeric amount (e.g., 2, 400, 0.5)
- `quantity_unit` - Unit of measurement (e.g., "tablespoons", "g", "medium")
- `is_optional` - Whether ingredient is optional
- `show_in_list` - Whether to include in grocery list

## 🔧 Customization

### **Adding More Recipes**

1. **For JSON method**: Add more objects to the `recipes` array in `recipes.json`
2. **For CSV method**: Add more rows to `recipes_template.csv`

### **Modifying Upload Logic**

Edit the Python scripts to:
- Change field mappings
- Add validation rules
- Modify error handling
- Add progress tracking

### **Batch Processing**

For very large datasets:
1. Split your data into smaller files
2. Run uploads in parallel
3. Add retry logic for failed uploads

## 🛠️ Troubleshooting

### **Common Issues**:

1. **"Failed to upload recipe"**
   - Check your Supabase credentials
   - Verify database schema matches
   - Check network connectivity

2. **"Failed to create ingredient"**
   - Ingredient name might contain special characters
   - Check ingredient name length

3. **"CSV parsing errors"**
   - Ensure proper CSV formatting
   - Check for missing required fields
   - Verify delimiter usage

### **Debug Mode**:

Add this to see detailed error messages:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 📈 Performance Tips

1. **For 100+ recipes**: Use CSV method
2. **For real-time updates**: Use JSON method
3. **For testing**: Start with 2-3 recipes
4. **For production**: Add error handling and retries

## 🔒 Security Notes

- Keep your Supabase key secure
- Don't commit credentials to version control
- Use environment variables for production

## 📞 Support

If you encounter issues:
1. Check the error messages in the console
2. Verify your Supabase database schema
3. Test with a single recipe first
4. Check the Supabase dashboard for any constraints

## 🎯 Next Steps

After uploading recipes:
1. **Test in your app** - Verify recipes appear correctly
2. **Check images** - Ensure image URLs are accessible
3. **Test grocery lists** - Verify ingredient aggregation works
4. **Monitor performance** - Check app loading times

---

**Happy cooking! 🍳** 