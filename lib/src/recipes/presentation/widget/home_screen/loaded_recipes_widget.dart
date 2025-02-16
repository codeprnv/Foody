import 'dart:io';
import 'package:Foody/src/recipes/domain/recipe.dart';
import 'package:Foody/src/recipes/presentation/widget/home_screen/recipe_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadedRecipesWidget extends StatelessWidget {
  final List<Recipe> recipes;
  final File? fallbackImageFile; // Optional fallback image

  const LoadedRecipesWidget({
    Key? key,
    required this.recipes,
    this.fallbackImageFile, // Optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/recipe_details',
                arguments: recipes[index],
              );
            },
            child: RecipeCardWidget(
              recipe: recipes[index],
              fallbackImageFile: fallbackImageFile, // Pass fallback image
            ).animate().slideX(
                duration: 200.ms,
                delay: 0.ms,
                begin: 1,
                end: 0,
                curve: Curves.easeInOutSine),
          );
        },
        childCount: recipes.length,
      ),
    );
  }
}
