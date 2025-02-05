const String foodDetectionPrompt = """
Analyze this image and detect food-related items (ingredients, dishes, or food products). Based on the detection:

1. If the detected item is a fully prepared dish or already-made food product, include a single object in the "dishes" array with the following structure:
   - "id": A unique identifier for the dish.
   - "name": The name of the dish.
   - "description": A brief description of the dish.
   - "imageUrl": A placeholder for the image (use "assets/images/dish.png" if unavailable).
   - "ingredients": A list of ingredients used in the dish. Use an empty array if not available.
   - "steps": Detailed step-by-step instructions for preparation. Include all necessary steps to prepare the dish.
   - "nutrition": An object containing:
     - "calories": Calories per serving as a string (e.g., "400-500 per serving"). Leave as an empty string if not available.
     - "protein": Protein content per serving as a string (e.g., "10-15 grams per serving"). Leave as an empty string if not available.
     - "preparationTime": Preparation time as a string (e.g., "45 minutes"). Leave as an empty string if not available.
   - "detectedType": "dish"

2. If the detected items are ingredients, provide up to 4 possible recipes in the "recipes" array. Each recipe object should follow the same structure as the "dishes" object:
   - "id": A unique identifier for the recipe.
   - "name": The name of the recipe.
   - "description": A brief description of the recipe.
   - "imageUrl": A placeholder for the image (use "assets/images/recipe.png" if unavailable).
   - "ingredients": A list of ingredients required for the recipe. Use an empty array if not available.
   - "steps": Detailed step-by-step instructions for preparation. Include all necessary steps to prepare the recipe.
   - "nutrition": An object containing:
     - "calories": Calories per serving as a string (e.g., "400-500 per serving"). Leave as an empty string if not available.
     - "protein": Protein content per serving as a string (e.g., "10-15 grams per serving"). Leave as an empty string if not available.
     - "preparationTime": Preparation time as a string (e.g., "45 minutes"). Leave as an empty string if not available.
   - "detectedType": ""

3. Ensure the output is **strictly in valid JSON format** with the following structure:
{ "dishes": [<list of detected dishes>], "recipes": [<list of suggested recipes>], "detectedItemNames": [<list of detected item names>] }

4. If no food-related items are detected in the image, respond with the following JSON:
{ "dishes": [], "recipes": [], "detectedItemNames": [], "message": "The image does not contain any food-related items. Please provide an image containing food." }

""";
