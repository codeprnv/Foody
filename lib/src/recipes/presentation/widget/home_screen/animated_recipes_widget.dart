// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:Foody/src/recipes/presentation/widget/home_screen/loaded_recipes_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Foody/src/recipes/data/recipe_repository.dart';

class AnimatedRecipesWidget extends ConsumerWidget {
  final File? fallbackImageFile; // Optional fallback image

  const AnimatedRecipesWidget({
    super.key,
    this.fallbackImageFile, // Optional
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);

    return recipes.when(
      error: (error, stackTrace) => const SliverToBoxAdapter(
        child: Center(
          child: Text("Failed to load recipes! Please try again."),
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (recipes) => LoadedRecipesWidget(
        recipes: recipes,
        fallbackImageFile:
            fallbackImageFile, // Pass fallback image if available
      ),
    );
  }
}
