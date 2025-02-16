const String foodDetectionPrompt = """
Analyze the provided image to detect food-related items (ingredients, dishes, or food products). Based on the detected items:  

---  

## **1 Detecting a Fully Prepared Dish**  
If the image contains a **fully prepared dish or a pre-made food product**, return a **single object** inside the `dishes` array with the following structure:  

- **"id"**: A unique identifier for the dish.  
- **"name"**: The name of the dish.  
- **"description"**: A short description of the dish.  
- **"imageUrl"**: A **high-quality full-size image URL** sourced from Unsplash, Pexels, or Wikimedia Commons.  
  - **For Wikimedia Commons, ensure URLs are valid and return existing images only.** 
   **For Wikimedia Commons**, ensure the full-size URL follows this format:    
    `"https://upload.wikimedia.org/wikipedia/commons/<first_letter>/<first_two_letters>/<file_name>"`  
  - **Validate each Wikimedia Commons URL before returning it.**  
  - If an image is missing, first attempt to find the correct URL using the Wikimedia API.      
- **"ingredients"**: A list of ingredients used in the dish (use an empty array `[]` if unavailable).  
- **"steps"**: Detailed **step-by-step cooking instructions** (each step should be **at least 2–3 sentences long**, describing the process, timing, and techniques).   
- **"nutrition"**: A structured object containing:  
  - `"calories"`: Calories per serving (**integer**). If unavailable, return `0`.  
  - `"protein"`: Protein content per serving (**integer in grams**). If unavailable, return `0`.  
  - `"preparationTime"`: **Estimated preparation time (integer in minutes) derived from the time estimations within the steps. If no time estimations are present in the steps, provide a reasonable estimate based on the complexity of the recipe. The minimum preparation time should be 5 minutes.**
- **"detectedType"**: `"dish"`  

Example Output:  
{  
  "dishes": [  
    {  
      "id": "pav-bhaji",  
      "name": "Pav Bhaji",  
      "description": "A popular Indian street food with a thick vegetable curry served with soft bread rolls.",  
      "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/6/63/Pav_Bhaji.jpg",  
      "ingredients": ["Potatoes", "Peas", "Butter", "Onions", "Tomatoes", "Ginger", "Garlic", "Spices"],  
       "steps": [  
        "Peel and chop the potatoes into small cubes. Boil them along with green peas until they are completely soft. Drain and mash them using a fork or a potato masher.",  
        "In a large pan, heat butter and sauté finely chopped onions until golden brown. Add minced ginger and garlic, stirring until fragrant.",  
        "Add chopped tomatoes and cook until they soften. Then, add pav bhaji masala and mix well.",  
        "Stir in the mashed potatoes and peas. Cook on medium heat, stirring occasionally, until the mixture thickens and develops a rich flavor.",  
        "Serve hot with buttered and toasted pav (soft bread rolls) and garnish with chopped cilantro and lemon wedges."  
      ],  
      "nutrition": {  
        "calories": 400,  
        "protein": 10,  
        "preparationTime": 45  
      },  
      "detectedType": "dish"  
    }  
  ]  
}  

---  

## **2️ Detecting Ingredients & Suggesting Recipes**  
If **ingredients** are detected instead of a full dish, return **up to 4 relevant recipes** inside the `recipes` array. Each recipe must follow this structure:  

- **"id"**: A unique identifier for the recipe.  
- **"name"**: The name of the recipe.  
- **"description"**: A short description.  
- **"imageUrl"**: A **high-quality full-size image URL** sourced from Unsplash, Pexels, or Wikimedia Commons.
  - **For Wikimedia Commons**, ensure the full-size URL follows this format:    
    `"https://upload.wikimedia.org/wikipedia/commons/<first_letter>/<first_two_letters>/<file_name>"`  
  - **Validate each Wikimedia Commons URL before returning it.**  
- **"ingredients"**: List of required ingredients.  
- **"steps"**: Detailed **step-by-step cooking instructions** (each step should be **at least 2–3 sentences long**, describing the process, timing, and techniques).  
- **"nutrition"**:    
  - `"calories"`: Calories per serving (**integer** or `0` if unknown).  
  - `"protein"`: Protein content per serving (**integer in grams** or `0` if unknown).  
  - `"preparationTime"`: **Estimated preparation time (integer in minutes) derived from the time estimations within the steps. If no time estimations are present in the steps, provide a reasonable estimate based on the complexity of the recipe. The minimum preparation time should be 5 minutes.**
- **"detectedType"**: `"recipe"`  

Example Output:  
{  
  "recipes": [  
    {  
      "id": "mashed-potatoes",  
      "name": "Mashed Potatoes",  
      "description": "Creamy and fluffy mashed potatoes, a perfect side dish.",  
      "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/0/04/Mashed_potatoes.jpg",  
      "ingredients": ["Potatoes", "Butter", "Milk", "Salt", "Pepper"],  
      "steps": [  
        "Peel the potatoes and cut them into evenly sized chunks to ensure even cooking. Rinse them under cold water to remove excess starch.",  
        "Boil the potatoes in a large pot of salted water until they are fork-tender, about 15–20 minutes. Drain and let them steam dry for a minute.",  
        "Mash the potatoes using a potato masher or a ricer for a smooth texture. Avoid using a blender as it can make the potatoes gluey.",  
        "Warm the milk and melt the butter together, then gradually mix them into the mashed potatoes. Stir until creamy and smooth.",  
        "Season with salt and freshly ground black pepper to taste. Serve warm, garnished with extra butter or fresh herbs if desired."  
      ],  
      "nutrition": {  
        "calories": 250,  
        "protein": 5,  
        "preparationTime": 30  
      },  
      "detectedType": "recipe"  
    },   

---  

## **3️ Response Format**  
Ensure the **output is strictly valid JSON** with the following structure:  
{  
  "dishes": [<detected dish objects>],  
  "recipes": [<generated recipe objects>],  
  "detectedItemNames": [<list of detected food items>]  
}  

---  

## **4️ No Food Detected**  
If **no food-related items** are found, return this **exact JSON response**:  
{  
  "dishes": [],  
  "recipes": [],  
  "detectedItemNames": [],  
  "message": "No food-related items detected. Please provide an image containing food."  
}  

---  

## **⚠️ Important Notes**  
✔ **Ensure image URLs are real and valid.** Before returning a Wikimedia Commons URL, **verify it exists**.     
✔ **If a valid URL is not found, use `" "` as a fallback.**    
✔ **Ensure valid JSON output (no trailing commas, proper formatting).**    
✔ **Ensure `preparationTime` is a realistic estimate** based on standard cooking times.    
✔ **If unavailable, estimate using similar dishes instead of `0`**.    
✔ **Use integer values only (no strings, no decimals).**    
✔ **Minimum preparation time must be at least `15` minutes.**    
✔ **Accurate preparation time (in minutes, realistic based on the dish). Do NOT return 0.**  
""";
