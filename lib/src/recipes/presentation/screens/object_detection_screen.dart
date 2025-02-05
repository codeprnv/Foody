import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:Foody/src/recipes/presentation/utils/prompts.dart';

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
    try {
      const apiKey = "AIzaSyCnA0Cw_MqlalY0aGJM5w7LUmFK6Kf0iKg";
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      final imageBytes = await widget.imageFile.readAsBytes();
      const mimetype = 'image/jpg';

      final response = await model.generateContent([
        Content.multi([
          TextPart(foodDetectionPrompt),
          DataPart(mimetype, imageBytes),
        ])
      ]);

      debugPrint('Gemini response: ${response.text}');

      if (response.text != null) {
        final parsedResponse = _parseGeminiResponse(response.text!);
        setState(() {
          _recipes = parsedResponse['recipes'];
          _dishes = parsedResponse['dishes']; // Save detected dishes
          _detectedItemNames = parsedResponse['detectedItemNames'];
          debugPrint('Detected Items: $_detectedItemNames');
          _message = parsedResponse['message'];
          _loading = false;
        });
      } else {
        setState(() {
          _message = 'No response received from Gemini.';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error using Gemini API: $e');
      setState(() {
        _message = 'Error occurred while using Gemini API.';
        _loading = false;
      });
    }
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

      // Extract recipes
      if (jsonResponse['recipes'] != null) {
        recipes = (jsonResponse['recipes'] as List)
            .map((recipe) => {
                  'id': recipe['id'],
                  'name': recipe['name'],
                  'description': recipe['description'],
                  'imageUrl': recipe['imageUrl'] ?? 'assets/images/recipe.png',
                  'ingredients': recipe['ingredients'] ?? [],
                  'steps': recipe['steps'] ?? [],
                  'nutrition': recipe['nutrition'] ?? {}
                })
            .toList();
      }

      // Extract dishes (for fully prepared dishes)
      if (jsonResponse['dishes'] != null) {
        dishes = (jsonResponse['dishes'] as List)
            .map((dish) => {
                  'id': dish['id'],
                  'name': dish['name'],
                  'description': dish['description'],
                  'imageUrl': dish['imageUrl'] ?? 'assets/images/dish.png',
                  'ingredients': dish['ingredients'] ?? [],
                  'steps': dish['steps'] ?? [],
                  'nutrition': dish['nutrition'] ?? {}
                })
            .toList();
      }

      // Extract detected item names
      if (jsonResponse['detectedItemNames'] != null) {
        detectedItemNames =
            List<String>.from(jsonResponse['detectedItemNames']);
      }

      message = detectedItemNames.isNotEmpty
          ? 'Detected food items successfully.'
          : 'No food-related items detected.';
    } catch (e) {
      debugPrint('Error parsing Gemini response: $e');
      message = 'Failed to process the response.';
    }

    return {
      'recipes': recipes,
      'dishes': dishes,
      'detectedItemNames': detectedItemNames,
      'message': message,
    };
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Detected Items:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: List<Widget>.generate(
                              _detectedItemNames.length,
                              (index) {
                                final itemName = _detectedItemNames[index];
                                return Chip(
                                  label: Text(
                                    itemName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
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
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 4,
                              child: ExpansionTile(
                                title: Text(
                                  item['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(item['description'] ??
                                    'No description available'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Ingredients:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          (item['ingredients'] as List)
                                                  .isNotEmpty
                                              ? (item['ingredients'] as List)
                                                  .join(", ")
                                              : 'No ingredients',
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Instructions:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          (item['steps'] as List).isNotEmpty
                                              ? (item['steps'] as List)
                                                  .join("\n")
                                              : 'No instructions',
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Nutrition:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Calories: ${item['nutrition']['calories'] ?? 'Not available'}',
                                        ),
                                        Text(
                                          'Protein: ${item['nutrition']['protein'] ?? 'Not available'}',
                                        ),
                                        Text(
                                          'Preparation Time: ${item['nutrition']['preparationTime'] ?? 'Not available'}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'No dishes or recipes to display.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
