import 'dart:io';
import 'package:Foody/src/recipes/presentation/screens/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:Foody/src/recipes/presentation/utils/prompts.dart';
import 'package:Foody/src/recipes/presentation/widget/home_screen/recipe_card_widget.dart';
import 'package:Foody/src/recipes/domain/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObjectDetectionScreen extends StatefulWidget {
  final File imageFile;

  const ObjectDetectionScreen({Key? key, required this.imageFile})
      : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> _dishes = []; // Store detected dishes
  bool _loading = true;
  String _message = '';
  List<String> _detectedItemNames = [];

  @override
  void initState() {
    super.initState();
    _detectFoodWithGemini();
  }

  Future<void> _detectFoodWithGemini() async {
    const apiKey = "AIzaSyBzYfWE4PKqQ9rcFsZv8dTjCvb53nfaK1g";
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final imageBytes = await widget.imageFile.readAsBytes();
    const mimetype = 'image/jpg';

    String cacheKey =
        widget.imageFile.path.hashCode.toString(); // Unique cache key

    try {
      // Load cache
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedResponse = prefs.getString(cacheKey);

      if (cachedResponse != null) {
        debugPrint("Using cached response");
        _handleGeminiResponse(cachedResponse);
        return;
      }

      int retries = 0;
      int delayMs = 1000; // Start with 1 second delay
      int maxRetries = 5;

      while (retries < maxRetries) {
        try {
          final response = await model.generateContent([
            Content.multi([
              TextPart(foodDetectionPrompt),
              DataPart(mimetype, imageBytes),
            ])
          ]);

          if (response.text != null) {
            debugPrint("Gemini response received.");
            await prefs.setString(cacheKey, response.text!); // Cache response
            _handleGeminiResponse(response.text!);
            return;
          } else {
            debugPrint("Empty response, retrying...");
          }
        } catch (e) {
          debugPrint("Attempt $retries failed: $e");

          if (e.toString().contains("exhausted") ||
              e.toString().contains("quota")) {
            debugPrint("Rate limit exceeded. Waiting for cooldown...");
            await Future.delayed(Duration(seconds: 60)); // Wait 1 minute
            retries = 0; // Reset retry count after cooldown
            continue;
          }

          if (!e.toString().contains("503")) {
            break; // Stop retrying if it's not a server overload issue
          }
        }

        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs =
            (delayMs * 2).clamp(1000, 30000); // Exponential backoff, max 30 sec
        retries++;
      }

      setState(() {
        _message =
            'Failed to get response from Gemini after multiple attempts.';
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error using Gemini API: $e');
      setState(() {
        _message = 'An error occurred while using Gemini API.';
        _loading = false;
      });
    }
  }

  void _handleGeminiResponse(String responseText) {
    final parsedResponse = _parseGeminiResponse(responseText);
    String fullResponse = jsonEncode(parsedResponse);
    for (int i = 0; i < fullResponse.length; i += 1000) {
      debugPrint(fullResponse.substring(
          i, i + 1000 > fullResponse.length ? fullResponse.length : i + 1000));
    }
    setState(() {
      _recipes = parsedResponse['recipes'];
      _dishes = parsedResponse['dishes'];
      _detectedItemNames = parsedResponse['detectedItemNames'];
      _message = parsedResponse['message'];
      _loading = false;
    });
  }

  Map<String, dynamic> _parseGeminiResponse(String responseText) {
    List<Map<String, dynamic>> recipes = [];
    List<Map<String, dynamic>> dishes = [];
    List<String> detectedItemNames = [];
    String message = '';

    try {
      responseText =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonResponse = jsonDecode(responseText);

      if (jsonResponse['recipes'] != null) {
        recipes = (jsonResponse['recipes'] as List).map((recipe) {
          return {
            'id': recipe['id'],
            'name': recipe['name'],
            'description': recipe['description'],
            'imageUrl': _validateImageUrl(recipe['imageUrl']),
            'ingredients': List<String>.from(recipe['ingredients'] ?? []),
            'steps': List<String>.from(recipe['steps'] ?? []),
            'nutrition': _parseNutrition(recipe['nutrition'])
          };
        }).toList();
      }

      if (jsonResponse['dishes'] != null) {
        dishes = (jsonResponse['dishes'] as List).map((dish) {
          return {
            'id': dish['id'],
            'name': dish['name'],
            'description': dish['description'],
            'imageUrl': _validateImageUrl(dish['imageUrl']),
            'ingredients': List<String>.from(dish['ingredients'] ?? []),
            'steps': List<String>.from(dish['steps'] ?? []),
            'nutrition': _parseNutrition(dish['nutrition'])
          };
        }).toList();
      }

      if (jsonResponse['detectedItemNames'] != null) {
        detectedItemNames =
            List<String>.from(jsonResponse['detectedItemNames']);
      }

      message = detectedItemNames.isNotEmpty
          ? 'Detected food items successfully.'
          : 'No food-related items detected.';
    } catch (e) {
      message = 'Failed to process the response.';
    }

    return {
      'recipes': recipes,
      'dishes': dishes,
      'detectedItemNames': detectedItemNames,
      'message': message,
    };
  }

  Map<String, int> _parseNutrition(Map<String, dynamic>? nutritionData) {
    if (nutritionData == null) {
      return {
        'calories': 0,
        'protein': 0,
        'prepTime': 10
      }; // Ensure a default minimum
    }

    return {
      'calories':
          int.tryParse(nutritionData['calories']?.toString() ?? '') ?? 0,
      'protein': int.tryParse(nutritionData['protein']?.toString() ?? '') ?? 0,
      'prepTime':
          _validatePrepTime(nutritionData['prepTime']), // Fix prepTime handling
    };
  }

// Ensure a minimum prep time
  int _validatePrepTime(dynamic prepTime) {
    int time = int.tryParse(prepTime?.toString() ?? '') ?? 0;
    return time > 0 ? time : 10; // Ensure at least 10 minutes if 0 or invalid
  }

  String _validateImageUrl(String? url) {
    if (url != null && Uri.tryParse(url)?.isAbsolute == true) {
      return url;
    }
    return 'assets/images/dish.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestion with Foody'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: ClipOval(
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 10),
                if (_detectedItemNames.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: List<Widget>.generate(
                              _detectedItemNames.length,
                              (index) {
                                final itemName = _detectedItemNames[index];
                                return Chip(
                                  label: Text(
                                    itemName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.deepPurpleAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  elevation: 3,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: (_dishes.isNotEmpty || _recipes.isNotEmpty)
                      ? ListView.builder(
                          itemCount: _dishes.isNotEmpty
                              ? _dishes.length
                              : _recipes.length,
                          itemBuilder: (context, index) {
                            final item = _dishes.isNotEmpty
                                ? _dishes[index]
                                : _recipes[index];
                            final recipe = Recipe(
                              name: item['name'] ?? 'Unknown',
                              description: item['description'] ??
                                  'No description available',
                              imageUrl:
                                  item['imageUrl'] ?? 'assets/images/dish.png',
                              nutrition: item['nutrition'] != null
                                  ? Map<String, num>.from(item['nutrition'].map(
                                      (key, value) => MapEntry(key,
                                          num.tryParse(value.toString()) ?? 0)))
                                  : {},
                              ingredients:
                                  List<String>.from(item['ingredients'] ?? []),
                              steps: List<String>.from(item['steps'] ?? []),
                              id: item['id'] ?? '',
                            );

                            return GestureDetector(
                              onTap: () {
                                // Navigate to RecipeDetailsScreen when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailsScreen(
                                      recipe: recipe,
                                      userImage: widget.imageFile,
                                    ),
                                  ),
                                );
                              },
                              child: RecipeCardWidget(
                                recipe: recipe,
                                fallbackImageFile: widget
                                    .imageFile, // Pass the selected image file
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'No dishes or recipes to display.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
